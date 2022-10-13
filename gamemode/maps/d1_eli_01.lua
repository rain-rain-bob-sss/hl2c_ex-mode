NEXT_MAP = "d1_eli_02"
GM.XP_REWARD_ON_MAP_COMPLETION = 0

TRIGGER_CHECKPOINT = {
	{ Vector( 364, 1764, -2730 ), Vector( 549, 1787, -2575 ) }
}

TRIGGER_DELAYMAPLOAD = { Vector( -703, 989, -2688 ), Vector( -501, 1029, -2527 ) }


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "pclip_airlock_1_a" )[ 1 ]:Remove()
		ents.FindByName( "brush_exit_door_raven_PClip" )[ 1 ]:Remove()
		ents.FindByName( "pclip_exit_door_raven2" )[ 1 ]:Remove()
		ents.FindByName( "pclip_airlock_2_a" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ( ent:GetName() == "doors_Airlock_Outside" ) || ( ent:GetName() == "inner_door" ) || ( ent:GetName() == "lab_exit_door_raven" ) || ( ent:GetName() == "lab_exit_door_raven2" ) || ( ent:GetName() == "airlock_south_door" ) || ( ent:GetName() == "airlock_south_doorb" ) ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "airlock_door" ) && ( string.lower( input ) == "open" ) ) then
	
		ents.FindByName( "doors_Airlock_Outside" )[ 1 ]:Fire( "Unlock" )
		ents.FindByName( "doors_Airlock_Outside" )[ 1 ]:Fire( "Open" )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_mosstour05" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( 457, 1656, -1267 ) )
			ply:SetEyeAngles( Angle( 0, 90, 0 ) )
		
		end
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
