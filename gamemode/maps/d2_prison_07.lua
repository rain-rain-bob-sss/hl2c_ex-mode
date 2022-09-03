NEXT_MAP = "d2_prison_08"


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

	timer.Create( "hl2cTurretRelationship", 1, 0, function() if ( IsValid( ents.FindByName( "relationship_turret_vs_player_like" )[ 1 ] ) ) then ents.FindByName( "relationship_turret_vs_player_like" )[ 1 ]:Fire( "ApplyRelationship" ); end; end )

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "door_croom2_gate" ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "logic_room5_entry" ) && ( string.lower( input ) == "trigger" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( 4161, -3966, -519 ) )
			ply:SetEyeAngles( Angle( 0, -90, 0 ) )
		
		end
		GAMEMODE:CreateSpawnPoint( Vector( 4710, -4237, -524 ), 180 )
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
