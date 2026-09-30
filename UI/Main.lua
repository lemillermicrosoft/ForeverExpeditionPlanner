local _, FEP = ...

local pages = {}
local tabs = {}
local selectedSlot = 1
local selectedPage = "Planner"

local function showPage(name)
    selectedPage = name
    for key, page in pairs(pages) do page:SetShown(key == name) end
    for key, tab in pairs(tabs) do
        tab:SetEnabled(key ~= name)
        if FEP.Theme:IsBronze() then
            tab:GetFontString():SetTextColor(key == name and 1 or 0.78, key == name and 0.77 or 0.54, key == name and 0.36 or 0.23)
        else
            tab:GetFontString():SetTextColor(key == name and 1 or 0.82, key == name and 1 or 0.82, key == name and 1 or 0)
        end
    end
end

local function createPage(frame)
    local page = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    page:SetPoint("TOPLEFT", 14, -72)
    page:SetPoint("BOTTOMRIGHT", -14, 14)
    FEP.Theme:Panel(page, "panel")
    return page
end

local function createPlannerPage(frame)
    local page = createPage(frame)
    pages.Planner = page

    local search = FEP:CreateEditBox(page, 260, 28)
    search:SetPoint("TOPLEFT", 18, -18)
    search:SetText("Search camp objects...")
    local function styleSearchPlaceholder()
        if search:GetText() == "Search camp objects..." then
            if FEP.Theme:IsBronze() then search:SetTextColor(unpack(FEP.Theme.muted)) else search:SetTextColor(0.60, 0.60, 0.60) end
        end
    end
    styleSearchPlaceholder()
    FEP:On("APPEARANCE_CHANGED", styleSearchPlaceholder)
    local results = {}
    for i = 1, 10 do
        local row = FEP:CreateButton(page, "", 260, 27)
        row:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -5 - ((i - 1) * 29))
        row:GetFontString():SetJustifyH("LEFT")
        row:SetScript("OnClick", function(self)
            if self.objectID then FEP.modules.Planner:SetSlot(selectedSlot, self.objectID) end
        end)
        row:SetScript("OnEnter", function(self)
            local object = FEP:GetCampObject(self.objectID); if not object then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if object.itemID and GameTooltip.SetItemByID then GameTooltip:SetItemByID(object.itemID) else
                GameTooltip:SetText(object.name); GameTooltip:AddLine(object.description, 1, 1, 1, true)
                GameTooltip:AddLine("Source: " .. object.verification.source .. " (" .. object.verification.status .. ")", 0.7, 0.7, 0.7, true)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        results[i] = row
    end
    local pending = FEP:CreateLabel(page, "Start by choosing a slot on the right. Verified camp-object data is not bundled yet, so slots stay Unassigned.\n\nEnable Developer Mode in Options only to preview clearly labeled sample fixtures.", "GameFontHighlight")
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
            row:SetText((i == selectedSlot and "|cFFFFC45C▶ |r" or "  ") .. i .. ". " .. (object and object.name or "Unassigned"))
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
        local slotIndex = i
        local row = FEP:CreateButton(page, "", 310, 27)
        row:SetPoint("TOPLEFT", slotsTitle, "BOTTOMLEFT", 0, -8 - ((slotIndex - 1) * 29))
        row:GetFontString():SetJustifyH("LEFT")
        row:SetScript("OnClick", function() selectedSlot = slotIndex refresh() end)
        row:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then FEP.modules.Planner:SetSlot(slotIndex, nil) end
        end)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slotRows[slotIndex] = row
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
    local guidance = FEP:CreateLabel(page, "Starter plans are generic and leave camp slots Unassigned until verified data is available.", "GameFontHighlightSmall")
    guidance:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    FEP.Theme:Register(guidance, "muted")
    local name = FEP:CreateEditBox(page, 270, 28)
    name:SetPoint("TOPLEFT", guidance, "BOTTOMLEFT", 0, -10)
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
        local rowIndex = i
        local row = FEP:CreateButton(page, "", 360, 28)
        row:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -12 - ((rowIndex - 1) * 30))
        row:SetScript("OnClick", function() FEP.modules.Planner:LoadPreset(rows[rowIndex].presetName) end)
        local remove = FEP:CreateButton(page, "Delete", 80, 25)
        remove:SetPoint("LEFT", row, "RIGHT", 10, 0)
        remove:SetScript("OnClick", function()
            local presetName = rows[rowIndex].presetName
            if presetName then FEP.modules.Planner:DeletePreset(presetName) end
        end)
        row.remove = remove
        rows[rowIndex] = row
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
        local rowIndex = i
        local label = FEP:CreateLabel(page, "")
        label:SetPoint("TOPLEFT", note, "BOTTOMLEFT", 0, -16 - ((rowIndex - 1) * 30))
        label:SetWidth(270)
        label:SetJustifyH("LEFT")
        local box = FEP:CreateEditBox(page, 180, 26)
        box:SetPoint("LEFT", label, "RIGHT", 10, 0)
        box:SetScript("OnEnterPressed", function(self) FEP.modules.Party:SetAssignment(rowIndex, self:GetText()) self:ClearFocus() end)
        box:SetScript("OnEditFocusLost", function(self) FEP.modules.Party:SetAssignment(rowIndex, self:GetText()) end)
        rows[rowIndex] = { label = label, box = box }
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
            row.label:SetText(i .. ". " .. (object and object.name or "Unassigned"))
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
    local readiness = FEP:CreateLabel(page, "READINESS", "GameFontNormalLarge")
    readiness:SetPoint("TOPLEFT", 340, -20)
    local dungeonPreset = FEP:CreateButton(page, "Dungeon", 82, 23)
    dungeonPreset:SetPoint("LEFT", readiness, "RIGHT", 8, 0)
    dungeonPreset:SetScript("OnClick", function() FEP.modules.Database:SetReadinessPreset("Dungeon") end)
    local travelPreset = FEP:CreateButton(page, "Travel", 72, 23)
    travelPreset:SetPoint("LEFT", dungeonPreset, "RIGHT", 6, 0)
    travelPreset:SetScript("OnClick", function() FEP.modules.Database:SetReadinessPreset("Travel") end)
    local materialHint = FEP:CreateLabel(page, "Materials appear here after verified camp objects are assigned.", "GameFontHighlightSmall")
    materialHint:SetPoint("TOPLEFT", materials, "BOTTOMLEFT", 0, -12)
    materialHint:SetWidth(270)
    materialHint:SetJustifyH("LEFT")
    FEP.Theme:Register(materialHint, "muted")
    local materialRows, readyRows = {}, {}
    for i = 1, 12 do
        local rowIndex = i
        local left = FEP:CreateCheckRow(page, 280)
        left:SetPoint("TOPLEFT", materials, "BOTTOMLEFT", 0, -10 - ((rowIndex - 1) * 26))
        left:SetScript("OnClick", function() FEP.modules.Checklists:Toggle("materials", rowIndex) end)
        materialRows[rowIndex] = left
        local right = FEP:CreateCheckRow(page, 280)
        right:SetPoint("TOPLEFT", readiness, "BOTTOMLEFT", 0, -10 - ((rowIndex - 1) * 26))
        right:SetScript("OnClick", function() FEP.modules.Checklists:Toggle("readiness", rowIndex) end)
        readyRows[rowIndex] = right
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
        materialHint:SetShown(#FEP.db.checklist.materials == 0)
    end
    FEP:On("CHECKLIST_CHANGED", refresh)
    page.refresh = refresh
    return page
end

local function createTransferPage(frame)
    local page = createPage(frame)
    pages.Transfer = page
    local title = FEP:CreateLabel(page, "IMPORT / EXPORT", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    local note = FEP:CreateLabel(page, "Schema FEPX1 is text-only, bounded, and never executes imported code. Unknown catalog IDs are rejected.")
    note:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8); note:SetWidth(620); note:SetJustifyH("LEFT")
    local box = FEP:CreateEditBox(page, 620, 250, true)
    box:SetPoint("TOPLEFT", note, "BOTTOMLEFT", 0, -14)
    local export = FEP:CreateButton(page, "Export current", 145, 28)
    export:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -14)
    export:SetScript("OnClick", function() box:SetText(FEP.modules.Transfer:Export()); box:HighlightText(); box:SetFocus() end)
    local import = FEP:CreateButton(page, "Import", 110, 28)
    import:SetPoint("LEFT", export, "RIGHT", 10, 0)
    local status = FEP:CreateLabel(page, "", "GameFontHighlight")
    status:SetPoint("LEFT", import, "RIGHT", 12, 0); status:SetWidth(330); status:SetJustifyH("LEFT")
    import:SetScript("OnClick", function() local ok, err = FEP.modules.Transfer:Import(box:GetText()); status:SetText(ok and "|cFF66DD66Imported safely.|r" or ("|cFFFF6655" .. tostring(err) .. "|r")) end)
    local dataset = FEP:CreateLabel(page, "", "GameFontHighlightSmall")
    dataset:SetPoint("TOPLEFT", export, "BOTTOMLEFT", 0, -22); dataset:SetWidth(620); dataset:SetJustifyH("LEFT")
    page.refresh = function() local count, blocker = FEP:GetDataStatus(); dataset:SetText("Verified catalog coverage: " .. count .. " records. " .. blocker) end
    return page
