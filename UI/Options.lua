local _, FEP = ...

local function checkLabel(button)
    local label = button.Text or (button:GetName() and _G[button:GetName() .. "Text"])
    if not label then
        -- Forever's radio template renders the control but does not expose the
        -- usual .Text region. Own the label so every choice remains readable.
        label = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("LEFT", button, "RIGHT", 4, 0)
        label:SetJustifyH("LEFT")
        button.FEPText = label
    end
    return label
end

local function setCheckText(button, text, width)
    local label = checkLabel(button)
    label:SetText(text)
    label:SetWidth(width or 145)
    FEP.Theme:Register(label, "text")
end

local function createCard(parent, top, height)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", 18, top); card:SetPoint("TOPRIGHT", -18, top); card:SetHeight(height)
    FEP.Theme:Panel(card, "card")
    return card
end

local function createSectionTitle(parent, text)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -12); title:SetText(text); FEP.Theme:Register(title, "title")
    return title
end

local function createDescription(parent, anchor, text)
    local description = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4); description:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    description:SetJustifyH("LEFT"); description:SetText(text); FEP.Theme:Register(description, "muted")
    return description
end

local function createCheckbox(parent, label, description, anchor, getter, setter)
    local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -4, -10); setCheckText(box, label)
    box.tooltipText, box.tooltipRequirement = label, description
    box:SetScript("OnShow", function(self) self:SetChecked(getter()) end)
    box:SetScript("OnClick", function(self) setter(self:GetChecked() == true) end)
    local detail = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    detail:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 28, 2); detail:SetText(description); FEP.Theme:Register(detail, "muted")
    return box, detail
end

local function createNativeButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 26); button:SetText(text); FEP.Theme:Button(button)
    return button
end

