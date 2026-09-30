local _, FEP = ...
local Party = { prefix = "FEP2", protocol = 2, roster = {}, receiving = {} }; FEP:RegisterModule("Party", Party)
local function secret(v) if type(issecretvalue) ~= "function" then return false end local ok, r = pcall(issecretvalue, v); return not ok or r == true end
local function safe(v, fallback) if secret(v) or type(v) ~= "string" then return fallback end return v end
local function sanitize(v, limit) return safe(v, ""):gsub("[|;\n\r]", " "):sub(1, limit or 80) end
local function unitName(unit, fallback) local ok, n = pcall(UnitName, unit); return ok and safe(n, fallback) or fallback end
function Party:Initialize()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then C_ChatInfo.RegisterAddonMessagePrefix(self.prefix) elseif RegisterAddonMessagePrefix then RegisterAddonMessagePrefix(self.prefix) end
    self:RefreshRoster()
end
function Party:RefreshRoster()
    self.roster = { unitName("player", "Player") }; local base, count = IsInRaid() and "raid" or "party", IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, count do local name = unitName(base .. i); if name then self.roster[#self.roster + 1] = name end end; FEP:Emit("ROSTER_CHANGED")
end
function Party:SetAssignment(slot, player) if tonumber(slot) and slot >= 1 and slot <= 10 then FEP.db.assignments[slot] = sanitize(player); FEP:Emit("ASSIGNMENTS_CHANGED") end end
function Party:Send(payload, channel) if #payload > 240 then return false end; if C_ChatInfo and C_ChatInfo.SendAddonMessage then C_ChatInfo.SendAddonMessage(self.prefix, payload, channel) elseif SendAddonMessage then SendAddonMessage(self.prefix, payload, channel) else return false end return true end
function Party:BuildMessages(nonce)
    nonce = sanitize(nonce or tostring(time and time() or 0), 16); local out = { "B|2|" .. nonce .. "|" .. FEP.db.settings.slotCount }
    for i = 1, FEP.db.settings.slotCount do out[#out + 1] = table.concat({ "S", "2", nonce, i, sanitize(FEP.db.activeLoadout.slots[i], 120), sanitize(FEP.db.assignments[i], 80) }, "|") end
    out[#out + 1] = "E|2|" .. nonce; return out
end
function Party:Broadcast()
    if not IsInGroup() then FEP:Print("Not in a group. Use the copyable summary instead."); return false end
    local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or "PARTY")
    for _, payload in ipairs(self:BuildMessages()) do if not self:Send(payload, channel) then FEP:Print("Plan was not sent: message transport unavailable."); return false end end
    FEP:Print("Protocol v2 plan shared; manual summary remains available."); return true
end
function Party:OnMessage(prefix, message, _, sender)
    prefix, message, sender = safe(prefix), safe(message), safe(sender, "group member"); if prefix ~= self.prefix or not message or #message > 240 then return end
    local version, nonce, count = message:match("^B|(%d+)|([%w%-_]+)|(%d+)$")
    if version then count = tonumber(count); if tonumber(version) ~= self.protocol or (count ~= 3 and count ~= 5 and count ~= 10) then return end; self.receiving[sender] = { nonce = nonce, count = count, slots = {}, assignments = {} }; return end
    local slot, id, player; version, nonce, slot, id, player = message:match("^S|(%d+)|([%w%-_]+)|(%d+)|([^|]*)|([^|]*)$")
    local tx = self.receiving[sender]; slot = tonumber(slot)
    if version and tx and tonumber(version) == self.protocol and tx.nonce == nonce and slot and slot >= 1 and slot <= tx.count and (id == "" or FEP:GetCampObject(id)) then tx.slots[slot], tx.assignments[slot] = id ~= "" and id or nil, player ~= "" and sanitize(player) or nil; return end
    version, nonce = message:match("^E|(%d+)|([%w%-_]+)$"); tx = self.receiving[sender]
    if version and tx and tonumber(version) == self.protocol and tx.nonce == nonce then FEP.modules.Planner:SetSlotCount(tx.count); FEP.db.activeLoadout.slots, FEP.db.assignments = tx.slots, tx.assignments; self.receiving[sender] = nil; FEP:Emit("PLAN_CHANGED"); FEP:Emit("ASSIGNMENTS_CHANGED"); FEP:Print("Plan received from " .. sanitize(sender) .. ".") end
end
function Party:GetManualSummary()
    local lines = { "Forever Expedition Planner - " .. FEP.db.activeLoadout.name }
    for i = 1, FEP.db.settings.slotCount do local o = FEP:GetCampObject(FEP.db.activeLoadout.slots[i]); lines[#lines + 1] = i .. ". " .. (o and o.name or "Unassigned") .. " - " .. (FEP.db.assignments[i] or "Anyone") end
    local materials = {}; for _, row in ipairs(FEP.db.checklist.materials) do materials[#materials + 1] = row.label end
    if #materials > 0 then lines[#lines + 1] = "Materials: " .. table.concat(materials, ", ") end
    return table.concat(lines, "\n")
end
