local Localize = function(token,def)
    local phrase = language.GetPhrase(token)
    if phrase == token then return def end
    return phrase
end

local PANEL = {}

PANEL.Armor = 0
PANEL.digit_xpos = 50

function PANEL:Reset()
    self.Armor = -1

    self:SetLabelText(Localize("#Valve_Hud_SUIT","SUIT"))
    self:SetDisplayValue(self.Armor)
end

function PANEL:Init()
    self:Reset()
end

function PANEL:Think()
    local newArmor = 0
    if IsValid(LocalPlayer()) then
        newArmor = math.max(LocalPlayer():Armor(),0)
    end

    if newArmor == self.Armor then return end
    self.Armor = newArmor

    self:SetDisplayValue(self.Armor)
end

function PANEL:ShouldDraw()
    return LocalPlayer():Alive() and LocalPlayer():Armor() > 0
end

vgui.Register("HudArmor",PANEL,"HudNumber")