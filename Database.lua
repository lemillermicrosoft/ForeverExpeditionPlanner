local _, FEP = ...
local Database = {}; FEP:RegisterModule("Database", Database)
local CURRENT_SCHEMA = 4
local defaults = {
    schema = CURRENT_SCHEMA,
    settings = { slotCount = 5, showMinimapHint = true, autoShare = false, appearance = "blizzard" },
    activeLoadout = { name = "Current Expedition", slots = {} }, presets = {}, assignments = {},
    checklist = { materials = {}, readiness = {} }, readinessPreset = "Dungeon", windowPosition = { x = 0, y = 0 },
}
local readiness = {
    Dungeon = { "Repair gear", "Empty bag space", "Restock consumables", "Review route, quests, and roles", "Confirm meeting stone/travel route", "Check camp materials" },
    Travel = { "Set destination and route", "Check hearthstone and flight paths", "Empty bag space", "Bring food and water", "Confirm party meeting point", "Check camp materials" },
}
local function copyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then if type(target[key]) ~= "table" then target[key] = {} end; copyDefaults(value, target[key])
        elseif target[key] == nil then target[key] = value end
    end
end
local function applyReadiness(db, name)
    name = readiness[name] and name or "Dungeon"; db.readinessPreset, db.checklist.readiness = name, {}
    for _, label in ipairs(readiness[name]) do db.checklist.readiness[#db.checklist.readiness + 1] = { label = label, checked = false } end
end
local function migrate(db)
    local schema = tonumber(db.schema) or 0
    if schema < 2 then db.settings = db.settings or {}; db.settings.appearance = "blizzard"; schema = 2 end
    if schema < 3 then db.settings.developerMode = nil; db.transferSchema = 1; schema = 3 end
    if schema < 4 then db.readinessPreset = db.readinessPreset or "Dungeon"; schema = 4 end
    db.schema = schema
end
function Database:Initialize()
    if type(ForeverExpeditionPlannerDB) ~= "table" then ForeverExpeditionPlannerDB = {} end
    migrate(ForeverExpeditionPlannerDB); copyDefaults(defaults, ForeverExpeditionPlannerDB); FEP.db = ForeverExpeditionPlannerDB
    local s = FEP.db.settings; if s.appearance ~= "blizzard" and s.appearance ~= "bronze" then s.appearance = "blizzard" end
    if s.slotCount ~= 3 and s.slotCount ~= 5 and s.slotCount ~= 10 then s.slotCount = 5 end
    if #FEP.db.checklist.readiness == 0 then applyReadiness(FEP.db, FEP.db.readinessPreset) end
    local p = FEP.db.windowPosition; p.x = type(p.x) == "number" and math.max(-2000, math.min(2000, p.x)) or 0; p.y = type(p.y) == "number" and math.max(-2000, math.min(2000, p.y)) or 0
    FEP.db.schema = CURRENT_SCHEMA
end
function Database:SetReadinessPreset(name) if readiness[name] then applyReadiness(FEP.db, name); FEP:Emit("CHECKLIST_CHANGED"); return true end return false end
function Database:Reset() ForeverExpeditionPlannerDB = {}; self:Initialize(); FEP:Emit("DATA_CHANGED"); FEP:Emit("PLAN_CHANGED") end
Database.CURRENT_SCHEMA, Database.readiness = CURRENT_SCHEMA, readiness
