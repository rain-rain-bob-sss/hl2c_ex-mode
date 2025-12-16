NEXT_MAP = "ep1_c17_02b"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)
	ply:Give("weapon_physcannon")
	ply:Give("weapon_pistol")
	ply:Give("weapon_shotgun")
	ply:Give("weapon_smg1")
	ply:Give("weapon_frag")
end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)

function hl2cPlayerInitialSpawn(ply)
end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )


-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

local hastriggered

-- Accept input
function hl2cAcceptInput(ent, input)
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
