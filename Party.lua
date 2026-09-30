local _, FEP = ...
local Party = { prefix = "FEP1", roster = {} }
FEP:RegisterModule("Party", Party)

local function isSecret(value)
    if type(issecretvalue) ~= "function" then return false end
    local ok, result = pcall(issecretvalue, value)
    return not ok or result == true
end

local function safeString(value, fallback)
    if isSecret(value) then return fallback end
    if type(value) ~= "string" then return fallback end
    return value
end

local function sanitize(value)
    local text = safeString(value, "")
    return text:gsub("[|;\n\r]", " "):sub(1, 80)
end

local function safeUnitName(unit, fallback)
    local ok, name = pcall(UnitName, unit)
    if not ok then return fallback end
    return safeString(name, fallback)
end

function Party:Initialize()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(self.prefix)
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.prefix)
    end
    self:RefreshRoster()
end

function Party:RefreshRoster()
    self.roster = { safeUnitName("player", "Player") }
    local units = IsInRaid() and "raid" or "party"
    local count = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, count do
        local name = safeUnitName(units .. i, nil)
        if name then table.insert(self.roster, name) end
    end
    FEP:Emit("ROSTER_CHANGED")
end

function Party:SetAssignment(slot, player)
    FEP.db.assignments[slot] = sanitize(player)
    FEP:Emit("ASSIGNMENTS_CHANGED")
end

function Party:Send(payload, channel)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(self.prefix, payload, channel)
    elseif SendAddonMessage then
        SendAddonMessage(self.prefix, payload, channel)
    end
end

function Party:Broadcast()
    if not IsInGroup() then FEP:Print("Not in a group. Use the manual summary instead.") return false end
    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or "PARTY")
    -- One bounded record per slot stays safely below addon-message payload limits.
    self:Send("B|" .. FEP.db.settings.slotCount, channel)
    for i = 1, FEP.db.settings.slotCount do
        local id = sanitize(FEP.db.activeLoadout.slots[i])
        local player = sanitize(FEP.db.assignments[i])
        self:Send("S|" .. i .. "|" .. id .. "|" .. player, channel)
    end
    FEP:Print("Assignments shared with addon users. Manual summary is available for everyone else.")
    return true
end

function Party:OnMessage(prefix, message, _, sender)
    prefix = safeString(prefix, nil)
    message = safeString(message, nil)
    if prefix == nil or message == nil or prefix ~= self.prefix then return end
    local count = tonumber(message:match("^B|(%d+)$"))
    if count == 3 or count == 5 or count == 10 then
        FEP.modules.Planner:SetSlotCount(count)
        local displaySender = safeString(sender, "group member")
        if Ambiguate and displaySender ~= "group member" then
            local ok, abbreviated = pcall(Ambiguate, displaySender, "short")
            displaySender = ok and safeString(abbreviated, "group member") or "group member"
        end
        FEP:Print("Receiving plan from " .. displaySender .. ".")
        return
    end
    local slot, id, player = message:match("^S|(%d+)|([^|]*)|([^|]*)$")
    slot = tonumber(slot)
    if not slot or slot > 10 then return end
    if id == "" or FEP:GetCampObject(id) then FEP.db.activeLoadout.slots[slot] = id ~= "" and id or nil end
    FEP.db.assignments[slot] = player ~= "" and player or nil
    FEP:Emit("PLAN_CHANGED")
end

function Party:GetManualSummary()
    local lines = { "Forever Expedition Planner — " .. FEP.db.activeLoadout.name }
    for i = 1, FEP.db.settings.slotCount do
        local object = FEP:GetCampObject(FEP.db.activeLoadout.slots[i])
        local item = object and object.name or "Unassigned"
        local player = FEP.db.assignments[i] or "Anyone"
        table.insert(lines, i .. ". " .. item .. " — " .. player)
    end
    return table.concat(lines, "\n")
end
