-- Finds the player meta table or terminates
local meta = FindMetaTable( "Player" )
if !meta then return end


-- Remove the vehicle
function meta:RemoveVehicle()

	if ( CLIENT || !self:IsValid() ) then
	
		return
	
	end

	if ( IsValid( self.vehicle ) ) then
	
		if ( IsValid( self.vehicle:GetDriver() ) && self.vehicle:GetDriver():IsPlayer() ) then
		
			self.vehicle:GetDriver():ExitVehicle()
		
		end
		self.vehicle:Remove()
	
	end

end

function meta:GetMaxDifficultyXPGainMul()
	return self:HasEternityUnlocked() and 250 or self:HasPrestigeUnlocked() and 75 or 15
end

function meta:GetSkillAmount(stat)
	if GAMEMODE.NoProgressionAdvantage then return 0 end
	return math.Clamp(self["Stat"..stat] or 0, 0, GAMEMODE.EndlessMode and 1e6 or 10)
end

function meta:HasPerkUnlocked(perk)
	return self.UnlockedPerks[perk]
end

function meta:HasPerkActive(perk)
	local perkdata = GAMEMODE.PerksData[perk]

	if GAMEMODE.NoProgressionAdvantage then return false end

	return self:HasPerkUnlocked(perk) and not table.HasValue(self.DisabledPerks, perk) and (GAMEMODE.EndlessMode or perkdata.PrestigeLevel < 2)
end




function meta:GetPlayerConfig(data)
	return GAMEMODE.ConfigList[data] and self.ConfigData[data]
end


function meta:CanLevelup()
	return self.XP >= GAMEMODE:GetReqXP(self)
end

function meta:CanPrestige()
	return self.Level > MAX_LEVEL or self.Level >= MAX_LEVEL and self.XP >= GAMEMODE:GetReqXP(self)
end

function meta:CanEternity()
	return self:CanPrestige() and self.Prestige >= MAX_PRESTIGE
end

function meta:HasPrestigeUnlocked()
	return self.Prestige > 0 or self:HasEternityUnlocked()
end

function meta:HasEternityUnlocked()
	return self.Eternity > 0 or self:HasCelestialityUnlocked()
end

function meta:HasCelestialityUnlocked()
	return self.Celestiality > 0
end

function meta:GetPrestigeGainMul()
	return math.floor(math.Clamp(
		self.XPUsedThisPrestige / GAMEMODE:CalculateXPNeededForLevels(MAX_LEVEL) * 0.6,
		1, self:GetMaxPrestige() - self.Prestige))
end

function meta:GetMaxLevel()
	return self:HasEternityUnlocked() and 250 or MAX_LEVEL
end

function meta:GetMaxPrestige()
	return self:HasEternityUnlocked() and 30 or MAX_PRESTIGE
end

function meta:GetMaxEternity()
	return MAX_ETERNITIES
end

function meta:GetMaxSkillLevel(perk)
	return self:HasEternityUnlocked() and (self:HasPerkActive("skills_improver_2") and 80 or 60) or self:HasPrestigeUnlocked() and 35 or 20
end


