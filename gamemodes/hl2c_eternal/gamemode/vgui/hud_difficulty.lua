local PANEL = {}

PANEL.text_xpos = 8
PANEL.text_ypos = 15
PANEL.digit_xpos = 55
PANEL.digit_ypos = 10
PANEL.digit2_xpos = 98
PANEL.digit2_ypos = 16

function PANEL:GetNumberFont()
    if self.Health > 999 / 100 then
        if self.Health > 9999999 / 100 then 
            return "HL2CEHudNumbersVerySmall","HL2CEHudNumbersVerySmallGlow",14
        end
        return "HL2CEHudNumbersSmall","HL2CEHudNumbersSmallGlow",10
    end
    return "HL2CEHudNumbers","HL2CEHudNumbersGlow",2
end

PANEL.IsPercent = true

function PANEL:Reset()
    self.StartTime = 0

    self:SetLabelText("Difficulty")
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

function PANEL:Paint(w,h)
    self:Draw(w,h)

    local diff = GAMEMODE.DifficultyDifference or 0
    if diff == 0 then return end
    local totaldiff = GAMEMODE.DifficultyDifferenceTotal
    local colordifference
    colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (self.DifficultyDifference < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0)) or Color(255, 220, 0)
	colordifference.a = 155
end

vgui.Register("HudTimeSpent",PANEL,"HudNumber")