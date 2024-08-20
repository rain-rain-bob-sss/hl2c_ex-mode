NEXT_MAP = "ep1_c17_00a"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

local hastriggered

-- Accept input
function hl2cAcceptInput( ent, input )
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
