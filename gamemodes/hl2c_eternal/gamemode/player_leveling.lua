local meta = FindMetaTable("Player")

function meta:GiveXP(xp, nomul)
    local xpmul = InfNumber(1)

    if !nomul then
        xpmul = xpmul + (self:GetSkillAmount("Knowledge") * (GAMEMODE.EndlessMode and (self:HasPerkActive("1_better_knowledge") and 0.065 or 0.05) or 0.03))

        if GAMEMODE.EndlessMode then
            if self:HasPerkActive("1_difficult_decision") then
                xpmul = xpmul * 1.1
            end

            if self:HasPerkActive("1_aggressive_gameplay") then
                xpmul = xpmul * 1.35
            end

            if self:HasPerkActive("3_celestial") then
                xpmul = xpmul * 1.4
            end
        end

        local prestigexpmul = 1
        prestigexpmul = prestigexpmul + infmath.min(self.Prestige*0.2, 100) + infmath.min(self.Eternities*1.2, 100) + infmath.min(self.Celestiality*5, 100)

        if nomul then
            xpmul = 1
            prestigexpmul = 1
        end

        xpmul = xpmul * prestigexpmul
    end


    local xpgain = xp*xpmul
    self.XP = self.XP + xpgain
    if self.MapStats then
        self.MapStats.GainedXP = (self.MapStats.GainedXP or 0) + xpgain
    end
    if self.XP >= GAMEMODE:GetReqXP(self) and infmath.ConvertInfNumberToNormalNumber(self.Level) < self:GetMaxLevel() then
        self:GainLevel()
    end

    net.Start("XPGain")
    net.WriteInfNumber(xpgain)
    net.Send(self)
    GAMEMODE:NetworkString_UpdateStats(self)

    return xpgain
end

function meta:GainLevel()
    if self.IsLevelingup then return end
    if infmath.ConvertInfNumberToNormalNumber(self.Level) >= self:GetMaxLevel() then
        if infmath.ConvertInfNumberToNormalNumber(self.Prestige) >= MAX_PRESTIGE then
            self:PrintMessage(HUD_PRINTTALK, "Prestige is maxed. Become Eternal.")
        else
           self:PrintMessage(HUD_PRINTTALK, "Level is maxed. You must prestige to go further.")
        end
    elseif self.XP >= GAMEMODE:GetReqXP(self) then
        local prevlvl = self.Level
        local prevxp, xp = self.XP, self.XPUsedThisPrestige
        local gainedsp = 0

        for i=1,1e3 do
            if not self:CanLevelup() or infmath.ConvertInfNumberToNormalNumber(self.Level) >= self:GetMaxLevel() then break end
            self.XP = self.XP - GAMEMODE:GetReqXP(self)
            self.Level = self.Level + 1
            local normallvl = infmath.ConvertInfNumberToNormalNumber(self.Level)
            self.StatPoints = self.StatPoints + (
                self:HasCelestialityUnlocked() and (normallvl >= 100 and 2 or 5) or
                self:HasEternityUnlocked() and (normallvl >= 100 and 1 or 3) or self:HasPrestigeUnlocked() and 2 or 1
            )
        end

        if self:HasPerkActive("2_skills_improver") then
            local equalspuse = math.floor(self.StatPoints / table.Count(GAMEMODE.SkillsInfo))
            for id,count in pairs(self.Skills) do
                if count >= self:GetMaxSkillLevel(id) then continue end
                local new = math.min(count + equalspuse, self:GetMaxSkillLevel(id))
                local used = new - count
                self.Skills[id] = new
                self.StatPoints = self.StatPoints - used
            end
        end
        self.XPUsedThisPrestige = prevxp + xp - self.XP
        if not self:HasEternityUnlocked() and not self:CanLevelup() then
            self:PrintMessage(HUD_PRINTTALK, Format("Level increased: %s --> %s", tostring(prevlvl), tostring(self.Level)))
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
    if self:CanPrestige() and infmath.ConvertInfNumberToNormalNumber(self.Prestige) < self:GetMaxPrestige() then
        local prevlvl = self.Prestige
        local prevprestigeunlocked = self:HasPrestigeUnlocked()
        local gainmul = self:GetPrestigeGainMul()
        self.XP = self.XP * (self:HasPerkActive("2_prestige_improvement_2") and 0.25 or self:HasPerkActive("prestige_improvement_1") and 0.15 or 0)
        self.XPUsedThisPrestige = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = self.Prestige + gainmul
        self.PrestigePoints = self.PrestigePoints + gainmul
        self:PrintMessage(HUD_PRINTTALK, Format("Prestige increased! (%s --> %s)", FormatNumber(prevlvl), FormatNumber(self.Prestige)))

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self.Skills[id] = 0
        end

        if not prevprestigeunlocked then
            PrintMessage(HUD_PRINTTALK, self:Nick().." prestiged for the first time!")
            self:EmitSound("ambient/energy/whiteflash.wav", 75, 90)
        	self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav", 75, 70)
            util.ScreenShake(self:GetPos(), 50, 0.5, 5, 800)

            net.Start("hl2ce_firstprestige")
            net.WriteString("prestige")
            net.Send(self)
        end
        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        self:GainLevel()
    end
