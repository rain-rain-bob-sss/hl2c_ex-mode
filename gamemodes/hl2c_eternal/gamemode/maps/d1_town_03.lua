NEXT_MAP = "d1_town_02"

TRIGGER_DELAYMAPLOAD = { Vector( -3801, -65, -3457 ), Vector( -3719, -7, -3335 ) }

if CLIENT then return end

if ( !file.Exists( "hl2c_eternal/d1_town_03.txt", "DATA" ) ) then

	file.Write( "hl2c_eternal/d1_town_03.txt", "We have been to d1_town_03." )

end


-- Player spawns
function hl2cPlayerSpawn(ply)

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_shotgun" )

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "startobjects_template" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
