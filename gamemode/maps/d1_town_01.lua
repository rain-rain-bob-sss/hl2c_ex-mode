NEXT_MAP = "d1_town_01a"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )

function hl2cAcceptInput( ent, input )

	if GAMEMODE.EXMode then
		timer.Create("Hl2c_EX_input1", 0.325, 0, function()
			if (IsValid(ents.FindByName("grigori_pyre_script_door_1")[1])) then ents.FindByName("grigori_pyre_script_door_1")[1]:Fire("Toggle") end
		end)
		timer.Create("Hl2c_EX_input2", 5, 0, function()
			if (IsValid(ents.FindByName("crushtrap_02_switch_01")[1])) then ents.FindByName("crushtrap_02_switch_01")[1]:Use(game.GetWorld()) end
		end)
	end
	
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "player_spawn_template" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