function FEP:RegisterOptions()
    if self.OptionsPanel then return end
    local panel = CreateFrame("Frame", "ForeverExpeditionPlannerOptions", UIParent)
    panel.name = "Forever Expedition Planner"; self.OptionsPanel = panel

    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(panel); self.Theme:Register(background, "optionsBackground")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -16); title:SetText("Forever Expedition Planner"); self.Theme:Register(title, "title")
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -5)
    subtitle:SetText("Prepare camp loadouts, party assignments, and expedition checklists."); self.Theme:Register(subtitle, "muted")

    local appearanceCard = createCard(panel, -66, 100)
    local appearanceTitle = createSectionTitle(appearanceCard, "Appearance")
    local appearanceDescription = createDescription(appearanceCard, appearanceTitle, "Switch instantly between the game-native interface and the original bronze design.")
    local appearanceButtons = {}
    local previous
    for _, entry in ipairs({ { "blizzard", "Blizzard / native" }, { "bronze", "Bronze / custom" } }) do
        local value, label = entry[1], entry[2]
        local radio = CreateFrame("CheckButton", nil, appearanceCard, "UIRadioButtonTemplate")
        if previous then radio:SetPoint("LEFT", previous, "RIGHT", 125, 0) else radio:SetPoint("TOPLEFT", appearanceDescription, "BOTTOMLEFT", -4, -9) end
        setCheckText(radio, label)
        radio:SetScript("OnClick", function()
            FEP:SetAppearance(value)
            for key, other in pairs(appearanceButtons) do other:SetChecked(key == value) end
        end)
        appearanceButtons[value] = radio; previous = radio
    end

    local loadoutCard = createCard(panel, -176, 104)
    local loadoutTitle = createSectionTitle(loadoutCard, "Camp Loadout")
    local loadoutDescription = createDescription(loadoutCard, loadoutTitle, "Choose how many camp-object slots are available. Unverified slots remain Unassigned.")
    local slotButtons, prior = {}, nil
    for _, count in ipairs({ 3, 5, 10 }) do
        local slotCount = count
        local radio = CreateFrame("CheckButton", nil, loadoutCard, "UIRadioButtonTemplate")
        if prior then radio:SetPoint("LEFT", prior, "RIGHT", 88, 0) else radio:SetPoint("TOPLEFT", loadoutDescription, "BOTTOMLEFT", -4, -9) end
        setCheckText(radio, tostring(slotCount) .. " slots")
        radio:SetScript("OnClick", function()
            FEP.modules.Planner:SetSlotCount(slotCount)
            for value, other in pairs(slotButtons) do other:SetChecked(value == slotCount) end
        end)
        slotButtons[slotCount] = radio; prior = radio
    end

    local behaviorCard = createCard(panel, -290, 181)
    local behaviorTitle = createSectionTitle(behaviorCard, "Behavior")
    local behaviorDescription = createDescription(behaviorCard, behaviorTitle, "Control test data and plan sharing. Changes save immediately.")
    local developer, developerDetail = createCheckbox(behaviorCard, "Developer Mode",
        "Loads labeled sample fixtures for UI testing; these are not game data.", behaviorDescription,
        function() return FEP.db.settings.developerMode end,
        function(value)
            FEP.db.settings.developerMode = value
            if value then FEP:LoadDeveloperFixtures() else
                FEP.Data.objects, FEP.Data.byID, FEP.Data.providers = {}, {}, {}
                FEP.db.activeLoadout.slots = {}; FEP:Emit("DATA_CHANGED"); FEP:Emit("PLAN_CHANGED")
            end
        end)
    local autoShare = CreateFrame("CheckButton", nil, behaviorCard, "UICheckButtonTemplate")
    autoShare:SetPoint("TOPLEFT", developerDetail, "BOTTOMLEFT", -28, -9); setCheckText(autoShare, "Automatically share plan changes")
    autoShare.tooltipText = "Automatically share plan changes"
    autoShare.tooltipRequirement = "Reserved for a future release and currently produces no traffic."
    autoShare:SetScript("OnClick", function(self) FEP.db.settings.autoShare = self:GetChecked() == true end)
    local shareDetail = behaviorCard:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    shareDetail:SetPoint("TOPLEFT", autoShare, "BOTTOMLEFT", 28, 2); shareDetail:SetText("Reserved for a future release; disabled behavior in this alpha.")
    self.Theme:Register(shareDetail, "muted")

    local actionsCard = createCard(panel, -481, 70)
    local actionsTitle = createSectionTitle(actionsCard, "Actions")
    local open = createNativeButton(actionsCard, "Open Planner", 150)
    open:SetPoint("TOPLEFT", actionsTitle, "BOTTOMLEFT", 0, -8); open:SetScript("OnClick", function() FEP:Toggle() end)
    local resetPosition = createNativeButton(actionsCard, "Reset Window Position", 205)
    resetPosition:SetPoint("TOPLEFT", actionsTitle, "BOTTOMLEFT", 168, -8)
    resetPosition:SetScript("OnClick", function()
        FEP.db.windowPosition.x, FEP.db.windowPosition.y = 0, 0
        if FEP.MainFrame then FEP.MainFrame:ClearAllPoints(); FEP.MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) end
        FEP:Print("Window position reset.")
    end)

    panel:SetScript("OnShow", function()
        for value, radio in pairs(appearanceButtons) do radio:SetChecked(value == FEP.db.settings.appearance) end
        for value, radio in pairs(slotButtons) do radio:SetChecked(value == FEP.db.settings.slotCount) end
        developer:SetChecked(FEP.db.settings.developerMode); autoShare:SetChecked(FEP.db.settings.autoShare)
    end)

    local registered = false
    if Settings and type(Settings.RegisterCanvasLayoutCategory) == "function" and type(Settings.RegisterAddOnCategory) == "function" then
        local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, panel.name)
        if ok and category then
            local added = pcall(Settings.RegisterAddOnCategory, category)
            if added then
                registered = true
                if type(category.GetID) == "function" then
                    local idOK, id = pcall(category.GetID, category); if idOK then FEP.OptionsCategoryID = id end
                end
            end
        end
    end
    if not registered and type(InterfaceOptions_AddCategory) == "function" then registered = pcall(InterfaceOptions_AddCategory, panel) end
    if not registered then self:Print("Could not register the AddOns options category; use /fep options and report this client build.") end
end

function FEP:OpenOptions()
    if Settings and type(Settings.OpenToCategory) == "function" and self.OptionsCategoryID then
        local ok = pcall(Settings.OpenToCategory, self.OptionsCategoryID); if ok then return end
    end
    if type(InterfaceOptionsFrame_OpenToCategory) == "function" and self.OptionsPanel then
        pcall(InterfaceOptionsFrame_OpenToCategory, self.OptionsPanel); pcall(InterfaceOptionsFrame_OpenToCategory, self.OptionsPanel)
    else self:Print("Open Esc > Options > AddOns > Forever Expedition Planner.") end
end
