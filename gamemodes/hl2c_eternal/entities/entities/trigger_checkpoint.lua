-- Entity information
ENT.Base = "base_brush"
ENT.Type = "brush"


-- Called when the entity first spawns
function ENT:Initialize()

	self.ipsLocation = Vector( self.pos.x, self.pos.y, self.min.z + 8 )

	local w = self.max.x - self.min.x
	local l = self.max.y - self.min.y
	local h = self.max.z - self.min.z

	local min = Vector( 0 - ( w / 2 ), 0 - ( l / 2 ), 0 - ( h / 2 ) )
	local max = Vector( w / 2, l / 2, h / 2 ) 

	self:DrawShadow( false )
	self:SetCollisionBounds( min, max )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetMoveType( 0 )
	self:SetTrigger( true )

end


-- Called when an entity touches it
function ENT:StartTouch( ent )

	if IsValid(ent) && ent:IsPlayer() && ( ent:Team() == TEAM_ALIVE ) && !self.triggered && (ent:GetMoveType() != MOVETYPE_NOCLIP || ent:InVehicle()) then
	
		-- Checkpoint was triggered
		self.triggered = true
	
		-- Run on touch
		if ( self.OnTouchRun ) then
		
			self:OnTouchRun()
		
		end
	
		-- Get the touching entity angles
		local ang = ent:GetAngles()
	
		-- Skip creating a spawn point
		if ( !self.skipSpawnpoint ) then
		
			GAMEMODE:CreateSpawnPoint( self.ipsLocation, ang.y )
		
		end
	
		-- Each individual player
		for _, ply in pairs( player.GetAll() ) do
		
			-- Set player positions
			if ( IsValid( ply ) && ( ply != ent ) && ( ply:Team() == TEAM_ALIVE ) ) then
			
				if ( IsValid( ply:GetVehicle() ) ) then
				
					ply:ExitVehicle()
					ply:GetVehicle():Remove()
				
				end
			
				ply:SetPos( self.ipsLocation )
				ply:SetAngles( ang )
			
			end
		
			-- Dead players become alive again
			if ( GetConVar( "hl2c_server_checkpoint_respawn" ):GetBool() && IsValid( ply ) && ( ply != ent ) && ( ply:Team() == TEAM_DEAD ) ) then
				deadPlayers = {}
			
				ply:SetTeam( TEAM_ALIVE )
				ply:Spawn()
			end
		end
	
		-- Remove the checkpoint from the table
		table.remove( checkpointPositions, 1 )

		-- Broadcast in chat who activated checkpoint
		PrintMessage(HUD_PRINTTALK, ent:Nick().." has activated checkpoint!")

		-- Update checkpoints on the client
		if checkpointPositions[1] then
			net.Start( "SetCheckpointPosition" )
			net.WriteVector( checkpointPositions[ 1 ] )
			net.Broadcast()
		end
	
		-- Remove the trigger
		self:Remove()
	
	end
end
