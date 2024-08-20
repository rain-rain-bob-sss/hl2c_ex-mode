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

function meta:GetMaxXPGainMul()
	return self.Eternity >= 1 and 75 or self.Prestige >= 1 and 35 or 15
end


function meta:CanLevelup()
	return self.XP >= GAMEMODE:GetReqXP(self) and self.Level < MAX_LEVEL
end

function meta:CanPrestige()
	return false
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


