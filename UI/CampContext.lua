local _, FEP = ...

local CampContext = {
    -- Interface 16001 feasibility audit: no documented, non-secret event or API
    -- identifies proximity to/interacting with a Forever campfire. Detection is
    -- therefore deliberately manual until a provider can prove a safe adapter.
    detector = { id = "manual-v1", automatic = false, verified = false },
}
FEP:RegisterModule("CampContext", CampContext)

local function secret(value)
    if type(issecretvalue) ~= "function" then return false end
    local ok, result = pcall(issecretvalue, value)
    return not ok or result == true
end

local function safePlayerName()
    if type(UnitName) ~= "function" then return nil end
    local ok, value = pcall(UnitName, "player")
    if not ok or secret(value) or type(value) ~= "string" or value == "" then return nil end
    return value
end

local function safeInGroup()
    if type(IsInGroup) ~= "function" then return false end
    local ok, value = pcall(IsInGroup)
    return ok and not secret(value) and value == true
end

local function samePlayer(left, right)
    if type(left) ~= "string" or type(right) ~= "string" then return false end
    local a = left:match("^[^-]+")
    local b = right:match("^[^-]+")
    return a and b and a:lower() == b:lower() or false
end

local function materialText(object)
    local values = {}
    for _, material in ipairs(object.materials or {}) do
        values[#values + 1] = tostring(material.count) .. " x " .. material.name
    end
    return #values > 0 and table.concat(values, ", ") or "No verified material requirements"
end

local function effectText(object)
    local values = {}
    for _, buff in ipairs(object.buffs or {}) do values[#values + 1] = buff end
    return #values > 0 and table.concat(values, ", ") or "No verified buff/effect details"
end

function CampContext:Initialize()
    self.contextActive = false
end

function CampContext:GetDetectionStatus()
    return "Automatic campfire sensing is unavailable: Interface 16001 exposes no proven permitted camp-context API/event. Manual context is " .. (self.contextActive and "active." or "inactive.")
end

function CampContext:Probe()
    local build = "unknown"
    if type(GetBuildInfo) == "function" then
        local ok, _, value = pcall(GetBuildInfo)
        if ok and not secret(value) and (type(value) == "string" or type(value) == "number") then build = tostring(value) end
    end
    return "Camp probe: build " .. build .. "; adapter manual-v1; automatic=false; no target, nameplate, combat-log, mouseover, or tooltip inspection performed."
end

function CampContext:SetActive(active)
    self.contextActive = active == true
    FEP:Emit("CAMP_CONTEXT_CHANGED", self.contextActive)
    return self.contextActive
end

function CampContext:Toggle()
    return self:SetActive(not self.contextActive)
end

function CampContext:GetChoices()
    return FEP:SearchCampObjects("")
end

function CampContext:SetDefault(id)
    if id ~= nil and not FEP:GetCampObject(id) then return false, "Choose a verified catalog option first." end
    FEP.db.campButton.defaultObjectID = id
    FEP:Emit("CAMP_DEFAULT_CHANGED", id)
    return true
end

function CampContext:GetRecommendation()
    local choices = self:GetChoices()
    if #choices == 0 then
        return nil, "No verified camp additions are available. The catalog is intentionally empty rather than guessed."
    end

    local grouped = safeInGroup()
    local player = grouped and safePlayerName() or nil
    if player then
        for slot = 1, FEP.db.settings.slotCount do
            local object = FEP:GetCampObject(FEP.db.activeLoadout.slots[slot])
            if object and samePlayer(FEP.db.assignments[slot], player) then
                return object, "Recommended because the current bounded FEP2 plan assigns this verified option to you."
            end
        end
    end

    if grouped then
        local represented = {}
        for slot = 1, FEP.db.settings.slotCount do
            local object = FEP:GetCampObject(FEP.db.activeLoadout.slots[slot])
            if object then for _, buff in ipairs(object.buffs or {}) do represented[buff] = true end end
        end
        for _, object in ipairs(choices) do
            for _, buff in ipairs(object.buffs or {}) do
                if not represented[buff] then
                    return object, "Recommended because its verified effect (" .. buff .. ") is not represented in the current FEP2 plan. No stacking behavior is inferred."
                end
            end
        end
    end

    local default = FEP:GetCampObject(FEP.db.campButton.defaultObjectID)
    if default then return default, "Recommended because it is your saved personal default." end
    return choices[1], "Recommended as the first verified catalog option; no personal default or matching assignment is known."
end

function CampContext:Describe(object)
    if not object then return "No verified option selected." end
    return object.name .. "\nEffect: " .. effectText(object) .. "\nMaterials: " .. materialText(object) .. "\nVerified: " .. object.verification.source .. " (" .. object.verification.status .. ")"
end
