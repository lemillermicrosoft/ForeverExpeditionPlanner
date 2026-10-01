local _, FEP = ...

local function clamp(value)
    return math.max(-2000, math.min(2000, value))
end

local function applyPosition(frame)
    local position = FEP.db.campButton.position
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", position.x, position.y)
end

function FEP:CreateCampButton()
    if self.CampButton then return end
    local context = self.modules.CampContext
    local button = self:CreateButton(UIParent, "CAMP", 48, 40)
    button:SetFrameStrata("DIALOG")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    applyPosition(button)
    self.CampButton = button

    local panel = CreateFrame("Frame", "ForeverExpeditionPlannerCampPanel", UIParent, "BackdropTemplate")
    panel:SetSize(430, 430)
    panel:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -5)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    self.Theme:Panel(panel, "panel")
    panel:Hide()

    local title = self:CreateLabel(panel, "CAMP CHOICE", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 14, -13)
    self.Theme:Register(title, "title")
    local recommendation = self:CreateLabel(panel, "", "GameFontHighlightSmall")
    recommendation:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7)
    recommendation:SetWidth(400)
    recommendation:SetJustifyH("LEFT")
    local empty = self:CreateLabel(panel, "", "GameFontHighlight")
    empty:SetPoint("TOPLEFT", recommendation, "BOTTOMLEFT", 0, -18)
    empty:SetWidth(400)
    empty:SetJustifyH("LEFT")
    local pageNumber = 1

    local rows = {}
    for index = 1, 6 do
        local row = self:CreateButton(panel, "", 400, 48)
        row:SetPoint("TOPLEFT", recommendation, "BOTTOMLEFT", 0, -13 - ((index - 1) * 51))
        row:GetFontString():SetJustifyH("LEFT")
        row:SetScript("OnClick", function(item)
            if item.objectID then
                local ok, err = context:SetDefault(item.objectID)
                FEP:Print(ok and ("Personal camp default: " .. item.objectName) or err)
            end
        end)
        row:SetScript("OnEnter", function(item)
            local object = FEP:GetCampObject(item.objectID)
            if not object then return end
            GameTooltip:SetOwner(item, "ANCHOR_RIGHT")
            GameTooltip:SetText(object.name)
            for line in context:Describe(object):gmatch("[^\n]+") do GameTooltip:AddLine(line, 1, 1, 1, true) end
            GameTooltip:AddLine("Click to save as your personal default.", 0.4, 0.9, 0.4, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        rows[index] = row
    end

    local previous = self:CreateButton(panel, "Previous", 90, 25)
    previous:SetPoint("BOTTOMLEFT", 14, 12)
    local pageLabel = self:CreateLabel(panel, "", "GameFontHighlightSmall")
    pageLabel:SetPoint("LEFT", previous, "RIGHT", 12, 0)
    pageLabel:SetWidth(180)
    pageLabel:SetJustifyH("CENTER")
    local nextPage = self:CreateButton(panel, "Next", 90, 25)
    nextPage:SetPoint("BOTTOMRIGHT", -14, 12)

    local function refresh()
        local settings = FEP.db.campButton
        button:SetShown(settings.visible and context.contextActive)
        if not button:IsShown() then panel:Hide() end
        local choice, reason = context:GetRecommendation()
        button:SetText(choice and "CAMP\n" .. choice.name:sub(1, 8) or "CAMP")
        recommendation:SetText(reason)
        local choices = context:GetChoices()
        local pageCount = math.max(1, math.ceil(#choices / #rows))
        pageNumber = math.max(1, math.min(pageCount, pageNumber))
        pageLabel:SetText("Page " .. pageNumber .. " / " .. pageCount)
        previous:SetEnabled(pageNumber > 1)
        nextPage:SetEnabled(pageNumber < pageCount)
        empty:SetShown(#choices == 0)
        empty:SetText(#choices == 0 and "No verified camp additions are currently available. Use this panel to confirm context readiness; options will appear automatically when a verified provider registers records." or "")
        for index, row in ipairs(rows) do
            local object = choices[((pageNumber - 1) * #rows) + index]
            row:SetShown(object ~= nil)
            row.objectID, row.objectName = object and object.id or nil, object and object.name or nil
            if object then
                local marker = settings.defaultObjectID == object.id and "[DEFAULT] " or ""
                local effect = #(object.buffs or {}) > 0 and table.concat(object.buffs, ", ") or "No verified effect"
                local materials = {}
                for _, material in ipairs(object.materials or {}) do materials[#materials + 1] = tostring(material.count) .. "x " .. material.name end
                row:SetText(marker .. object.name .. "\nEffect: " .. effect .. " | Materials: " .. (#materials > 0 and table.concat(materials, ", ") or "none verified"))
            end
        end
    end


    previous:SetScript("OnClick", function() pageNumber = math.max(1, pageNumber - 1); refresh() end)
    nextPage:SetScript("OnClick", function() pageNumber = pageNumber + 1; refresh() end)

    button:SetScript("OnClick", function()
        refresh()
        panel:SetShown(not panel:IsShown())
    end)
    button:SetScript("OnEnter", function(self)
        local object, reason = context:GetRecommendation()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Forever Expedition Planner")
        GameTooltip:AddLine(context:GetDetectionStatus(), 1, 1, 1, true)
        GameTooltip:AddLine(reason, 0.8, 0.8, 0.8, true)
        if object then GameTooltip:AddLine(context:Describe(object), 1, 0.82, 0.2, true) end
        GameTooltip:AddLine("Click to review; drag to move. Planning only: nothing is placed or cast.", 0.4, 0.9, 0.4, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local px, py = UIParent:GetCenter()
        if type(x) == "number" and type(y) == "number" and type(px) == "number" and type(py) == "number" then
            FEP.db.campButton.position.x, FEP.db.campButton.position.y = clamp(x - px), clamp(y - py)
            applyPosition(self)
        end
    end)

    self:On("CAMP_CONTEXT_CHANGED", refresh)
    self:On("CAMP_DEFAULT_CHANGED", refresh)
    self:On("DATA_CHANGED", refresh)
    self:On("PLAN_CHANGED", refresh)
    self:On("ASSIGNMENTS_CHANGED", refresh)
    self:On("APPEARANCE_CHANGED", refresh)
    panel.refresh = refresh
    refresh()
end

function FEP:ResetCampButtonPosition()
    self.db.campButton.position.x, self.db.campButton.position.y = 260, -40
    if self.CampButton then applyPosition(self.CampButton) end
end
