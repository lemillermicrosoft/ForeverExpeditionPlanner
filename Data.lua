local _, FEP = ...

FEP.Data = { objects = {}, byID = {}, providers = {}, manifests = {} }
local required = { "id", "name", "category", "description", "verification" }
local function cleanString(value, maximum)
    if type(value) ~= "string" then return nil end
    value = value:match("^%s*(.-)%s*$")
    if value == "" or #value > (maximum or 200) then return nil end
    return value
end

function FEP:RegisterCampObjects(provider, records, manifest)
    provider = cleanString(provider, 80)
    if not provider or type(records) ~= "table" then return false, "invalid provider" end
    local accepted = 0
    for _, source in ipairs(records) do
        local record, valid = {}, true
        for _, key in ipairs(required) do
            if key == "verification" then
                valid = valid and type(source.verification) == "table"
            else
                record[key] = cleanString(source[key], key == "description" and 600 or 120)
                valid = valid and record[key] ~= nil
            end
        end
        local v = source.verification
        if valid then
            for _, key in ipairs({ "source", "url", "build", "license", "verifiedOn", "status" }) do
                if not cleanString(v[key], 500) then valid = false end
            end
        end
        if valid and not self.Data.byID[record.id] then
            record.provider, record.verification = provider, v
            record.materials, record.tags, record.buffs, record.conflicts = {}, {}, {}, {}
            record.icon = type(source.icon) == "number" and source.icon or nil
            record.itemID = type(source.itemID) == "number" and source.itemID or nil
            for _, material in ipairs(type(source.materials) == "table" and source.materials or {}) do
                if cleanString(material.name, 120) and tonumber(material.count) and tonumber(material.count) > 0 then
                    record.materials[#record.materials + 1] = { name = material.name, count = tonumber(material.count), itemID = tonumber(material.itemID) }
                end
            end
            for _, field in ipairs({ "tags", "buffs", "conflicts" }) do
                for _, value in ipairs(type(source[field]) == "table" and source[field] or {}) do
                    value = cleanString(value, 120); if value then record[field][#record[field] + 1] = value end
                end
            end
            self.Data.objects[#self.Data.objects + 1], self.Data.byID[record.id] = record, record
            accepted = accepted + 1
        end
    end
    self.Data.providers[provider] = { records = accepted }
    if manifest then self.Data.manifests[provider] = manifest end
    self:Emit("DATA_CHANGED")
    return true, accepted
end

function FEP:GetCampObject(id) return self.Data.byID[id] end
function FEP:SearchCampObjects(query)
    query = (type(query) == "string" and query or ""):lower()
    local results = {}
    for _, object in ipairs(self.Data.objects) do
        local haystack = (object.name .. " " .. object.category .. " " .. object.description .. " " .. table.concat(object.tags, " ")):lower()
        if query == "" or haystack:find(query, 1, true) then results[#results + 1] = object end
    end
    table.sort(results, function(a, b) return a.name == b.name and a.id < b.id or a.name < b.name end)
    return results
end
function FEP:GetDataStatus()
    return #self.Data.objects, FEP.DataManifest and FEP.DataManifest.blocker or "No manifest loaded."
end
