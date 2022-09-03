NEXT_MAP = "d3_c17_02"


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

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input, activator, caller, value )

	if ( !game.SinglePlayer() && ( ent:GetName() == "door_klab01" ) && ( string.lower( input ) == "setanimation" ) && ( string.lower( value ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ( ent:GetName() == "doors_elevator_1" ) || ( ent:GetName() == "doors_elevator_2" ) ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ( ent:GetName() == "pclip_TPdoor" ) || ( ent:GetName() == "pclip_exitdoor" ) ) && ( string.lower( input ) == "enable" ) ) then
	
		return true
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
