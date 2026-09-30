local _, FEP = ...
local Checklists = {}
FEP:RegisterModule("Checklists", Checklists)

local readinessDefaults = { "Repair gear", "Empty bag space", "Restock consumables", "Review route and roles" }

function Checklists:Initialize()
    if #FEP.db.checklist.readiness == 0 then
        for _, label in ipairs(readinessDefaults) do
            table.insert(FEP.db.checklist.readiness, { label = label, checked = false })
        end
    end
    self:RebuildMaterials()
end

function Checklists:RebuildMaterials()
    local old, totals = {}, {}
    for _, row in ipairs(FEP.db.checklist.materials) do old[row.label] = row.checked end
    for index = 1, FEP.db.settings.slotCount do
        local id = FEP.db.activeLoadout.slots[index]
        local object = FEP:GetCampObject(id)
        if object then
            for _, material in ipairs(object.materials or {}) do
                totals[material.name] = (totals[material.name] or 0) + (tonumber(material.count) or 0)
            end
        end
    end
    FEP.db.checklist.materials = {}
    for name, count in pairs(totals) do
        local label = count .. " × " .. name
        table.insert(FEP.db.checklist.materials, { label = label, checked = old[label] or false })
    end
    table.sort(FEP.db.checklist.materials, function(a, b) return a.label < b.label end)
    FEP:Emit("CHECKLIST_CHANGED")
end

function Checklists:Toggle(kind, index)
    local row = FEP.db.checklist[kind] and FEP.db.checklist[kind][index]
    if row then
        row.checked = not row.checked
        FEP:Emit("CHECKLIST_CHANGED")
    end
end

FEP:On("PLAN_CHANGED", function() Checklists:RebuildMaterials() end)
