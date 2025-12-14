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


	if ent:GetName() == "start_music" and input:lower() == "playsound" then
		timer.Simple(2, function() PrintMessage(3, "Chapter 6") end)
		timer.Simple(4, function()
			local s = "WELCOMETOHELL"
			for i=1,#s do
				timer.Simple(i*0.1, function()
					PrintMessage(3, s[i])
				end)
			end
		end)
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "player_spawn_template" )[ 1 ]:Remove()
	
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

hook.Add("EntityTakeDamage", "hl2cEntityTakeDamage", function(ent, dmginfo)
	if !GAMEMODE.EXMode then return end
	if !ent:IsPlayer() then return end
	dmginfo:ScaleDamage(5)
end)

