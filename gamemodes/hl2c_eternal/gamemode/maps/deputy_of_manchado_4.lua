-- Why is this here?!

NEXT_MAP = "d1_trainstation_01"

OVERRIDE_PLAYER_RESPAWNING = true

MAP_FORCE_NO_FRIENDLIES = true

FORCE_DIFFICULTY = 1.5

if CLIENT then return end

-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

function hl2cAcceptInput(ent, input)
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
