INFO_PLAYER_SPAWN = { Vector( -2489, -1292, 580 ), 90 }
GM.XpGainOnNPCKillMul = 0.35
GM.DifficultyGainOnNPCKillMul = 0.5

NEXT_MAP_PERCENT = 101

RESET_WEAPONS = true

TRIGGER_DELAYMAPLOAD = { Vector( 14095, 15311, 14964 ), Vector( 13702, 14514, 15000 ) }

if ( PLAY_EPISODE_1 ) then

	NEXT_MAP = "ep1_citadel_00"

else

	NEXT_MAP = "d1_trainstation_01"

end

OVERRIDE_PLAYER_RESPAWNING = true

CITADEL_ENDING = false

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	if ( !game.SinglePlayer() && CITADEL_ENDING ) then
	
		ply:RemoveAllItems()
		ply:Freeze( true )
	
	end

	if ( !game.SinglePlayer() && IsValid( PLAYER_VIEWCONTROL ) && ( PLAYER_VIEWCONTROL:GetClass() == "point_viewcontrol" ) ) then
	
		ply:SetViewEntity( PLAYER_VIEWCONTROL )
		ply:SetNoDraw( true )
		ply:DrawWorldModel( false )
		ply:Freeze( true )
	
		timer.Simple( 0.01, function() if ( IsValid( ply ) ) then ply:SetMoveType( MOVETYPE_NOCLIP ); end; end )
	
	end

	if ( game.SinglePlayer() && IsValid( ents.FindByName( "pod" )[ 1 ] ) ) then
	
		ply:EnterVehicle( ents.FindByName( "pod" )[ 1 ] )
	
	end

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


hook.Add("NextMap", "hl2cEX_NextMap", function()
	if changingLevel then return end
	for _,ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTTALK, "Congratulations, you have completed the campaign!")
		ply:GiveXP(40000)
	end
end)

