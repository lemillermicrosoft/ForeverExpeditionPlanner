local _, FEP = ...

local pages = {}
local tabs = {}
local selectedSlot = 1

local function showPage(name)
    for key, page in pairs(pages) do page:SetShown(key == name) end
    for key, tab in pairs(tabs) do
        tab:SetEnabled(key ~= name)
        tab:GetFontString():SetTextColor(key == name and 1 or 0.78, key == name and 0.77 or 0.54, key == name and 0.36 or 0.23)
    end
end

local function createPage(frame)
    local page = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    page:SetPoint("TOPLEFT", 14, -72)
    page:SetPoint("BOTTOMRIGHT", -14, 14)
    FEP.Theme:Panel(page)
    return page
end

local function createPlannerPage(frame)
    local page = createPage(frame)
    pages.Planner = page

    local search = FEP:CreateEditBox(page, 260, 28)
    search:SetPoint("TOPLEFT", 18, -18)
    search:SetText("Search camp objects...")
    search:SetTextColor(unpack(FEP.Theme.muted))
    local results = {}
    for i = 1, 10 do
        local row = FEP:CreateButton(page, "", 260, 27)
        row:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -5 - ((i - 1) * 29))
        row:GetFontString():SetJustifyH("LEFT")
        row:SetScript("OnClick", function(self)
            if self.objectID then FEP.modules.Planner:SetSlot(selectedSlot, self.objectID) end
        end)
        results[i] = row
    end
    local pending = FEP:CreateLabel(page, "Verified camp data pack pending.\nEnable Developer Mode in Options to preview sample fixtures.", "GameFontHighlight")
    pending:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 6, -14)
    pending:SetWidth(250)
    pending:SetJustifyH("LEFT")

    local slotRows = {}
    local function refresh()
        local query = search:GetText() or ""
        if query == "Search camp objects..." then query = "" end
        local objects = FEP:SearchCampObjects(query)
        pending:SetShown(#objects == 0)
        for i, row in ipairs(results) do
            local object = objects[i]
            row:SetShown(object ~= nil)
            row.objectID = object and object.id or nil
            if object then row:SetText("  " .. object.name .. "  |cFF9D8F78" .. object.category .. "|r") end
        end
        for i, row in ipairs(slotRows) do
            row:SetShown(i <= FEP.db.settings.slotCount)
            local object = FEP:GetCampObject(FEP.db.activeLoadout.slots[i])
            row:SetText((i == selectedSlot and "|cFFFFC45C▶ |r" or "  ") .. i .. ". " .. (object and object.name or "Empty slot"))
        end
        local warnings = FEP.modules.Planner:GetWarnings()
        page.warning:SetText(#warnings > 0 and ("|cFFFF6233Warning:|r " .. warnings[1].message) or "")
    end
    search:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "Search camp objects..." then self:SetText("") self:SetTextColor(1, 1, 1) end
    end)
    search:SetScript("OnTextChanged", refresh)

    local slotsTitle = FEP:CreateLabel(page, "CAMP LOADOUT", "GameFontNormalLarge")
    slotsTitle:SetPoint("TOPLEFT", 310, -20)
    for i = 1, 10 do
        local row = FEP:CreateButton(page, "", 310, 27)
        row:SetPoint("TOPLEFT", slotsTitle, "BOTTOMLEFT", 0, -8 - ((i - 1) * 29))
        row:GetFontString():SetJustifyH("LEFT")
        row:SetScript("OnClick", function() selectedSlot = i refresh() end)
        row:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then FEP.modules.Planner:SetSlot(i, nil) end
        end)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slotRows[i] = row
    end
    page.warning = FEP:CreateLabel(page, "", "GameFontHighlight")
    page.warning:SetPoint("BOTTOMLEFT", 310, 18)
    page.warning:SetWidth(310)
    page.warning:SetJustifyH("LEFT")
    FEP:On("PLAN_CHANGED", refresh)
    FEP:On("DATA_CHANGED", refresh)
    page.refresh = refresh
    return page
end

local function createPresetsPage(frame)
    local page = createPage(frame)
    pages.Presets = page
    local title = FEP:CreateLabel(page, "SAVED PRESETS", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    local name = FEP:CreateEditBox(page, 270, 28)
    name:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -14)
    name:SetText("Preset name")
    local save = FEP:CreateButton(page, "Save current", 130, 28)
    save:SetPoint("LEFT", name, "RIGHT", 12, 0)
    local rows = {}
    local function refresh()
        local names = {}
        for presetName in pairs(FEP.db.presets) do table.insert(names, presetName) end
        table.sort(names)
        for i, row in ipairs(rows) do
            local presetName = names[i]
            row:SetShown(presetName ~= nil)
            row.remove:SetShown(presetName ~= nil)
            row.presetName = presetName
            if presetName then row:SetText(presetName) end
        end
    end
    save:SetScript("OnClick", function()
        if FEP.modules.Planner:SavePreset(name:GetText()) then name:SetText("") refresh() end
    end)
    for i = 1, 12 do
        local row = FEP:CreateButton(page, "", 360, 28)
        row:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -12 - ((i - 1) * 30))
        row:SetScript("OnClick", function(self) FEP.modules.Planner:LoadPreset(self.presetName) end)
        local remove = FEP:CreateButton(page, "Delete", 80, 25)
        remove:SetPoint("LEFT", row, "RIGHT", 10, 0)
        remove:SetScript("OnClick", function() if row.presetName then FEP.modules.Planner:DeletePreset(row.presetName) end end)
        row.remove = remove
        rows[i] = row
    end
    FEP:On("PRESETS_CHANGED", refresh)
    page.refresh = refresh
    return page
end

