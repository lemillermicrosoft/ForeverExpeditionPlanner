local _, FEP = ...
local Planner = {}
FEP:RegisterModule("Planner", Planner)

local validCounts = { [3] = true, [5] = true, [10] = true }

function Planner:Initialize()
    self:SetSlotCount(FEP.db.settings.slotCount)
end

function Planner:SetSlotCount(count)
    count = tonumber(count)
    if not validCounts[count] then count = 5 end
    FEP.db.settings.slotCount = count
    local slots = FEP.db.activeLoadout.slots
    for index = count + 1, 10 do slots[index] = nil end
    FEP:Emit("PLAN_CHANGED")
end

function Planner:SetSlot(index, objectID)
    if index < 1 or index > FEP.db.settings.slotCount then return end
    if objectID and not FEP:GetCampObject(objectID) then return end
    FEP.db.activeLoadout.slots[index] = objectID
    FEP:Emit("PLAN_CHANGED")
end

function Planner:SavePreset(name)
    name = (name or ""):match("^%s*(.-)%s*$")
    if name == "" then return false end
    local copy = { name = name, slotCount = FEP.db.settings.slotCount, slots = {} }
    for i = 1, copy.slotCount do copy.slots[i] = FEP.db.activeLoadout.slots[i] end
    FEP.db.presets[name] = copy
    FEP:Emit("PRESETS_CHANGED")
    return true
end

function Planner:LoadPreset(name)
    local preset = FEP.db.presets[name]
    if not preset then return false end
    self:SetSlotCount(preset.slotCount)
    FEP.db.activeLoadout.slots = {}
    for i = 1, preset.slotCount do FEP.db.activeLoadout.slots[i] = preset.slots[i] end
    FEP:Emit("PLAN_CHANGED")
    return true
end

function Planner:DeletePreset(name)
    FEP.db.presets[name] = nil
    FEP:Emit("PRESETS_CHANGED")
end

function Planner:GetWarnings()
    return FEP.modules.Conflicts:Evaluate(FEP.db.activeLoadout.slots)
end
