NEXT_MAP = "d1_town_04"

if CLIENT then return end

local function SpawnNPC(class, pos, ang, func)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if func then
		func(ent)
	end
	ent:Spawn()

	return ent
end

if file.Exists("hl2c_eternal/d1_town_03.txt", "DATA") then
	file.Delete( "hl2c_eternal/d1_town_03.txt" )
end


-- Player spawns
function hl2cPlayerSpawn(ply)

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_shotgun" )

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "startobjects_template" )[ 1 ]:Remove()

	local monk = ents.Create( "npc_monk" )
	monk:SetPos( Vector( -5221, 2034, -3240 ) )
	monk:SetAngles( Angle( 0, 90, 0 ) )
	monk:SetName( "monk" )
	monk:SetKeyValue( "additionalequipment", "weapon_annabelle" )
	monk:SetKeyValue( "spawnflags", "4" )
	monk:Spawn()
	monk:Activate()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "graveyard_exit_momentary_wheel" )[ 1 ]:Fire( "Lock" )
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput(ent, input)
	local entname = ent:GetName()
	local inputlower = input:lower()

	if ( !game.SinglePlayer() && ( ent:GetName() == "graveyard_exit_door" ) && ( string.lower(input) == "setposition" ) ) then
	
		ent:Fire( "Open" )
		return true
	
	end

	if GAMEMODE.EXMode then
		if entname == "graveyard_fz_1_seq" and inputlower == "beginsequence" then
			for i=1,20 do
				SpawnNPC("npc_fastzombie", Vector(-7250-(i-1)*30, 2000-(i-1)*30, -2800), Angle(0,-45,0), function(ent)
					local enemy = ents.FindByName("monk")[1]
					ent:SetEnemy(enemy)
					ent:UpdateEnemyMemory(enemy, enemy:GetPos())

					timer.Simple(10, function()
						if !IsValid(ent) then return end

						local enemy = ents.FindByName("monk")[1]
						ent:SetEnemy(enemy)
						ent:UpdateEnemyMemory(enemy, enemy:GetPos())
					end)
				end)
			end

			PrintMessage(3, "Guard Father Grigori... OR YOU FAIL!")
		end

		if entname == "graveyard_zombies_sched" and inputlower == "startschedule" then
		end

		if entname == "graveyard_monk_scene_b4" and inputlower == "start" then
			for i=1,10 do
				SpawnNPC("npc_poisonzombie", Vector(-7960+(i-1)*40, 1024, -3400), Angle(0, -90, 0), function(ent)
					ent:SetHealth(2^128)
				end)
			end
		end
	end

end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
