local addonName, FEP = ...

FEP.name = addonName
FEP.version = "0.2.0-rc1"
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
    local raw = (input or ""):match("^%s*(.-)%s*$")
    input = raw:lower()
    if input == "options" then
        if FEP.OpenOptions then FEP:OpenOptions() end
    elseif input == "share" then
        FEP.modules.Party:Broadcast()
    elseif input == "status" then
        local count, blocker = FEP:GetDataStatus()
        FEP:Print(count .. " verified catalog records. " .. blocker)
        FEP:Print(FEP.modules.Integrations:Status())
        FEP:Print(FEP.modules.CampContext:GetDetectionStatus())
    elseif input == "camp" or input == "camp toggle" then
        local active = FEP.modules.CampContext:Toggle()
        FEP:Print("Manual camp context " .. (active and "enabled. The choice button is now available." or "disabled."))
    elseif input == "camp show" then
        FEP.db.campButton.visible = true; FEP.modules.CampContext:SetActive(true)
        FEP:Print("Camp button enabled; manual camp context active.")
    elseif input == "camp hide" then
        FEP.db.campButton.visible = false; FEP.modules.CampContext:SetActive(false)
        FEP:Print("Camp button hidden.")
    elseif input == "camp probe" then
        FEP:Print(FEP.modules.CampContext:Probe())
    elseif input == "camp status" then
        local object, reason = FEP.modules.CampContext:GetRecommendation()
        FEP:Print(FEP.modules.CampContext:GetDetectionStatus())
        FEP:Print((object and ("Choice: " .. object.name .. ". ") or "") .. reason)
    elseif input:match("^camp default%s+") then
        local id = raw:match("^[Cc][Aa][Mm][Pp]%s+[Dd][Ee][Ff][Aa][Uu][Ll][Tt]%s+(.+)$")
        local ok, err = FEP.modules.CampContext:SetDefault(id)
        FEP:Print(ok and ("Personal camp default set to " .. FEP:GetCampObject(id).name .. ".") or err)
    elseif input == "export" then
        FEP:Print(FEP.modules.Transfer:Export())
    elseif input == "help" then
        FEP:Print("/fep - open; /fep options; /fep share; /fep export; /fep status; /fep camp [toggle|show|hide|status|probe|default <id>]")
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
        FEP.modules.CampContext:Initialize()
        FEP.modules.Planner:Initialize()
        FEP.modules.Checklists:Initialize()
        FEP.modules.Party:Initialize()
        FEP.modules.Integrations:Initialize()
        -- Register with Esc > Options while the addon is loading. Forever's
        -- Settings category list may already be finalized by PLAYER_LOGIN.
        if FEP.RegisterOptions then
            local ok, err = pcall(FEP.RegisterOptions, FEP)
            if not ok then FEP:Print("Options registration failed: " .. tostring(err)) end
        end
        FEP:Emit("READY")
    elseif event == "PLAYER_LOGIN" then
        if FEP.CreateMainWindow then
            local ok, err = pcall(FEP.CreateMainWindow, FEP)
            if not ok then FEP:Print("Window creation failed: " .. tostring(err)) end
        end
        if FEP.CreateCampButton then
            local ok, err = pcall(FEP.CreateCampButton, FEP)
            if not ok then FEP:Print("Camp button creation failed: " .. tostring(err)) end
        end
        FEP:Print("Loaded. Type /fep to open or /fep help for commands. Configuration: Esc > Options > AddOns > Forever Expedition Planner.")
    elseif event == "GROUP_ROSTER_UPDATE" then
        FEP.modules.Party:RefreshRoster()
    elseif event == "CHAT_MSG_ADDON" then
        FEP.modules.Party:OnMessage(...)
    elseif event == "PLAYER_REGEN_DISABLED" then
        if FEP.MainFrame then FEP.MainFrame:Hide() end
    end
end)