end

function meta:GainEternity()
    if self:CanEternity() then
        local prevlvl = self.Eternities
        local preveternityunlocked = self:HasEternityUnlocked()
        self.XP = 0
        self.XPUsedThisPrestige = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = 0
        self.PrestigePoints = self:HasPerkActive("2_perk_points") and 12 or 0
        self.Eternities = self.Eternities + 1
        self.EternityPoints = self.EternityPoints + 1

        for id,_ in pairs(self.UnlockedPerks) do
            local perk = GAMEMODE.PerksData[id]
            if not perk then continue end
            if perk.PrestigeLevel <= 1 then
                if self:HasPerkActive("2_prestige_improvement_2") then
                    self.PrestigePoints = self.PrestigePoints - perk.Cost
                else
                    self.UnlockedPerks[id] = nil
                end
            end
        end

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self.Skills[id] = 0
        end

        -- if self:HasEternityUnlocked() then
            self:PrintMessage(HUD_PRINTTALK, Format("Eternity increased! (%s --> %s)", tostring(prevlvl), tostring(self.Eternities)))
        -- end

        
        if not preveternityunlocked then
            PrintMessage(HUD_PRINTTALK, self:Nick().." went eternal for the first time!")
            local eff = EffectData()
            for i=0,0.3,0.1 do
                timer.Simple(i, function()
                    self:EmitSound("ambient/energy/whiteflash.wav", 75, 90)
        	        self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav", 75, 70)

                    eff:SetOrigin(self:GetPos())
                    util.Effect("TeslaZap", eff)
                end)
            end
            util.ScreenShake(self:GetPos(), 190, 0.8, 10, 1000)

            net.Start("hl2ce_firstprestige")
            net.WriteString("eternity")
            net.Send(self)
        end

        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        GAMEMODE:NetworkString_UpdatePerks(self)
    end
end

function meta:GainCelestiality()
    if tonumber(self.Celestiality) >= self:GetMaxCelestiality() then
        self:PrintMessage(HUD_PRINTTALK, "Celestiality Maxed.")
    elseif self:CanCelestiality() then
        local prevlvl = self.Celestiality
        local prevcelestialityunlocked = self:HasCelestialityUnlocked()
        self.XP = 0
        self.XPUsedThisPrestige = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = 0
        self.PrestigePoints = self:HasPerkActive("2_perk_points") and 12 or 0
        self.Celestiality = self.Celestiality + 1
        self.CelestialityPoints = self.CelestialityPoints + 1

        for id,_ in pairs(self.UnlockedPerks) do
            local perk = GAMEMODE.PerksData[id]
            if not perk then continue end
            if perk.PrestigeLevel <= 1 then
                if self:HasPerkActive("2_prestige_improvement_2") then
                    self.PrestigePoints = self.PrestigePoints - perk.Cost
                else
                    self.UnlockedPerks[id] = nil
                end
            end
        end

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self.Skills[id] = 0
        end

        -- if self:HasEternityUnlocked() then
            self:PrintMessage(HUD_PRINTTALK, Format("Celestiality increased! (%i --> %i)", prevlvl, self.Celestiality))
        -- end

        
        if not prevcelestialityunlocked then
            PrintMessage(HUD_PRINTTALK, self:Nick().." went celestial for the first time!")
            local eff = EffectData()
            for i=0,0.3,0.1 do
                timer.Simple(i, function()
                    self:EmitSound("ambient/energy/whiteflash.wav", 75, 90)
        	        self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav", 75, 70)

                    eff:SetOrigin(self:GetPos())
                    util.Effect("TeslaZap", eff)
                end)
            end
            util.ScreenShake(self:GetPos(), 190, 0.8, 10, 1000)

            net.Start("hl2ce_firstprestige")
            net.WriteString("celestiality")
            net.Send(self)
        end

        GAMEMODE:NetworkString_UpdateStats(self)
        GAMEMODE:NetworkString_UpdateSkills(self)
        GAMEMODE:NetworkString_UpdatePerks(self)
    end
end



