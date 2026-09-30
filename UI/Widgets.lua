local _, FEP = ...

function FEP:CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 100, height or 24)

    -- Forever's plain Button does not lazily create a font string when SetText
    -- or SetNormalFontObject is called. Install one explicitly so callers can
    -- safely use GetFontString(), alignment, and SetText on every client build.
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", button, "LEFT", 6, 0)
    label:SetPoint("RIGHT", button, "RIGHT", -6, 0)
    label:SetJustifyH("CENTER")
    button:SetFontString(label)
    button:SetText(text or "")

    self.Theme:Button(button)
    return button
end

function FEP:CreateLabel(parent, text, template)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    label:SetText(text or "")
    label:SetTextColor(unpack(self.Theme.text))
    return label
end

function FEP:CreateEditBox(parent, width, height, multiline)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(width, height)
    box:SetAutoFocus(false)
    box:SetFontObject("GameFontHighlight")
    if multiline then
        box:SetMultiLine(true)
        box:SetTextInsets(8, 8, 8, 8)
    end
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return box
end

function FEP:CreateCheckRow(parent, width)
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetSize(width, 24)
    local check = row:CreateTexture(nil, "ARTWORK")
    check:SetSize(16, 16)
    check:SetPoint("LEFT", 2, 0)
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    local label = self:CreateLabel(row, "")
    label:SetPoint("LEFT", check, "RIGHT", 5, 0)
    row.check = check
    row.label = label
    return row
end
