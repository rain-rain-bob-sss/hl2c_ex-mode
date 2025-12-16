NEXT_MAP = "d3_c17_07"

TRIGGER_CHECKPOINT = {
	{ Vector( 3537, 1539, 256 ), Vector( 3616, 1581, 349 ) }
}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)

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
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "player_spawn_template" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
