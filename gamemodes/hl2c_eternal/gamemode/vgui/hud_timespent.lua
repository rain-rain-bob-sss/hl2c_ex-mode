surface.CreateFont("HL2CEHudDefault2", {
    font = "Verdana",
    size = ScreenScaleH(18),
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    additive = true
})

surface.CreateFont("HL2CEHudDefault0.8", {
    font = "Verdana",
    size = ScreenScaleH(9 * 0.8),
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    additive = true
})

local PANEL = {}

PANEL.StartTime = 0
PANEL.Freeze = false
PANEL.TextFont = "HL2CEHudDefault0.8"
PANEL.NumberFont = "HL2CEHudDefault2"

PANEL.text_xpos = 8
PANEL.text_ypos = 15
PANEL.digit_xpos = 55
PANEL.digit_ypos = 10
PANEL.digit2_xpos = 98
PANEL.digit2_ypos = 16
PANEL.IsTime = true

function PANEL:Reset()
    self.StartTime = 0

    self:SetLabelText("")
    self:SetDisplayValue(CurTime() - self.StartTime)
end

function PANEL:Init()
    self:Reset()
end

function PANEL:Think()
    if self.Freeze then 
        return 
    end
    self:SetDisplayValue(CurTime() - self.StartTime)
end

function PANEL:ShouldDraw()
    return true
end

vgui.Register("HudTimeSpent",PANEL,"HudNumber")