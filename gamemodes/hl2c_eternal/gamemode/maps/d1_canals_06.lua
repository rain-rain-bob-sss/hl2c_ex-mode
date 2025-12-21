ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_07"

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

-- Accept input
function hl2cAcceptInput(ent, input)
	if GAMEMODE.EXMode then
		if ent:GetName() == "choreo_gman_overwatch_1" and input:lower() == "start" then
			timer.Simple(1, function()
				PrintMessage(3, "Chapter 4")
			end)
			timer.Simple(4, function()
				PrintMessage(3, "Hazardous radiation levels")
			end)
		end
	end
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
