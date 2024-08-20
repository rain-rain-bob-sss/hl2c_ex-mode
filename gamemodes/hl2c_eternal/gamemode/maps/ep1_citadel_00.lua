NEXT_MAP = "ep1_citadel_01"
GM.XP_REWARD_ON_MAP_COMPLETION = 0

TRIGGER_CHECKPOINT = {
	{ Vector( -8922, 5856, -144 ), Vector( -9106, 5744, 8 ) },
	{ Vector( -6720, 5572, -124 ), Vector( -6890, 5512, 0 ) },
	-- { Vector( 4318, 4288, -6344 ), Vector( 4064, 3936, -5944 ) }
}

MAP_FORCE_CHANGELEVEL_ON_MAPRESTART = true

if CLIENT then return end

function hl2cPlayerSpawn( ply )
	-- ply:Freeze(true)
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )

function hl2cMapEdit()
    ents.FindByName("trigger_falldeath")[1]:Remove()
end
hook.Add("MapEdit", "hl2cMapEdit", hl2cMapEdit)

local allowunlock
function hl2cAcceptInput(ent, input)
    if !game.SinglePlayer() and string.lower(input) == "scriptplayerdeath" then -- Can break the sequences
        return true
    end

    if ent:GetName() == "relay_givegravgun_1" and string.lower(input) == "trigger" then
        for _,ply in pairs(player.GetAll()) do
            ply:Give("weapon_physcannon")
        end
    end

    if !game.SinglePlayer() and ent:GetName() == "lcs_al_vanride_end01" and string.lower(input) == "start" then
        for _,ply in pairs(player.GetAll()) do
            -- ply:ExitVehicle()
            if not ply:InVehicle() then
                ply:SetPos(Vector(4624, 4116, -6342))
                ply:SetEyeAngles(Angle(0, -90, 0))
            end
        end

        GAMEMODE:CreateSpawnPoint( Vector( 4624, 4116, -6342 ), -90 )

        local entity = ents.FindByName("van")[1]
        if entity and entity:IsValid() then
            entity:Fire("lock")
            -- entity:Fire("kill")
        end

        allowunlock = true
    end

    if !game.SinglePlayer() and string.lower(ent:GetName()) == "van" and string.lower(input) == "unlock" and allowunlock then
        for _,ply in pairs(player.GetAll()) do
            if ply:InVehicle() then
                ply:ExitVehicle()
            end
        end
    end
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)

