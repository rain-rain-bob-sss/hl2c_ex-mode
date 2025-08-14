local PANEL = {}

PANEL.EndTime = 0
PANEL.digit_xpos = 0

function PANEL:Reset()
    self.EndTime = 0

    self:SetLabelText("")
    self:SetDisplayValue(self.EndTime - CurTime())
    self.IsTime = true
end

function PANEL:Init()
    self:Reset()
end

function PANEL:Think()
    self:SetDisplayValue(self.EndTime - CurTime())
end

function PANEL:ShouldDraw()
    return true
end

vgui.Register("HudTimeRemain",PANEL,"HudNumber")