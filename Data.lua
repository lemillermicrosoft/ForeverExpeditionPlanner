local _, FEP = ...

-- Production intentionally ships without purportedly authoritative camp data.
-- Future data packs may call RegisterCampObjects with verified records.
FEP.Data = { objects = {}, byID = {}, providers = {} }

local required = { "id", "name", "category", "description" }
function FEP:RegisterCampObjects(provider, records)
    if type(provider) ~= "string" or type(records) ~= "table" then return false end
    for _, record in ipairs(records) do
        local valid = true
        for _, key in ipairs(required) do
            if type(record[key]) ~= "string" or record[key] == "" then valid = false end
        end
        if valid and not self.Data.byID[record.id] then
            record.provider = provider
            record.materials = type(record.materials) == "table" and record.materials or {}
            record.tags = type(record.tags) == "table" and record.tags or {}
            table.insert(self.Data.objects, record)
            self.Data.byID[record.id] = record
        end
    end
    self.Data.providers[provider] = true
    self:Emit("DATA_CHANGED")
    return true
end

function FEP:GetCampObject(id)
    return self.Data.byID[id]
end

function FEP:SearchCampObjects(query)
    query = (query or ""):lower()
    local results = {}
    for _, object in ipairs(self.Data.objects) do
        local haystack = (object.name .. " " .. object.category .. " " .. object.description .. " " .. table.concat(object.tags, " ")):lower()
        if query == "" or haystack:find(query, 1, true) then table.insert(results, object) end
    end
    table.sort(results, function(a, b) return a.name < b.name end)
    return results
end

function FEP:LoadDeveloperFixtures()
    if not self.db or not self.db.settings.developerMode then return end
    self:RegisterCampObjects("FEP sample fixtures (not game data)", {
        { id = "sample-comfort", name = "Sample Comfort Object", category = "Utility", description = "Developer-only fixture. Not authoritative game data.", tags = { "sample", "comfort" }, materials = { { name = "Sample Material", count = 2 } }, buffs = { "sample-comfort" } },
        { id = "sample-feast", name = "Sample Shared Feast", category = "Provision", description = "Developer-only fixture for assignment and conflict testing.", tags = { "sample", "food" }, materials = { { name = "Sample Ingredient", count = 5 } }, buffs = { "sample-food" } },
        { id = "sample-snack", name = "Sample Personal Snack", category = "Provision", description = "Developer-only non-stacking fixture.", tags = { "sample", "food" }, materials = {}, buffs = { "sample-food" } },
    })
end
