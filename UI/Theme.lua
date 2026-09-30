local _, FEP = ...

local Theme = {
    bronze = { 0.78, 0.54, 0.23 }, bronzeBright = { 1.00, 0.77, 0.36 }, bronzeDark = { 0.20, 0.12, 0.06 },
    panel = { 0.055, 0.045, 0.035, 0.96 }, text = { 0.92, 0.86, 0.72 }, muted = { 0.62, 0.57, 0.48 },
    warning = { 1.00, 0.38, 0.20 }, objects = {},
}
FEP.Theme = Theme

local CUSTOM_BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 }
-- Blizzard's tiled legacy backdrops are safe here: unlike atlases, SetBackdrop
-- renders their border as slices and tiles the center instead of stretching it.
local NATIVE_DIALOG_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 },
}
local NATIVE_INSET_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

function Theme:IsBronze()
    return FEP.db and FEP.db.settings and FEP.db.settings.appearance == "bronze"
end

function Theme:Register(object, kind)
    if not object then return object end
    self.objects[#self.objects + 1] = { object = object, kind = kind }
    self:ApplyObject(object, kind)
    return object
end

function Theme:Panel(frame, kind) self:Register(frame, kind or "panel") end

local function tint(texture, r, g, b)
    if texture and texture.SetVertexColor then texture:SetVertexColor(r, g, b, 1) end
end

function Theme:Button(button)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    if not button._fepThemeRegistered then
        button._fepThemeRegistered = true
        self:Register(button, "button")
    else
        self:ApplyObject(button, "button")
    end
end

function Theme:ApplyObject(object, kind)
    if not object then return end
    local bronze = self:IsBronze()
    if kind == "main" or kind == "panel" or kind == "card" then
        object:SetBackdrop(bronze and CUSTOM_BACKDROP or (kind == "main" and NATIVE_DIALOG_BACKDROP or NATIVE_INSET_BACKDROP))
        if bronze then
            object:SetBackdropColor(unpack(self.panel)); object:SetBackdropBorderColor(unpack(self.bronze))
        else
            object:SetBackdropColor(0.08, 0.08, 0.08, kind == "main" and 1 or 0.94); object:SetBackdropBorderColor(1, 1, 1, 1)
        end
    elseif kind == "optionsBackground" then
        if bronze then object:SetColorTexture(0.025, 0.018, 0.012, 0.72) else object:SetColorTexture(0.075, 0.075, 0.075, 0.35) end
    elseif kind == "title" then
        if bronze then object:SetTextColor(unpack(self.bronzeBright)) else object:SetTextColor(1, 0.82, 0) end
    elseif kind == "text" then
        if bronze then object:SetTextColor(unpack(self.text)) else object:SetTextColor(1, 1, 1) end
    elseif kind == "muted" then
        if bronze then object:SetTextColor(unpack(self.muted)) else object:SetTextColor(0.72, 0.72, 0.72) end
    elseif kind == "button" then
        object:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
        object:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
        object:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
        object:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
        local r, g, b = 1, 1, 1; if bronze then r, g, b = 0.86, 0.66, 0.38 end
        tint(object:GetNormalTexture(), r, g, b); tint(object:GetPushedTexture(), r, g, b); tint(object:GetDisabledTexture(), r, g, b)
        if object:GetFontString() then
            if bronze then object:GetFontString():SetTextColor(unpack(self.text)) else object:GetFontString():SetTextColor(1, 0.82, 0) end
        end
    end
end

function Theme:ApplyAppearance()
    for _, entry in ipairs(self.objects) do self:ApplyObject(entry.object, entry.kind) end
    FEP:Emit("APPEARANCE_CHANGED", FEP.db.settings.appearance)
end

function FEP:SetAppearance(value)
    if value ~= "blizzard" and value ~= "bronze" then value = "blizzard" end
    self.db.settings.appearance = value
    self.Theme:ApplyAppearance()
end