local function createPartyPage(frame)
    local page = createPage(frame)
    pages.Party = page
    local title = FEP:CreateLabel(page, "WHO BRINGS WHAT", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    local note = FEP:CreateLabel(page, "Type a character name for each slot. Addon sharing is optional; the summary works for everyone.")
    note:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    local rows = {}
    for i = 1, 10 do
        local label = FEP:CreateLabel(page, "")
        label:SetPoint("TOPLEFT", note, "BOTTOMLEFT", 0, -16 - ((i - 1) * 30))
        label:SetWidth(270)
        label:SetJustifyH("LEFT")
        local box = FEP:CreateEditBox(page, 180, 26)
        box:SetPoint("LEFT", label, "RIGHT", 10, 0)
        box:SetScript("OnEnterPressed", function(self) FEP.modules.Party:SetAssignment(i, self:GetText()) self:ClearFocus() end)
        box:SetScript("OnEditFocusLost", function(self) FEP.modules.Party:SetAssignment(i, self:GetText()) end)
        rows[i] = { label = label, box = box }
    end
    local share = FEP:CreateButton(page, "Share with party", 150, 28)
    share:SetPoint("BOTTOMLEFT", 20, 20)
    share:SetScript("OnClick", function() FEP.modules.Party:Broadcast() end)
    local summary = FEP:CreateButton(page, "Manual summary", 150, 28)
    summary:SetPoint("LEFT", share, "RIGHT", 10, 0)
    summary:SetScript("OnClick", function()
        page.summaryBox:SetText(FEP.modules.Party:GetManualSummary())
        page.summaryBox:HighlightText()
        page.summaryBox:SetFocus()
    end)
    page.summaryBox = FEP:CreateEditBox(page, 260, 140, true)
    page.summaryBox:SetPoint("TOPRIGHT", -20, -60)
    page.summaryBox:SetText("Click Manual summary, then copy with Ctrl+C.")
    local function refresh()
        for i, row in ipairs(rows) do
            row.label:SetShown(i <= FEP.db.settings.slotCount)
            row.box:SetShown(i <= FEP.db.settings.slotCount)
            local object = FEP:GetCampObject(FEP.db.activeLoadout.slots[i])
            row.label:SetText(i .. ". " .. (object and object.name or "Empty slot"))
            if not row.box:HasFocus() then row.box:SetText(FEP.db.assignments[i] or "") end
        end
    end
    FEP:On("PLAN_CHANGED", refresh)
    FEP:On("ASSIGNMENTS_CHANGED", refresh)
    page.refresh = refresh
    return page
end

local function createChecklistPage(frame)
    local page = createPage(frame)
    pages.Checklists = page
    local materials = FEP:CreateLabel(page, "MATERIALS", "GameFontNormalLarge")
    materials:SetPoint("TOPLEFT", 20, -20)
    local readiness = FEP:CreateLabel(page, "DUNGEON READINESS", "GameFontNormalLarge")
    readiness:SetPoint("TOPLEFT", 340, -20)
    local materialRows, readyRows = {}, {}
    for i = 1, 12 do
        local left = FEP:CreateCheckRow(page, 280)
        left:SetPoint("TOPLEFT", materials, "BOTTOMLEFT", 0, -10 - ((i - 1) * 26))
        left:SetScript("OnClick", function() FEP.modules.Checklists:Toggle("materials", i) end)
        materialRows[i] = left
        local right = FEP:CreateCheckRow(page, 280)
        right:SetPoint("TOPLEFT", readiness, "BOTTOMLEFT", 0, -10 - ((i - 1) * 26))
        right:SetScript("OnClick", function() FEP.modules.Checklists:Toggle("readiness", i) end)
        readyRows[i] = right
    end
    local function fill(rows, data)
        for i, row in ipairs(rows) do
            local item = data[i]
            row:SetShown(item ~= nil)
            if item then row.label:SetText(item.label) row.check:SetShown(item.checked) end
        end
    end
    local function refresh()
        fill(materialRows, FEP.db.checklist.materials)
        fill(readyRows, FEP.db.checklist.readiness)
    end
    FEP:On("CHECKLIST_CHANGED", refresh)
    page.refresh = refresh
    return page
end

function FEP:CreateMainWindow()
    if self.MainFrame then return end
    local frame = CreateFrame("Frame", "ForeverExpeditionPlannerFrame", UIParent, "BackdropTemplate")
    frame:SetSize(700, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    self.Theme:Panel(frame)
    table.insert(UISpecialFrames, frame:GetName())
    self.MainFrame = frame

    local title = self:CreateLabel(frame, "FOREVER EXPEDITION PLANNER", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetTextColor(unpack(self.Theme.bronzeBright))
    local version = self:CreateLabel(frame, self.version, "GameFontDisableSmall")
    version:SetPoint("LEFT", title, "RIGHT", 9, -2)
    local close = self:CreateButton(frame, "×", 28, 28)
    close:SetPoint("TOPRIGHT", -12, -10)
    close:SetScript("OnClick", function() frame:Hide() end)

    local tabNames = { "Planner", "Presets", "Party", "Checklists" }
    for index, name in ipairs(tabNames) do
        local tab = self:CreateButton(frame, name, 120, 25)
        tab:SetPoint("TOPLEFT", 16 + ((index - 1) * 124), -43)
        tab:SetScript("OnClick", function() showPage(name) if pages[name].refresh then pages[name].refresh() end end)
        tabs[name] = tab
    end
    createPlannerPage(frame)
    createPresetsPage(frame)
    createPartyPage(frame)
    createChecklistPage(frame)
    showPage("Planner")
    frame:SetScript("OnShow", function()
        for _, page in pairs(pages) do if page.refresh then page.refresh() end end
    end)
    frame:Hide()
end