end

function FEP:CreateMainWindow()
    if self.MainFrame then return end
    local frame = CreateFrame("Frame", "ForeverExpeditionPlannerFrame", UIParent, "BackdropTemplate")
    frame:SetSize(700, 520)
    local position = self.db.windowPosition
    frame:SetPoint("CENTER", UIParent, "CENTER", position.x, position.y)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local frameX, frameY = self:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        if type(frameX) == "number" and type(frameY) == "number" and type(parentX) == "number" and type(parentY) == "number" then
            FEP.db.windowPosition.x = math.max(-2000, math.min(2000, frameX - parentX))
            FEP.db.windowPosition.y = math.max(-2000, math.min(2000, frameY - parentY))
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", FEP.db.windowPosition.x, FEP.db.windowPosition.y)
        end
    end)
    self.Theme:Panel(frame, "main")
    table.insert(UISpecialFrames, frame:GetName())
    self.MainFrame = frame

    local title = self:CreateLabel(frame, "FOREVER EXPEDITION PLANNER", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 18, -16)
    self.Theme:Register(title, "title")
    local version = self:CreateLabel(frame, self.version, "GameFontDisableSmall")
    version:SetPoint("LEFT", title, "RIGHT", 9, -2)
    local close = self:CreateButton(frame, "×", 28, 28)
    close:SetPoint("TOPRIGHT", -12, -10)
    close:SetScript("OnClick", function() frame:Hide() end)

    local tabNames = { "Planner", "Presets", "Party", "Checklists", "Transfer" }
    for index, name in ipairs(tabNames) do
        local tabIndex, pageName = index, name
        local tab = self:CreateButton(frame, pageName, 105, 25)
        tab:SetPoint("TOPLEFT", 16 + ((tabIndex - 1) * 109), -43)
        tab:SetScript("OnClick", function() showPage(pageName) if pages[pageName].refresh then pages[pageName].refresh() end end)
        tabs[pageName] = tab
    end
    createPlannerPage(frame)
    createPresetsPage(frame)
    createPartyPage(frame)
    createChecklistPage(frame)
    createTransferPage(frame)
    self:On("APPEARANCE_CHANGED", function() showPage(selectedPage) end)
    showPage("Planner")
    frame:SetScript("OnShow", function()
        for _, page in pairs(pages) do if page.refresh then page.refresh() end end
    end)
    frame:Hide()
end