-- Initialize entities
function hl2cMapEdit()

	game.SetGlobalState( "super_phys_gun", GLOBAL_ON )

	game.ConsoleCommand( "physcannon_tracelength 850\n" )
	game.ConsoleCommand( "physcannon_maxmass 850\n" )
	game.ConsoleCommand( "physcannon_pullforce 8000\n" )

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "citadel_template_combinewall_start1" )[ 1 ]:Remove()
	
		local viewcontrol = ents.Create( "point_viewcontrol" )
		viewcontrol:SetName( "pod_viewcontrol" )
		viewcontrol:SetPos( ents.FindByName( "pod" )[ 1 ]:GetPos() )
		viewcontrol:SetKeyValue( "spawnflags", "12" )
		viewcontrol:Spawn()
		viewcontrol:Activate()
		viewcontrol:SetParent( ents.FindByName( "pod" )[ 1 ] )
		viewcontrol:Fire( "SetParentAttachment", "vehicle_driver_eyes" )
		viewcontrol:Fire( "Enable", "", 0.1 )
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input, activator, caller, value )

	if ( !game.SinglePlayer() && ( ent:GetClass() == "point_viewcontrol" ) ) then
	
		if ( ent:GetName() == "blackout_viewcontroller" ) then
		
			return true
		
		end
	
		if ( string.lower( input ) == "enable" ) then
		
			PLAYER_VIEWCONTROL = ent
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ent )
				ply:SetNoDraw( true )
				ply:DrawWorldModel( false )
				ply:Freeze( true )
			
				timer.Simple( 0.01, function() if ( IsValid( ply ) ) then ply:SetMoveType( MOVETYPE_NOCLIP ); end; end )
			
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
				ply:Freeze( false )
				ply:UnLock()
			
				timer.Simple( 0.01, function() if ( IsValid( ply ) ) then ply:SetMoveType( MOVETYPE_WALK ); end; end )
			
			end
		
			return true
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "logic_fade_view" ) && ( string.lower( input ) == "trigger" ) ) then
	
		if ( timer.Exists( "hl2cUpdatePlayerPosition" ) ) then timer.Destroy( "hl2cUpdatePlayerPosition" ); end
	
		GAMEMODE:CreateSpawnPoint( Vector( -1875, 887, 591 ), 265.5 )
	
		PLAYER_VIEWCONTROL:Fire( "Disable" )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "clip_door_BreenElevator" ) && ( string.lower( input ) == "enable" ) ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( -1968, 0, 600 ) )
			ply:SetEyeAngles( Angle( 0, -90, 0 ) )
		
		end
		GAMEMODE:CreateSpawnPoint( Vector( -1860, 0, 1380 ), 0 )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_al_doworst" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( -1056, 464, 1340 ) )
			ply:SetEyeAngles( Angle( 0, -90, 0 ) )
		
		end
		GAMEMODE:CreateSpawnPoint( Vector( -1056, 300, -200 ), -90 )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "citadel_scene_al_rift1" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( -640, -400, 1320 ) )
			ply:SetEyeAngles( Angle( 0, 35, 0 ) )
			for i,v in ipairs(player.GetAll())do v:Give("weapon_hl2ce_medkit") end
		
		end
		GAMEMODE:CreateSpawnPoint( Vector( -640, -400, 1320 ), 35 )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "relay_portalfinalexplodeshake" ) && ( string.lower( input ) == "trigger" ) ) then
	
		game.SetGlobalState("super_phys_gun", GLOBAL_OFF)

		game.ConsoleCommand( "physcannon_tracelength 250\n" )
		game.ConsoleCommand( "physcannon_maxmass 250\n" )
		game.ConsoleCommand( "physcannon_pullforce 4000\n" )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "relay_breenwins" ) && ( string.lower( input ) == "trigger" ) ) then
	
		gamemode.Call("RestartMap")
		PrintMessage(3, "You failed to complete this map. (Dr. Breen has escaped)")
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "teleport_player_gman_1" ) && ( string.lower( input ) == "teleport" ) ) then
	
		CITADEL_ENDING = true
	
		for _, ply in ipairs( player.GetAll() ) do
		
			ply:RemoveAllItems()
			ply:SetNoDraw( true )
			ply:SetPos( ent:GetPos() )
			ply:Freeze( true )
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "view_gman_end_1" ) && ( string.lower( input ) == "enable" ) ) then
	
		hook.Call( "NextMap", GAMEMODE )

		for _,ply in pairs(player.GetAll()) do
			gamemode.Call("PlayerCompletedCampaign", ply)
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetClass() == "player_speedmod" ) && ( string.lower( input ) == "modifyspeed" ) ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			ply:SetLaggedMovementValue( tonumber( value ) )
		
		end
	
		return true
	
	end

	if ent:GetClass() == "citadel_scene_br_dead1" and string.lower(input) == "trigger" then
	end

	if ent:GetClass() == "logic_portal_final_end_2" and string.lower(input) == "trigger" then
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )


-- Every frame or tick
function hl2cThink()

	if game.GetGlobalState("super_phys_gun") == GLOBAL_ON then
	
		for _, ent in ipairs( ents.FindByClass( "weapon_physcannon" ) ) do
		
			if ( IsValid( ent ) && ent:IsWeapon() ) then
			
				if ( ent:GetSkin() != 1 ) then ent:SetSkin( 1 ); end
			
			end
		
		end
	
		for _, ent in ipairs( ents.FindByClass( "weapon_*" ) ) do
		
			if ( IsValid( ent ) && ent:IsWeapon() && ( ent:GetClass() != "weapon_physcannon" ) && ( !IsValid( ent:GetOwner() ) || ( IsValid( ent:GetOwner() ) && ent:GetOwner():IsPlayer() ) ) ) then
			
				if not ent.CanUseInCitadel then
					ent:Remove()
				end
			
			end
		
		end
	
	end

end
hook.Add( "Think", "hl2cThink", hl2cThink )


if ( !game.SinglePlayer() ) then

	-- Update player position to the vehicle
	function hl2cUpdatePlayerPosition()
	
		for _, ply in ipairs( team.GetPlayers( TEAM_ALIVE ) ) do
		
			if ( IsValid( ply ) && IsValid( ents.FindByName( "pod" )[ 1 ] ) && ply:Alive() ) then
				if not ply.DebugMode then
					ply:SetPos( ents.FindByName( "pod" )[ 1 ]:GetPos() )
				end
			
			end
		
		end
	
	end
	timer.Create( "hl2cUpdatePlayerPosition", 0.1, 0, hl2cUpdatePlayerPosition )

end
