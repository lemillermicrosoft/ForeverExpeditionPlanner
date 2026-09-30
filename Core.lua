local addonName, FEP = ...

FEP.name = addonName
FEP.version = "0.1.0-alpha"
FEP.modules = {}
FEP.callbacks = {}

function FEP:RegisterModule(name, module)
    self.modules[name] = module
end

function FEP:On(event, callback)
    if not self.callbacks[event] then self.callbacks[event] = {} end
    table.insert(self.callbacks[event], callback)
end

function FEP:Emit(event, ...)
    local list = self.callbacks[event]
    if not list then return end
    for _, callback in ipairs(list) do
        local ok, err = pcall(callback, ...)
        if not ok then self:Print("Error: " .. tostring(err)) end
    end
end

function FEP:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFC68A3A[FEP]|r " .. tostring(message))
end

function FEP:Toggle()
    if not self.MainFrame then return end
    if InCombatLockdown and InCombatLockdown() then
        self:Print("The planner is available after combat.")
        return
    end
    if self.MainFrame:IsShown() then self.MainFrame:Hide() else self.MainFrame:Show() end
end

SLASH_FOREVEREXPEDITIONPLANNER1 = "/fep"
SLASH_FOREVEREXPEDITIONPLANNER2 = "/expeditionplanner"
SlashCmdList.FOREVEREXPEDITIONPLANNER = function(input)
    input = (input or ""):lower():match("^%s*(.-)%s*$")
    if input == "options" then
        if FEP.OpenOptions then FEP:OpenOptions() end
    elseif input == "share" then
        FEP.modules.Party:Broadcast()
    elseif input == "help" then
        FEP:Print("/fep - open planner; /fep options; /fep share")
    else
        FEP:Toggle()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("GROUP_ROSTER_UPDATE")
events:RegisterEvent("CHAT_MSG_ADDON")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded ~= addonName then return end
        FEP.modules.Database:Initialize()
        FEP.modules.Planner:Initialize()
        FEP.modules.Checklists:Initialize()
        FEP.modules.Party:Initialize()
        FEP:Emit("READY")
    elseif event == "PLAYER_LOGIN" then
        if FEP.CreateMainWindow then FEP:CreateMainWindow() end
        if FEP.RegisterOptions then FEP:RegisterOptions() end
    elseif event == "GROUP_ROSTER_UPDATE" then
        FEP.modules.Party:RefreshRoster()
    elseif event == "CHAT_MSG_ADDON" then
        FEP.modules.Party:OnMessage(...)
    elseif event == "PLAYER_REGEN_DISABLED" then
        if FEP.MainFrame then FEP.MainFrame:Hide() end
    end
end)
