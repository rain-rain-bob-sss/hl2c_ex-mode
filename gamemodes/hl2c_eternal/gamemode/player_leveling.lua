local meta = FindMetaTable("Player")

function meta:GiveXP(xp, nomul)
    local xpmul = 1
    xpmul = xpmul + (self:GetSkillAmount("Knowledge") * (GAMEMODE.EndlessMode and (self:HasPerkActive("better_knowledge_1") and 0.065 or 0.05) or 0.03))

    if GAMEMODE.EndlessMode then
        if self:HasPerkActive("difficult_decision_1") then
            xpmul = xpmul * 1.1
        end

        if self:HasPerkActive("aggressive_gameplay_1") then
            xpmul = xpmul * 1.35
        end
    end

    local prestigexpmul = 1
    prestigexpmul = prestigexpmul + math.min(self.Prestige*0.2, 100) + math.min(self.Eternity*1.2, 100) + math.min(self.Celestiality*5, 100)

    xpmul = xpmul * prestigexpmul

    if nomul then
        xpmul = 1
        prestigexpmul = 1
    end

    self.XP = self.XP + xp*xpmul
    if self.MapStats then
        self.MapStats.GainedXP = (self.MapStats.GainedXP or 0) + xp*xpmul
    end
    if self.XP >= GAMEMODE:GetReqXP(self) and tonumber(self.Level) < self:GetMaxLevel() then
        self:GainLevel()
    end

    net.Start("XPGain")
    net.WriteFloat(xp*xpmul)
    net.Send(self)
    GAMEMODE:NetworkString_UpdateStats(self)
end

function meta:GainLevel()
    if self.IsLevelingup then return end
    if tonumber(self.Level) >= self:GetMaxLevel() then
        if tonumber(self.Prestige) >= MAX_PRESTIGE then
            self:PrintMessage(HUD_PRINTTALK, "Prestige is maxed. Become Eternal.")
        else
           self:PrintMessage(HUD_PRINTTALK, "Level is maxed. You must prestige to go further.")
        end
    elseif self.XP >= GAMEMODE:GetReqXP(self) then
        local prevlvl = self.Level
        local prevxp, xp = self.XP, self.XPUsedThisPrestige
        local gainedsp = 0
        for i=1,1e4 do
            if not self:CanLevelup() or self.Level >= self:GetMaxLevel() then break end
            self.XP = self.XP - GAMEMODE:GetReqXP(self)
            self.Level = self.Level + 1
            self.StatPoints = self.StatPoints + (
                self:HasCelestialityUnlocked() and (self.Level >= 100 and 2 or 5) or
                self:HasEternityUnlocked() and (self.Level >= 100 and 1 or 3) or self:HasPrestigeUnlocked() and 2 or 1
            )
        end

        if self:HasPerkActive("skills_improver_2") then
            local equalspuse = math.floor(self.StatPoints / table.Count(GAMEMODE.SkillsInfo))
            for id,_ in pairs(GAMEMODE.SkillsInfo) do
                if self["Stat"..id] >= self:GetMaxSkillLevel(id) then continue end
                local new = math.min(self["Stat"..id] + equalspuse, self:GetMaxSkillLevel(id))
                local used = new - self["Stat"..id]
                self["Stat"..id] = new
                self.StatPoints = self.StatPoints - used
            end
        end
        self.XPUsedThisPrestige = prevxp + xp - self.XP
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
    if self:CanPrestige() and self.Prestige < self:GetMaxPrestige() then
        local prevlvl = self.Prestige
        local prevprestigeunlocked = self:HasPrestigeUnlocked()
        local gainmul = self:GetPrestigeGainMul()
        self.XP = self.XP * (self:HasPerkActive("prestige_improvement_2") and 0.25 or self:HasPerkActive("prestige_improvement_1") and 0.15 or 0)
        self.XPUsedThisPrestige = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = self.Prestige + gainmul
        self.PrestigePoints = self.PrestigePoints + gainmul
        self:PrintMessage(HUD_PRINTTALK, Format("Prestige increased! (%i --> %i)", prevlvl, self.Prestige))

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self["Stat"..id] = 0
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
    if tonumber(self.Eternity) >= self:GetMaxEternity() then
        self:PrintMessage(HUD_PRINTTALK, "You have reached maximum amount of Eternities. You must Celestialize to go even further beyond.")
    elseif self:CanEternity() then
        local prevlvl = self.Eternity
        local preveternityunlocked = self:HasEternityUnlocked()
        self.XP = 0
        self.XPUsedThisPrestige = 0
        self.Level = 1
        self.StatPoints = 0
        self.Prestige = 0
        self.PrestigePoints = self:HasPerkActive("perk_points_2") and 12 or 0
        self.Eternity = self.Eternity + 1
        self.EternityPoints = self.EternityPoints + 1

        for id,_ in pairs(self.UnlockedPerks) do
            local perk = GAMEMODE.PerksData[id]
            if not perk then continue end
            if perk.PrestigeLevel <= 1 then
                if self:HasPerkActive("prestige_improvement_2") then
                    self.PrestigePoints = self.PrestigePoints - perk.Cost
                else
                    self.UnlockedPerks[id] = nil
                end
            end
        end

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self["Stat"..id] = 0
        end

        -- if self:HasEternityUnlocked() then
            self:PrintMessage(HUD_PRINTTALK, Format("Eternity increased! (%i --> %i)", prevlvl, self.Eternity))
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
        self.PrestigePoints = self:HasPerkActive("perk_points_2") and 12 or 0
        self.Eternity = 0
        self.EternityPoints = 0
        self.Celestiality = self.Celestiality + 1
        self.CelestialityPoints = self.CelestialityPoints + 1

        for id,_ in pairs(self.UnlockedPerks) do
            local perk = GAMEMODE.PerksData[id]
            if not perk then continue end
            if perk.PrestigeLevel <= 2 then
                --if self:HasPerkActive("prestige_improvement_2") then
                    --self.PrestigePoints = self.PrestigePoints - perk.Cost
                --else
                    self.UnlockedPerks[id] = nil
                --end
            end
        end

        for id,_ in pairs(GAMEMODE.SkillsInfo) do
            self["Stat"..id] = 0
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



