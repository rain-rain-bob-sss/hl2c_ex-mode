local color_txt = Color(255,235,20,255)
local color_bg = Color(0,0,0,128)
local SSH = ScreenScaleH

local PANEL = {}
PANEL.FGColor = color_txt
PANEL.BGColor = color_bg

PANEL.LabelText = "Number"

surface.CreateFont("HL2CEHudNumbers", {
    font = "HalfLife2",
    size = SSH(32),
    weight = 0,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    additive = true
})

surface.CreateFont("HL2CEHudNumbersGlow", {
    font = "HalfLife2",
    size = SSH(32),
    weight = 0,
    blursize = SSH(4),
    scanlines = 2,
    antialias = true,
    additive = true
})

surface.CreateFont("HL2CEHudNumbersSmall", {
    font = "HalfLife2",
    size = SSH(16),
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    additive = true
})

surface.CreateFont("HL2CEHudNumbersSmallGlow", {
    font = "HalfLife2",
    size = SSH(16),
    weight = 1000,
    blursize = SSH(4),
    scanlines = 2,
    antialias = true,
    additive = true
})

surface.CreateFont("HL2CEHudNumbersVerySmall", {
    font = "HalfLife2",
    size = SSH(9),
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    additive = true
})

surface.CreateFont("HL2CEHudNumbersVerySmallGlow", {
    font = "HalfLife2",
    size = SSH(9),
    weight = 1000,
    blursize = SSH(4),
    scanlines = 2,
    antialias = true,
    additive = true
})

PANEL.TextFont = "HudDefault"
PANEL.NumberFont = "HL2CEHudNumbers"
PANEL.NumberGlowFont = "HL2CEHudNumbersGlow"
PANEL.SmallNumberFont = "HL2CEHudNumbersSmall"

PANEL.text_xpos = 8
PANEL.text_ypos = 20
PANEL.digit_xpos = 40
PANEL.digit_ypos = 2
PANEL.digit2_xpos = 98
PANEL.digit2_ypos = 16

PANEL.Value = 0
PANEL.SecondaryValue = 0
PANEL.DisplayValue = true
PANEL.DisplaySecondaryValue = false
PANEL.Indent = false
PANEL.IsTime = false
PANEL.Blur = 0

PANEL.ShouldDrawBackground = true
PANEL.Alpha = 1

function PANEL:SetDisplayValue(value)
    self.Value = value
end

function PANEL:SetSecondaryValue(value)
    self.SecondaryValue = value
end

function PANEL:SetShouldDisplayValue(state)
    self.DisplayValue = state
end

function PANEL:SetShouldDisplaySecondaryValue(state)
    self.DisplaySecondaryValue = state
end

function PANEL:SetLabelText(text)
    self.LabelText = text
end

function PANEL:SetIndent(state)
    self.Indent = state
end

function PANEL:SetIsTime(state)
    self.IsTime = state
end

function PANEL:PaintNumbers(font,xpos,ypos,value,secondary)
    surface.SetFont(font)
    local text = ""

    local IsTime = (secondary and self.SecondaryIsTime) or self.IsTime
    local IsPercent = (secondary and self.SecondaryIsPercent) or self.IsPercent

    if not IsTime and not IsPercent then 
        text = math.Round(value)
    elseif not IsPercent then
        local Minutes = value / 60
        local Seconds = value - Minutes * 60
        if Seconds < 10 then 
            text = string.format("%d:0%d",Minutes,Seconds)
        else
            text = string.format("%d:%d",Minutes,Seconds)
        end
    else
        text = math.Round(value * 100) .. "%"
    end

    local charWidth = surface.GetTextSize(font,"0")
    if value < 100 and self.Indent then xpos = xpos + charWidth end
    if value < 10 and self.Indent then xpos = xpos + charWidth end
    surface.SetTextPos(xpos,ypos)
    surface.DrawText(text)
end

function PANEL:PaintLabel()
    surface.SetFont(self.TextFont)
    surface.SetTextColor(self.FGColor)
    surface.SetTextPos(SSH(self.text_xpos),SSH(self.text_ypos))
    surface.DrawText(self.LabelText)
end

function PANEL:Paint(w,h)

    if self.ShouldDraw and not self:ShouldDraw() then return true end

    if self.ShouldDrawBackground then 
        local col = self.BGColor
        col.a = col.a * self.Alpha
        draw.RoundedBox(8,0,0,w,h,col)
    end

    if self.DisplayValue then 
        local col = self.FGColor:Copy()
        col.a = col.a * (self.NumberAlpha or 1)
        surface.SetTextColor(col)
        self:PaintNumbers(self.NumberFont,SSH(self.digit_xpos),SSH(self.digit_ypos),self.Value)

        local fl = self.Blur
        while fl > 0 do
            if fl >= 1 then 
                self:PaintNumbers(self.NumberGlowFont,SSH(self.digit_xpos),SSH(self.digit_ypos),self.Value)
            else
                local col = self.FGColor:Copy() --update your game if you don't have this function
                col.a = col.a * fl
                surface.SetTextColor(col)
                self:PaintNumbers(self.NumberGlowFont,SSH(self.digit_xpos),SSH(self.digit_ypos),self.Value)
            end
            fl = fl - 1
        end
    end

    if self.DisplaySecondaryValue then 
        local col = self.FGColor:Copy()
        col.a = col.a * (self.SmallNumberAlpha or 1)
        surface.SetTextColor(col)
        self:PaintNumbers(self.SmallNumberFont,SSH(self.digit2_xpos),SSH(self.digit2_ypos),self.SecondaryValue,true)
    end

    self:PaintLabel()
end

function PANEL:Init()
    
end

vgui.Register("HudNumber",PANEL,"Panel")