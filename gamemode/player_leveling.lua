local meta = FindMetaTable("Player")

function meta:GiveXP(xp)
    self.XP = self.XP + xp
    if self.XP >= GAMEMODE:GetReqXP(self) and tonumber(self.Level) < MAX_LEVEL then
        self:GainLevel()
    end
	net.Start("XPGain")
    net.WriteFloat(xp)
    net.Send(self)
    GAMEMODE:NetworkString_UpdateStats(self)
end

function meta:GainLevel()
    if self.IsLevelingup then return end
    if tonumber(self.Level) >= MAX_LEVEL then
        self:PrintMessage(HUD_PRINTTALK, "[HL2c EX] Level maxed")
    elseif self.XP >= GAMEMODE:GetReqXP(self) then
        local prevlvl = self.Level
        for i=1,2000 do
            if not self:CanLevelup() then break end
            self.XP = self.XP - GAMEMODE:GetReqXP(self)
            self.Level = self.Level + 1
            self.StatPoints = self.StatPoints + 1
        end
        self:PrintMessage(HUD_PRINTTALK, Format("[HL2c EX] Level increased (%i --> %i)", prevlvl, self.Level, self.Level))
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        timer.Create("hl2c_levelup_player_"..self:EntIndex(), 0.1, 1, function()
            self.IsLevelingup = false
            self:GainLevel()
        end)
    end
end

function meta:GainPrestige()
    if tonumber(self.Prestige) >= 10 then
        self:PrintMessage(HUD_PRINTTALK, "[HL2c EX] Level maxed")
    elseif self:CanPrestige() then
        local prevlvl = self.Prestige
        self.XP = 0
        self.Level = 1
        self.StatPoints = 0
        self:PrintMessage(HUD_PRINTTALK, Format("Prestige increased! (%i --> %i)", prevlvl, self.Level, self.Level))
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        timer.Simple(0.01, function() self:GainLevel() end)
    end
end



