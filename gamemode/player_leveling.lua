local meta = FindMetaTable("Player")

function meta:GiveXP(xp)
    self.XP = self.XP + xp
    if self.XP >= GAMEMODE:GetReqXP(self) and tonumber(self.Level) < 100 then
        self:GainLevel()
    end
	net.Start("XPGain")
    net.WriteFloat(xp)
    net.Send(self)
    GAMEMODE:NetworkString_UpdateStats(self)
end

function meta:GainLevel()
    if tonumber(self.Level) >= 100 then
        self:PrintMessage(HUD_PRINTTALK, "[HL2c EX] Level maxed")
    elseif self.XP >= GAMEMODE:GetReqXP(self) then
        local prevlvl = self.Level
        self.XP = self.XP - GAMEMODE:GetReqXP(self)
        self.Level = self.Level + 1
        self.StatPoints = self.StatPoints + 1
        self:PrintMessage(HUD_PRINTTALK, Format("[HL2c EX] Level increased (%i --> %i)", prevlvl, self.Level, self.Level))
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        timer.Simple(0.01, function() self:GainLevel() end)
    end
end
