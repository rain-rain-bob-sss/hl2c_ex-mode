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
	if not perk then return false end
	local perkdata = GAMEMODE.PerksData[perk]
	if not perkdata then return end

	if GAMEMODE.NoProgressionAdvantage then return false end

	return self:HasPerkUnlocked(perk) and not table.HasValue(self.DisabledPerks, perk) and (GAMEMODE.EndlessMode or perkdata.PrestigeLevel < 2)
end




function meta:CanLevelup()
	return self.XP >= GAMEMODE:GetReqXP(self)
end

function meta:CanPrestige()
	return self.Level >= MAX_LEVEL and self.XP >=GAMEMODE:GetReqXP(self)
end

function meta:CanEternity()
	return false
end

function meta:HasPrestigeUnlocked()
	if not self.Prestige then return false end
	return self.Prestige > 0 or self:HasEternityUnlocked()
end

function meta:HasEternityUnlocked()
	if not self.Eternity then return false end
	return self.Eternity > 0 or self:HasCelestialityUnlocked()
end

function meta:HasCelestialityUnlocked()
	if not self.Celestiality then return false end
	return self.Celestiality > 0
end


