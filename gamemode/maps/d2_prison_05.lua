INFO_PLAYER_SPAWN = { Vector( 1439, 612, 388 ), 90 }

NEXT_MAP = "d2_prison_06"


-- Player initial spawn
function hl2cPlayerInitialSpawn( ply )

	ply:SendLua( "table.insert( FRIENDLY_NPCS, \"npc_antlion\" )" )

end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )


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

	game.SetGlobalState( "antlion_allied", GLOBAL_ON )

	table.insert( FRIENDLY_NPCS, "npc_antlion" )

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "point_of_no_return" ) && ( string.lower( input ) == "enable" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( -3662, -548, 439 ) )
			ply:SetEyeAngles( Angle( 0, 180, 0 ) )
		
		end
		GAMEMODE:CreateSpawnPoint( Vector( -4650, -745, 641 ), -50 )
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
