local _, FEP = ...
local Database = {}
FEP:RegisterModule("Database", Database)

local CURRENT_SCHEMA = 2
local defaults = {
    schema = CURRENT_SCHEMA,
    settings = { slotCount = 5, developerMode = false, showMinimapHint = true, autoShare = false, appearance = "blizzard" },
    activeLoadout = { name = "Current Expedition", slots = {} },
    presets = {},
    assignments = {},
    checklist = { materials = {}, readiness = {} },
    windowPosition = { x = 0, y = 0 },
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

local starterChecklist = {
    "Repair gear", "Empty bags", "Food/drink", "Meet-up point confirmed", "Quests reviewed", "Materials checked",
}
local starterPresets = { "Dungeon Run", "Gathering Trip", "Group Expedition" }

local function seedStarterContent(db)
    if db.starterContentSeeded then return end
    -- Starter plans are intentionally generic and keep every camp slot
    -- unassigned. They provide useful planning structure without presenting
    -- unverified object names, costs, or effects as game facts.
    for _, name in ipairs(starterPresets) do
        if db.presets[name] == nil then db.presets[name] = { name = name, slotCount = 5, slots = {} } end
    end
    if #db.checklist.readiness == 0 then
        for _, label in ipairs(starterChecklist) do
            table.insert(db.checklist.readiness, { label = label, checked = false })
        end
    end
    db.starterContentSeeded = true
end

function Database:Initialize()
    if type(ForeverExpeditionPlannerDB) ~= "table" then ForeverExpeditionPlannerDB = {} end
    copyDefaults(defaults, ForeverExpeditionPlannerDB)
    FEP.db = ForeverExpeditionPlannerDB
    if FEP.db.settings.appearance ~= "blizzard" and FEP.db.settings.appearance ~= "bronze" then
        FEP.db.settings.appearance = "blizzard"
    end
    seedStarterContent(FEP.db)
    FEP.db.schema = CURRENT_SCHEMA
    local position = FEP.db.windowPosition
    if type(position.x) ~= "number" or position.x ~= position.x then position.x = 0 end
    if type(position.y) ~= "number" or position.y ~= position.y then position.y = 0 end
    position.x = math.max(-2000, math.min(2000, position.x))
    position.y = math.max(-2000, math.min(2000, position.y))
    if FEP.db.settings.developerMode then FEP:LoadDeveloperFixtures() end
end

function Database:Reset()
    ForeverExpeditionPlannerDB = {}
    copyDefaults(defaults, ForeverExpeditionPlannerDB)
    FEP.db = ForeverExpeditionPlannerDB
    seedStarterContent(FEP.db)
    FEP.db.schema = CURRENT_SCHEMA
    FEP:Emit("DATA_CHANGED")
end
