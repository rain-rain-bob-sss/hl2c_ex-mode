NEXT_MAP = "d3_citadel_02"

NEXT_MAP_PERCENT = 1

CITADEL_VEHICLE_ENTITY = nil


-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_shotgun" )
	ply:Give( "weapon_ar2" )
	ply:Give( "weapon_rpg" )
	ply:Give( "weapon_crossbow" )
	ply:Give( "weapon_bugbait" )

	if ( !game.SinglePlayer() && IsValid( PLAYER_VIEWCONTROL ) && ( PLAYER_VIEWCONTROL:GetClass() == "point_viewcontrol" ) ) then
		ply:SetViewEntity( PLAYER_VIEWCONTROL )
		ply:SetNoDraw( true )
		ply:DrawWorldModel( false )
		ply:Lock()
	
		ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
		ply:CollisionRulesChanged()
	end
end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)

function hl2cEX_PlayerInitialSpawn(ply)
	if !GAMEMODE.EXMode then return end
	timer.Simple(2, function()
		if !ply:IsValid() then return end
		ply:PrintMessage(HUD_PRINTTALK, "Gimnick of the map: Don't take any damage. Beware.")
		timer.Simple(3, function()
			if !ply:IsValid() then return end
			ply:PrintMessage(HUD_PRINTTALK, "Chapter 12")
			timer.Simple(2.5, function()
				if !ply:IsValid() then return end
				ply:PrintMessage(HUD_PRINTTALK, "???????")
			end)
		end)
	end)

end
hook.Add("PlayerInitialSpawn", "hl2cEX_InitialSpawn", hl2cEX_PlayerInitialSpawn)

hook.Add("EntityTakeDamage", "hl2cEX_gimnick", function(target, dmginfo)
	if !GAMEMODE.EXMode then return end
	if target:IsPlayer() then
		dmginfo:SetDamage(1000)
	end
	dmginfo:SetDamageType(DMG_DISSOLVE)
end, HOOK_LOW)


-- Initialize entities
function hl2cMapEdit()
	ents.FindByName("global_newgame_template_ammo" )[1]:Remove()
	ents.FindByName("global_newgame_template_base_items" )[1]:Remove()
	ents.FindByName("global_newgame_template_local_items" )[1]:Remove()

	if GAMEMODE.EXMode then
		local ent = ents.Create("npc_combine_s")
		ent:SetPos(Vector(10094,3364,-1470))
		ent:SetAngles(Angle(0,180,0))
		ent:Give("weapon_ar2")
		ent:Spawn()
	end
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

	if ( !game.SinglePlayer() && ( ent:GetName() == "zapper_fade" ) && ( string.lower( input ) == "fade" ) ) then
	
		hook.Call( "RestartMap", GAMEMODE )
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )


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
