local _, FEP = ...
local Conflicts = {}; FEP:RegisterModule("Conflicts", Conflicts)
function Conflicts:Evaluate(objectIDs)
    local seen, warnings = {}, {}
    for slot = 1, 10 do
        local object = FEP:GetCampObject(objectIDs[slot])
        if object then
            local keys = {}; for _, key in ipairs(object.buffs or {}) do keys[#keys + 1] = "buff:" .. key end; for _, key in ipairs(object.conflicts or {}) do keys[#keys + 1] = "conflict:" .. key end
            for _, key in ipairs(keys) do
                if seen[key] then warnings[#warnings + 1] = { key = key, first = seen[key], second = slot, message = object.name .. " may not stack with slot " .. seen[key] }
                else seen[key] = slot end
            end
        end
    end
    return warnings
end
