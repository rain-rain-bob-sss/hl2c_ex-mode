local Localize = function(token,def)
    local phrase = language.GetPhrase(token)
    if phrase == token then return def end
    return phrase
end

local color_txt = Color(255,235,20,255)
local color_txtred = Color(255,235,20,255)

--color_txt = HUD_CLIENTSCEHEME.FgColor or color_txt
--color_txtred = HUD_CLIENTSCEHEME.BrightDamagedFg or color_txtred

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
        self.SmallNumberAlpha = (1 - delta)
        self.Blur = (1 - delta) * 3
    end)
    self.HealthIncreasedBelow20 = Derma_Anim("HealthIncreasedBelow20",self,function(self,anim,delta,data)
        self.SmallNumberAlpha = delta
        self.Blur = delta * 1
    end)
    self.LowHealth = Derma_Anim("LowHealth",self,function(self,anim,delta,data)
        self.FGColor = color_txt:Lerp(color_txtred,delta)
    end)
    self.NotLowHealth = Derma_Anim("NotLowHealth",self,function(self,anim,delta,data)
        self.FGColor = color_txt:Lerp(color_txtred,1 - delta)
    end)
end

function PANEL:GetNumberFont()
    if self.Health > 999 then
        if self.Health > 9999999 then 
            return "HL2CEHudNumbersVerySmall","HL2CEHudNumbersVerySmallGlow",14
        end
        return "HL2CEHudNumbersSmall","HL2CEHudNumbersSmallGlow",10
    end
    return "HL2CEHudNumbers","HL2CEHudNumbersGlow",2
end

function PANEL:Think()

    if self.HealthIncreasedAbove20:Active() then self.HealthIncreasedAbove20:Run() end
    if self.HealthIncreasedBelow20:Active() then self.HealthIncreasedBelow20:Run() end
    if self.LowHealth:Active() then self.LowHealth:Run() end
    if self.NotLowHealth:Active() then self.NotLowHealth:Run() end

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
        self.LowHealth:Stop()
        if self.Low then 
            self.NotLowHealth:Start(1)
            self.Low = false
        end
        self.HealthIncreasedAbove20:Start(2)
    else
        self.NotLowHealth:Stop()
        self.HealthIncreasedAbove20:Stop()
        if not self.Low then
            self.LowHealth:Start(1) self.Low = true
            self.HealthIncreasedBelow20:Start(1)
        end
    end

    local font,glowfont,dypos = self:GetNumberFont()
    self.NumberFont = font
    self.NumberGlowFont = glowfont
    self.digit_ypos = dypos
    self:SetDisplayValue(self.Health)
    self:SetSecondaryValue(self.Health / maxHealth)
end

function PANEL:ShouldDraw()
    return LocalPlayer():Alive()
end

vgui.Register("HudHealth",PANEL,"HudNumber")