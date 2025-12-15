ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_10"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

function hl2cAcceptInput(ent, input, activator)
	if !GAMEMODE.EXMode then return end

	if ent:GetName() == "music_canals_bombingrun" and input:lower() == "playsound" then
		local e = ents.FindByName("heli_1")[1]

		timer.Simple(5, function()
			timer.Simple(0, function() e:EmitSound("npc/attack_helicopter/aheli_megabomb_siren1.wav", 130, 100) end)
			timer.Simple(0.15, function() e:EmitSound("npc/attack_helicopter/aheli_megabomb_siren1.wav", 130, 100) end)
			timer.Simple(0.3, function() e:EmitSound("npc/attack_helicopter/aheli_megabomb_siren1.wav", 130, 100) end)
			timer.Simple(0.45, function() e:EmitSound("npc/attack_helicopter/aheli_megabomb_siren1.wav", 130, 100) end)

			timer.Simple(1, function() e:Fire("startcarpetbombing") end)
		end)
	end
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
