local _, FEP = ...
local Conflicts = {}
FEP:RegisterModule("Conflicts", Conflicts)

-- This evaluator is data-driven. A verified data pack supplies shared buff keys
-- or explicit conflict keys; the addon does not guess game stacking rules.
function Conflicts:Evaluate(objectIDs)
    local seen, warnings = {}, {}
    for slot, id in ipairs(objectIDs or {}) do
        local object = FEP:GetCampObject(id)
        if object then
            local keys = object.conflicts or object.buffs or {}
            for _, key in ipairs(keys) do
                if seen[key] then
                    table.insert(warnings, { key = key, first = seen[key], second = slot, message = object.name .. " may not stack with slot " .. seen[key] })
                else
                    seen[key] = slot
                end
            end
        end
    end
    return warnings
end
