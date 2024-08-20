NEXT_MAP = "d2_coast_01"

TRIGGER_DELAYMAPLOAD = { Vector( -1723, 10939, 904 ), Vector( -1638, 10995, 1010 ) }

TOWN_CREATE_NEW_SPAWNPOINT = true

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_shotgun" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "player_spawn_template" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "trigger_close_door" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "aisc_attentiontoradio" ) && ( string.lower( input ) == "enable" ) ) then
	
		ents.FindByName( "alyx_camera" )[ 1 ]:Fire( "SetOn" )
		ents.FindByName( "lcs_leon_nag" )[ 1 ]:Fire( "Kill" )
		ents.FindByName( "radio_nag" )[ 1 ]:Fire( "Kill" )
		ents.FindByName( "lcs_leon_radios3" )[ 1 ]:Fire( "Start" )
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "aisc_leon_waits" ) && ( string.lower( input ) == "enable" ) ) then
	
		ents.FindByName( "warehouse_leonleads_lcs" )[ 1 ]:Fire( "Start" )
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "aisc_leaonwait1" ) && ( string.lower( input ) == "enable" ) ) then
	
		ents.FindByName( "warehouse_leonleads_lcs" )[ 1 ]:Fire( "Resume" )
		ents.FindByName( "radio_nag" )[ 1 ]:Fire( "Disable" )
		return true
	
	end

	if ( !game.SinglePlayer() && TOWN_CREATE_NEW_SPAWNPOINT && ( ent:GetName() == "citizen_warehouse_door_1" ) && ( string.lower( input ) == "open" ) ) then
	
		TOWN_CREATE_NEW_SPAWNPOINT = false
		GAMEMODE:CreateSpawnPoint( Vector( -1160, 10122, 908 ), 90 )
	
	end

	if GAMEMODE.EXMode and ent:GetName() == "lcs_leon_radios3" and string.lower(input) == "start" then
		PrintMessage(3, "You may skip this cutscene.")
		local entity = ents.FindByName("citizen_warehouse_door_0")[1]
		if entity and entity:IsValid() then
			entity:Fire("Unlock")
			entity:Fire("Open")
		end
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
