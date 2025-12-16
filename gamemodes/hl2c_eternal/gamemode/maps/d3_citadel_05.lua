NEXT_MAP = "d3_breen_01"
GM.XP_REWARD_ON_MAP_COMPLETION = 0

NEXT_MAP_PERCENT = 1
NEXT_MAP_INSTANT_PERCENT = 1

CITADEL_VEHICLE_ENTITY = nil

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_physcannon" )

	if ( !game.SinglePlayer() && IsValid( PLAYER_VIEWCONTROL ) && ( PLAYER_VIEWCONTROL:GetClass() == "point_viewcontrol" ) ) then
	
		ply:SetViewEntity( PLAYER_VIEWCONTROL )
		ply:SetNoDraw( true )
		ply:DrawWorldModel( false )
		ply:Lock()
	
		ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
		ply:CollisionRulesChanged()
	
	end

	timer.Simple( 0.1, function() if ( IsValid( ply ) ) then ply:SetNoTarget( true ); end; end )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	game.SetGlobalState( "super_phys_gun", GLOBAL_ON )

	game.ConsoleCommand( "physcannon_tracelength 850\n" )
	game.ConsoleCommand( "physcannon_maxmass 850\n" )
	game.ConsoleCommand( "physcannon_pullforce 8000\n" )

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetClass() == "point_viewcontrol" ) ) then
	
		if ( string.lower( input ) == "enable" ) then
		
			PLAYER_VIEWCONTROL = ent
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ent )
				ply:SetNoDraw( true )
				ply:DrawWorldModel( false )
				ply:Lock()
			
				ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
				ply:CollisionRulesChanged()
			
			end
		
			if ( !ent.doubleEnabled ) then
			
				ent.doubleEnabled = true
				ent:Fire( "Enable" )
			
			end
		
		elseif ( string.lower( input ) == "disable" ) then
		
			PLAYER_VIEWCONTROL = nil
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ply )
				ply:SetNoDraw( false )
				ply:DrawWorldModel( true )
				ply:UnLock()
			
				ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
				ply:CollisionRulesChanged()
			
			end
		
			return true
		
		end
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )


-- Every frame or tick
function hl2cThink()

	if ( game.GetGlobalState("super_phys_gun") == GLOBAL_ON ) then
	
		for _, ent in pairs( ents.FindByClass( "weapon_physcannon" ) ) do
		
			if ( IsValid( ent ) && ent:IsWeapon() ) then
			
				if ( ent:GetSkin() != 1 ) then ent:SetSkin( 1 ); end
			
			end
		
		end
	
		for _, ent in pairs( ents.FindByClass( "weapon_*" ) ) do
		
			if ( IsValid( ent ) && ent:IsWeapon() && ( ent:GetClass() != "weapon_physcannon" ) && ( !IsValid( ent:GetOwner() ) || ( IsValid( ent:GetOwner() ) && ent:GetOwner():IsPlayer() ) ) ) then
			
				ent:Remove()
			
			end
		
		end
	
	end

end
hook.Add( "Think", "hl2cThink", hl2cThink )


if ( !game.SinglePlayer() ) then

	-- Player entered vehicle
	function hl2cPlayerEnteredVehicle( ply, vehicle )
	
		if ( vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then
		
			CITADEL_VEHICLE_ENTITY = vehicle
		
			local viewcontrol = ents.Create( "point_viewcontrol" )
			viewcontrol:SetName( "pod_player_viewcontrol" )
			viewcontrol:SetPos( CITADEL_VEHICLE_ENTITY:GetPos() )
			viewcontrol:SetKeyValue( "spawnflags", "12" )
			viewcontrol:Spawn()
			viewcontrol:Activate()
			viewcontrol:SetParent( CITADEL_VEHICLE_ENTITY )
			viewcontrol:Fire( "SetParentAttachment", "vehicle_driver_eyes" )
			viewcontrol:Fire( "Enable", "", 0.1 )
		
			timer.Create( "hl2cUpdatePlayerPosition", 0.1, 0, hl2cUpdatePlayerPosition )
		
		end
	
	end
	hook.Add( "PlayerEnteredVehicle", "hl2cPlayerEnteredVehicle", hl2cPlayerEnteredVehicle )


	-- Update player position to the vehicle
	function hl2cUpdatePlayerPosition()
	
		for _, ply in ipairs( team.GetPlayers( TEAM_ALIVE ) ) do
		
			if ( IsValid( ply ) && ply:Alive() && IsValid( CITADEL_VEHICLE_ENTITY ) ) then
			
				ply:SetPos( CITADEL_VEHICLE_ENTITY:GetPos() )
			
			end
		
		end
	
	end

end
