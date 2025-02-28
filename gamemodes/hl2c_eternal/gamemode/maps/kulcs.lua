NEXT_MAP = "d1_trainstation_02"
FORCE_PLAYER_RESPAWNING = true
FORCE_DIFFICULTY = 666666666

if CLIENT then return end

hook.Add("PlayerSpawn", "hl2cPlayerSpawn", function(ply)
    ply:ChatPrint("stop exploring this")
    ply:ChatPrint("launch tf2 and connect to 79.127.217.197:22912")
    ply:ChatPrint("or connect to 79.127.217.197:22913 for sourcetv")
    ply:ChatPrint("goodbye.")
	ply:Give("weapon_crowbar")
    ply:SetWalkSpeed(250)
    ply:SetRunSpeed(550)
end)

-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

function hl2cAcceptInput(ent, input)
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
