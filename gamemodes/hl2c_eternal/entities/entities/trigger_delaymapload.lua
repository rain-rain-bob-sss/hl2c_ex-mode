-- Entity information
ENT.Base = "base_brush"
ENT.Type = "brush"


-- Called when the entity first spawns
function ENT:Initialize()

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

local plys={}
hook.Add("Think","Hl2ce_No weapon in roaming",function()
	for i,v in pairs(plys)do
		if IsValid(v) then
			v:SetActiveWeapon(NULL)
			v:DropObject()
		end
	end
end)

-- Called when an entity touches me :D
function ENT:StartTouch( ent )

	if ( IsValid( ent ) && ent:IsPlayer() && ( ent:Team() == TEAM_ALIVE ) && (ent:GetMoveType() != MOVETYPE_NOCLIP || ent:InVehicle())) then

		ent:SetTeam( TEAM_COMPLETED_MAP )

		-- Remove their vehicle
		if ( IsValid( ent:GetVehicle() ) ) then

			ent:ExitVehicle()
			ent:RemoveVehicle()

		end

		-- Freeze them and make sure they don't push people away (and also so they don't get targeted by NPC's)
		--ent:Lock()
		plys[#plys+1]=ent
		ent:Spectate(OBS_MODE_ROAMING)
		ent:SetNoDraw(true)

		ent:SetMoveType(MOVETYPE_NOCLIP)
		ent:SetAvoidPlayers(false)
		ent:SetNoTarget(true)

		-- Start the nextmap countdown
		if !changingLevel then
			gamemode.Call("OnMapCompleted")
			GAMEMODE:NextMap()
		end

		-- Let everyone know that someone entered the loading section
		PrintMessage( HUD_PRINTTALK, Format( "%s completed the map (%s) [%i of %i]", ent:Name(), string.ToMinutesSeconds( CurTime() - ent.startTime ), team.NumPlayers( TEAM_COMPLETED_MAP ), self.playersAlive))

		gamemode.Call("PlayerCompletedMap", ent)
	end
end


-- Checks to see if we should go to the next map
function ENT:Think()

	self.playersAlive = team.NumPlayers( TEAM_ALIVE ) + team.NumPlayers( TEAM_COMPLETED_MAP )

	if ( ( self.playersAlive > 0 ) && ( team.NumPlayers( TEAM_COMPLETED_MAP ) >= ( self.playersAlive * ( NEXT_MAP_PERCENT / 100 ) ) ) ) then

		GAMEMODE:GrabAndSwitch()

	end

end
