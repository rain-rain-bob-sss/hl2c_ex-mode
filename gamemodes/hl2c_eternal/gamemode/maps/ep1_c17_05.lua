NEXT_MAP = "ep1_c17_06"

TRIGGER_DELAYMAPLOAD = {Vector(9888, 9664, -736), Vector(9632, 9536, -512)} -- Skip this map.

-- TRIGGER_CHECKPOINT = {
	-- {Vector(1088, 1974, -256), Vector(1216, 1942, -144), -90}
-- }

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
	ply:Give("weapon_pistol")
	ply:Give("weapon_shotgun")
	ply:Give("weapon_smg1")
	ply:Give("weapon_ar2")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )

function hl2cPlayerInitialSpawn(ply)
end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )


-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

hook.Add("OnMapCompleted", "hl2ceOnMapCompleted", function()
	PrintMessage(3, "Fuck this map.")
end)

