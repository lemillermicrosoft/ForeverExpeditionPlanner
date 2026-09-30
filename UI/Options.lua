local _, FEP = ...

local function addCheckbox(panel, label, description, y, getter, setter)
    local box = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    box:SetPoint("TOPLEFT", 20, y)
    box.Text:SetText(label)
    box.tooltipText = label
    box.tooltipRequirement = description
    box:SetScript("OnShow", function(self) self:SetChecked(getter()) end)
    box:SetScript("OnClick", function(self) setter(self:GetChecked()) end)
    return box
end

function FEP:RegisterOptions()
    local panel = CreateFrame("Frame", "ForeverExpeditionPlannerOptions")
    panel.name = "Forever Expedition Planner"
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Forever Expedition Planner")
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Out-of-combat expedition preparation. Changes save immediately.")

    local slotsLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    slotsLabel:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -28)
    slotsLabel:SetText("Camp loadout slots")
    local slotButtons = {}
    for index, count in ipairs({ 3, 5, 10 }) do
        local buttonIndex, slotCount = index, count
        local button = FEP:CreateButton(panel, tostring(slotCount), 58, 25)
        button:SetPoint("TOPLEFT", slotsLabel, "BOTTOMLEFT", (buttonIndex - 1) * 64, -8)
        button:SetScript("OnClick", function()
            FEP.modules.Planner:SetSlotCount(slotCount)
            for value, other in pairs(slotButtons) do other:SetEnabled(value ~= slotCount) end
        end)
        slotButtons[slotCount] = button
    end
    panel:SetScript("OnShow", function()
        for value, button in pairs(slotButtons) do button:SetEnabled(value ~= FEP.db.settings.slotCount) end
    end)

    addCheckbox(panel, "Developer Mode", "Loads clearly labeled sample fixtures for UI testing. These are not game data.", -155,
        function() return FEP.db.settings.developerMode end,
        function(value)
            FEP.db.settings.developerMode = value and true or false
            if value then FEP:LoadDeveloperFixtures() else
                FEP.Data.objects, FEP.Data.byID, FEP.Data.providers = {}, {}, {}
                FEP.db.activeLoadout.slots = {}
                FEP:Emit("DATA_CHANGED")
            end
        end)
    addCheckbox(panel, "Automatically share after plan changes", "Reserved preference; disabled in this alpha to avoid chat noise.", -190,
        function() return FEP.db.settings.autoShare end,
        function(value) FEP.db.settings.autoShare = value and true or false end)

    local open = FEP:CreateButton(panel, "Open Planner", 140, 28)
    open:SetPoint("TOPLEFT", 20, -245)
    open:SetScript("OnClick", function() FEP:Toggle() end)
    local resetPosition = FEP:CreateButton(panel, "Reset window position", 170, 28)
    resetPosition:SetPoint("LEFT", open, "RIGHT", 10, 0)
    resetPosition:SetScript("OnClick", function()
        FEP.db.windowPosition.x, FEP.db.windowPosition.y = 0, 0
        if FEP.MainFrame then
            FEP.MainFrame:ClearAllPoints()
            FEP.MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
    end)
    FEP.OptionsPanel = panel

    local registered = false
    if Settings and type(Settings.RegisterCanvasLayoutCategory) == "function" and type(Settings.RegisterAddOnCategory) == "function" then
        local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, panel.name)
        if ok and category then
            local added = pcall(Settings.RegisterAddOnCategory, category)
            if added then
                registered = true
                if type(category.GetID) == "function" then
                    local idOK, categoryID = pcall(category.GetID, category)
                    if idOK then FEP.OptionsCategoryID = categoryID end
                end
            end
        end
    end
    if not registered and type(InterfaceOptions_AddCategory) == "function" then
        pcall(InterfaceOptions_AddCategory, panel)
    end
end

function FEP:OpenOptions()
    if Settings and type(Settings.OpenToCategory) == "function" and self.OptionsCategoryID then
        local ok = pcall(Settings.OpenToCategory, self.OptionsCategoryID)
        if ok then return end
    end
    if type(InterfaceOptionsFrame_OpenToCategory) == "function" and self.OptionsPanel then
        pcall(InterfaceOptionsFrame_OpenToCategory, self.OptionsPanel)
        pcall(InterfaceOptionsFrame_OpenToCategory, self.OptionsPanel)
    else
        self:Print("Open Esc > Options > AddOns > Forever Expedition Planner.")
    end
end
