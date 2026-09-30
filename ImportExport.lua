local _, FEP = ...
local Transfer = { SCHEMA = 1, PREFIX = "FEPX1" }
FEP:RegisterModule("Transfer", Transfer)

local function encode(value)
    return (tostring(value or ""):gsub("([^%w%-%._~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end
local function decode(value)
    if type(value) ~= "string" or #value > 8000 or value:find("%%[^%x]", 1) then return nil end
    return (value:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end))
end
local function split(value, separator)
    local out = {}; value = value or ""
    for part in (value .. separator):gmatch("(.-)" .. separator) do out[#out + 1] = part end
    return out
end
function Transfer:Export()
    local fields = { self.PREFIX, "S=" .. FEP.db.settings.slotCount, "N=" .. encode(FEP.db.activeLoadout.name) }
    local slots, assignments = {}, {}
    for i = 1, FEP.db.settings.slotCount do
        slots[i] = encode(FEP.db.activeLoadout.slots[i] or "")
        assignments[i] = encode(FEP.db.assignments[i] or "")
    end
    fields[#fields + 1] = "L=" .. table.concat(slots, ",")
    fields[#fields + 1] = "A=" .. table.concat(assignments, ",")
    return table.concat(fields, ";")
end
function Transfer:Parse(text)
    if type(text) ~= "string" or #text > 8000 or text:sub(1, 6) ~= self.PREFIX .. ";" then return nil, "Unsupported or oversized plan" end
    local values = {}
    for token in text:gmatch("[^;]+") do local k, v = token:match("^([A-Z])=(.*)$"); if k and not values[k] then values[k] = v end end
    local count = tonumber(values.S)
    if count ~= 3 and count ~= 5 and count ~= 10 then return nil, "Invalid slot count" end
    local plan = { slotCount = count, name = decode(values.N or "") or "Imported Expedition", slots = {}, assignments = {} }
    if #plan.name > 80 then return nil, "Name too long" end
    local slots, assignments = split(values.L, ","), split(values.A, ",")
    for i = 1, count do
        local id, player = decode(slots[i] or ""), decode(assignments[i] or "")
        if id == nil or player == nil or #id > 120 or #player > 80 then return nil, "Malformed field" end
        if id ~= "" and not FEP:GetCampObject(id) then return nil, "Unknown object: " .. id end
        plan.slots[i], plan.assignments[i] = id ~= "" and id or nil, player ~= "" and player or nil
    end
    return plan
end
function Transfer:Import(text)
    local plan, err = self:Parse(text); if not plan then return false, err end
    FEP.modules.Planner:SetSlotCount(plan.slotCount)
    FEP.db.activeLoadout = { name = plan.name, slots = plan.slots }
    FEP.db.assignments = plan.assignments
    FEP:Emit("PLAN_CHANGED"); FEP:Emit("ASSIGNMENTS_CHANGED")
    return true
end
