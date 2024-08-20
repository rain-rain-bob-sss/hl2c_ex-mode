local meta = FindMetaTable("Player")

function meta:GiveXP(xp, nomul)
    local xpmul = 1
    xpmul = xpmul + (self:GetSkillAmount("Knowledge") * (GAMEMODE.EndlessMode and (self:HasPerkActive("better_knowledge_1") and 0.07 or 0.05) or 0.03))

    local prestigexpmul = 1
    prestigexpmul = prestigexpmul + math.min(self.Prestige*0.1, 100) + math.min(self.Eternity*0.5, 100) + math.min(self.Celestiality*1.5, 100)

    prestigexpmul = math.min(1000, prestigexpmul)*xpmul

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

function meta:GainLevel()
    if self.IsLevelingup then return end
    if tonumber(self.Level) >= MAX_LEVEL then
        self:PrintMessage(HUD_PRINTTALK, "Level is maxed. You must prestige to go further.")
    elseif self.XP >= GAMEMODE:GetReqXP(self) then
        local prevlvl = self.Level
        for i=1,2000 do
            if not self:CanLevelup() or self.Level >= MAX_LEVEL then break end
            self.XP = self.XP - GAMEMODE:GetReqXP(self)
            self.Level = self.Level + 1
            self.StatPoints = self.StatPoints + 1
        end
        if not self:HasEternityUnlocked() then
            self:PrintMessage(HUD_PRINTTALK, Format("Level increased: %i --> %i", prevlvl, self.Level))
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
        self:PrintMessage(HUD_PRINTTALK, "Prestige is maxed. Eternity to go even further.")
    elseif self:CanPrestige() then
        local prevlvl = self.Prestige
        local prevprestigeunlocked = self:HasPrestigeUnlocked()
        self.XP = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = self.Prestige + 1
        self.PrestigePoints = self.PrestigePoints + 1
        self:PrintMessage(HUD_PRINTTALK, Format("Prestige increased! (%i --> %i)", prevlvl, self.Prestige))
        if not prevprestigeunlocked then
            PrintMessage(HUD_PRINTTALK, self:Nick().." prestiged for the first time!")
        end
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
    end
end

function meta:GainEternity()
    if tonumber(self.Eternity) >= MAX_ETERNITIES then
        self:PrintMessage(HUD_PRINTTALK, "You have reached maximum amount of Eternities. You must Celestialize to go even further beyond.")
    elseif self:CanEternity() then
        local prevlvl = self.Eternity
        self.XP = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = 0
        self.PrestigePoints = 0
        self.Eternity = self.Eternity + 1
        self.EternityPoints = self.EternityPoints + 1

        -- if self:HasEternityUnlocked() then
            self:PrintMessage(HUD_PRINTTALK, Format("Eternity increased! (%i --> %i)", prevlvl, self.Eternity))
        -- end

        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
    end
end



