ALLOWED_VEHICLE = "Airboat"

INFO_PLAYER_SPAWN = { Vector( 7512, -11398, -438 ), 0 }

NEXT_MAP = "d1_canals_09"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()
	if ( !game.SinglePlayer() ) then ents.FindByName( "trigger_close_gates" )[ 1 ]:Remove(); end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
