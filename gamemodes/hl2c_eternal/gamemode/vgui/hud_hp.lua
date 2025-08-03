local Localize = function(token,def)
    local phrase = language.GetPhrase(token)
    if phrase == token then return def end
    return phrase
end

local SSH = ScreenScaleH

surface.CreateFont("HL2CEHudDefault1", {
    font = "Verdana",
    size = SSH(9),
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    additive = true
})

local PANEL = {}

PANEL.Health = 0
PANEL.digit_xpos = 50
PANEL.digit2_xpos = 8
PANEL.digit2_ypos = 27
PANEL.DisplaySecondaryValue = true
PANEL.SecondaryIsPercent = true
PANEL.SmallNumberFont = "HL2CEHudDefault1"

function PANEL:Reset()
    self.Health = -1

    self:SetLabelText(Localize("#Valve_Hud_HEALTH","HEALTH"))
    self:SetDisplayValue(self.Health)
end

function PANEL:Init()
    self:Reset()
    self.HealthIncreasedAbove20 = Derma_Anim("HealthIncreasedAbove20",self,function(self,anim,delta,data)
        self.Blur = (1 - delta) * 3
    end)
    self.HealthIncreasedBelow20 = Derma_Anim("HealthIncreasedBelow20",self,function(self,anim,delta,data)
        self.Blur = delta * 1
    end)
end

function PANEL:Think()

    if self.HealthIncreasedAbove20:Active() then self.HealthIncreasedAbove20:Run() end
    if self.HealthIncreasedBelow20:Active() then self.HealthIncreasedBelow20:Run() end

    local newHealth = 0
    local maxHealth = 0
    if IsValid(LocalPlayer()) then
        newHealth = math.max(LocalPlayer():Health(),0)
        maxHealth = LocalPlayer():GetMaxHealth()
    end

    if newHealth == self.Health then return end

    self.Health = newHealth

    if self.Health >= LocalPlayer():GetMaxHealth() * 0.2 then 
        self.HealthIncreasedBelow20:Stop()
        self.HealthIncreasedAbove20:Start(1)
    else
        self.HealthIncreasedAbove20:Stop()
        self.HealthIncreasedBelow20:Start(0.5)
    end

    self.NumberFont = self.Health > 999 and "HL2CEHudNumbersSmall" or "HL2CEHudNumbers"
    self.NumberGlowFont = self.Health > 999 and "HL2CEHudNumbersSmallGlow" or "HL2CEHudNumbersGlow"
    self.digit_ypos = self.Health > 999 and 10 or 2
    self:SetDisplayValue(self.Health)
    self:SetSecondaryValue(self.Health / maxHealth)
end

function PANEL:ShouldDraw()
    return LocalPlayer():Alive()
end

vgui.Register("HudHealth",PANEL,"HudNumber")