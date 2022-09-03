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
