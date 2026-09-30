local _, FEP = ...
local Database = {}
FEP:RegisterModule("Database", Database)

local defaults = {
    schema = 1,
    settings = { slotCount = 5, developerMode = false, showMinimapHint = true, autoShare = false },
    activeLoadout = { name = "Current Expedition", slots = {} },
    presets = {},
    assignments = {},
    checklist = { materials = {}, readiness = {} },
}

local function copyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            copyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function Database:Initialize()
    if type(ForeverExpeditionPlannerDB) ~= "table" then ForeverExpeditionPlannerDB = {} end
    copyDefaults(defaults, ForeverExpeditionPlannerDB)
    FEP.db = ForeverExpeditionPlannerDB
    if FEP.db.settings.developerMode then FEP:LoadDeveloperFixtures() end
end

function Database:Reset()
    ForeverExpeditionPlannerDB = {}
    copyDefaults(defaults, ForeverExpeditionPlannerDB)
    FEP.db = ForeverExpeditionPlannerDB
    FEP:Emit("DATA_CHANGED")
end
