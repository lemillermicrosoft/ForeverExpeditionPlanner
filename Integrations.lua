local _, FEP = ...
local Integrations = {}
FEP:RegisterModule("Integrations", Integrations)

function Integrations:Initialize()
    self.tomtom = type(TomTom) == "table" and type(TomTom.AddWaypoint) == "function"
    self.auctionator = type(Auctionator) == "table" or (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Auctionator")) or (IsAddOnLoaded and IsAddOnLoaded("Auctionator"))
end
function Integrations:AddWaypoint(mapID, x, y, title)
    if not self.tomtom or type(mapID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then return false end
    local ok = pcall(TomTom.AddWaypoint, TomTom, mapID, x, y, { title = tostring(title or "Expedition destination"), persistent = false })
    return ok
end
function Integrations:OpenShoppingList()
    if not self.auctionator then return false, "Auctionator is not installed." end
    if Auctionator and Auctionator.Shopping and type(Auctionator.Shopping.Show) == "function" then return pcall(Auctionator.Shopping.Show) end
    return false, "Auctionator detected; use its Shopping tab and the copyable materials summary."
end
function Integrations:Status()
    return "TomTom: " .. (self.tomtom and "ready" or "not installed") .. "; Auctionator: " .. (self.auctionator and "detected" or "not installed")
end
