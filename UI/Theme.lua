local _, FEP = ...

FEP.Theme = {
    bronze = { 0.78, 0.54, 0.23 },
    bronzeBright = { 1.00, 0.77, 0.36 },
    bronzeDark = { 0.20, 0.12, 0.06 },
    panel = { 0.055, 0.045, 0.035, 0.96 },
    text = { 0.92, 0.86, 0.72 },
    muted = { 0.62, 0.57, 0.48 },
    warning = { 1.00, 0.38, 0.20 },
}

function FEP.Theme:Panel(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(self.panel))
    frame:SetBackdropBorderColor(unpack(self.bronze))
end

function FEP.Theme:Button(button)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
end
