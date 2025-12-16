ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_08"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
