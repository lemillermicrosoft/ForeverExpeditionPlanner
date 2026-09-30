local _, FEP = ...

local BRONZE = { 0.78, 0.54, 0.23 }
local GOLD = { 1.00, 0.82, 0.20 }
local MUTED = { 0.72, 0.68, 0.60 }

local function setCheckText(checkButton, text)
    local label = checkButton.Text or (checkButton:GetName() and _G[checkButton:GetName() .. "Text"])
    if label then
        label:SetText(text)
        label:SetTextColor(0.95, 0.90, 0.78)
    end
end

local function createCard(parent, top, height)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", 18, top)
    card:SetPoint("TOPRIGHT", -18, top)
    card:SetHeight(height)
    card:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    card:SetBackdropColor(0.055, 0.040, 0.025, 0.94)
    card:SetBackdropBorderColor(BRONZE[1], BRONZE[2], BRONZE[3], 0.82)
    return card
end

local function createSectionTitle(parent, text)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -13)
    title:SetText(text)
    title:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    return title
end

local function createDescription(parent, anchor, text)
    local description = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5)
    description:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    description:SetJustifyH("LEFT")
    description:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
    description:SetText(text)
    return description
end

local function createCheckbox(parent, label, description, anchor, getter, setter)
    local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -4, -12)
    setCheckText(box, label)
    box.tooltipText = label
    box.tooltipRequirement = description
    box:SetScript("OnShow", function(self) self:SetChecked(getter()) end)
    box:SetScript("OnClick", function(self) setter(self:GetChecked() == true) end)

    local detail = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    detail:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 28, 2)
    detail:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
    detail:SetText(description)
    return box, detail
end

local function createNativeButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 26)
    button:SetText(text)
    return button
end

function FEP:RegisterOptions()
    if self.OptionsPanel then return end

    local panel = CreateFrame("Frame", "ForeverExpeditionPlannerOptions", UIParent)
    panel.name = "Forever Expedition Planner"
    self.OptionsPanel = panel

    local pageBackground = panel:CreateTexture(nil, "BACKGROUND")
    pageBackground:SetAllPoints(panel)
    pageBackground:SetColorTexture(0.025, 0.018, 0.012, 0.72)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("Forever Expedition Planner")
    title:SetTextColor(GOLD[1], GOLD[2], GOLD[3])

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -7)
    subtitle:SetText("Prepare camp loadouts, party assignments, and expedition checklists.")
    subtitle:SetTextColor(0.84, 0.80, 0.72)

    local loadoutCard = createCard(panel, -72, 125)
    local loadoutTitle = createSectionTitle(loadoutCard, "Camp Loadout")
    local loadoutDescription = createDescription(loadoutCard, loadoutTitle,
        "Choose the number of camp-object slots available in the expedition plan.")

    local slotButtons = {}
    local previous
    for _, count in ipairs({ 3, 5, 10 }) do
        local slotCount = count
        local radio = CreateFrame("CheckButton", nil, loadoutCard, "UIRadioButtonTemplate")
        if previous then
            radio:SetPoint("LEFT", previous, "RIGHT", 88, 0)
        else
            radio:SetPoint("TOPLEFT", loadoutDescription, "BOTTOMLEFT", -4, -13)
        end
        setCheckText(radio, tostring(slotCount) .. " slots")
        radio:SetScript("OnClick", function()
            FEP.modules.Planner:SetSlotCount(slotCount)
            for value, other in pairs(slotButtons) do other:SetChecked(value == slotCount) end
        end)
        slotButtons[slotCount] = radio
        previous = radio
    end

    local behaviorCard = createCard(panel, -211, 197)
    local behaviorTitle = createSectionTitle(behaviorCard, "Behavior")
    local behaviorDescription = createDescription(behaviorCard, behaviorTitle,
        "Control test data and how plans are shared. Changes save immediately.")

    local developer, developerDetail = createCheckbox(behaviorCard,
        "Developer Mode",
        "Loads clearly labeled sample fixtures for UI testing; these are not game data.",
        behaviorDescription,
        function() return FEP.db.settings.developerMode end,
        function(value)
            FEP.db.settings.developerMode = value
            if value then
                FEP:LoadDeveloperFixtures()
            else
                FEP.Data.objects, FEP.Data.byID, FEP.Data.providers = {}, {}, {}
                FEP.db.activeLoadout.slots = {}
                FEP:Emit("DATA_CHANGED")
            end
        end)

    local autoShare = CreateFrame("CheckButton", nil, behaviorCard, "UICheckButtonTemplate")
    autoShare:SetPoint("TOPLEFT", developerDetail, "BOTTOMLEFT", -28, -11)
    setCheckText(autoShare, "Automatically share plan changes")
    autoShare.tooltipText = "Automatically share plan changes"
    autoShare.tooltipRequirement = "Reserved for a future release and currently produces no chat or addon traffic."
    autoShare:SetScript("OnShow", function(self) self:SetChecked(FEP.db.settings.autoShare) end)
    autoShare:SetScript("OnClick", function(self) FEP.db.settings.autoShare = self:GetChecked() == true end)

    local shareDetail = behaviorCard:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    shareDetail:SetPoint("TOPLEFT", autoShare, "BOTTOMLEFT", 28, 2)
    shareDetail:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
    shareDetail:SetText("Reserved for a future release; disabled behavior in this alpha.")

    local actionsCard = createCard(panel, -422, 79)
    local actionsTitle = createSectionTitle(actionsCard, "Actions")
    local open = createNativeButton(actionsCard, "Open Planner", 140)
    open:SetPoint("TOPLEFT", actionsTitle, "BOTTOMLEFT", 0, -10)
    open:SetScript("OnClick", function() FEP:Toggle() end)

    local resetPosition = createNativeButton(actionsCard, "Reset Window Position", 180)
    resetPosition:SetPoint("LEFT", open, "RIGHT", 10, 0)
    resetPosition:SetScript("OnClick", function()
        FEP.db.windowPosition.x, FEP.db.windowPosition.y = 0, 0
        if FEP.MainFrame then
            FEP.MainFrame:ClearAllPoints()
            FEP.MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        FEP:Print("Window position reset.")
    end)

    panel:SetScript("OnShow", function()
        for value, radio in pairs(slotButtons) do
            radio:SetChecked(value == FEP.db.settings.slotCount)
        end
        developer:SetChecked(FEP.db.settings.developerMode)
        autoShare:SetChecked(FEP.db.settings.autoShare)
    end)

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
        registered = pcall(InterfaceOptions_AddCategory, panel)
    end
    if not registered then
        self:Print("Could not register the AddOns options category; use /fep options and report this client build.")
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
