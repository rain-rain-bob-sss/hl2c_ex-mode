
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

if CLIENT then

	net.Receive("hl2ce_music", function()
		local bool = net.ReadBool()
		local sound = "#hl2c_eternal/music/zombie_survival.wav"
		local ply = LocalPlayer()

		if bool then
			ply:EmitSound(sound, 0, 100, 1, CHAN_STATIC, SND_DELAY, 0)
		else
			ply:EmitSound(sound, 0, 100, 0, CHAN_STATIC, SND_DELAY + SND_STOP, 0)
		end
	end)
end

if ( file.Exists( "hl2c_eternal/d1_town_03.txt", "DATA" ) ) then

	INFO_PLAYER_SPAWN = { Vector( -3755, -28, -3366 ), 45 }

	NEXT_MAP = "d1_town_02a"

	if CLIENT then return end

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


	function hl2cAcceptInput(ent, input, activator)
		local entname = ent:GetName()
		local inputlower = input:lower()

		if entname == "rooftop_save" and inputlower == "save" then
			local e1 = ents.FindByName("cavezombies_1_case")[1]
			local e2 = ents.FindByName("cavezombies_2_case")[1]

			for i=1,10 do
				e1:Fire("pickrandom", nil, i*10)
				e2:Fire("pickrandom", nil, i*10+5)
			end

			net.Start("hl2ce_music")
			net.WriteBool(true)
			net.Broadcast()
		end

		if entname == "monk_church_scene_a1" and inputlower == "start" then
			for _,ply in ipairs(player.GetLiving()) do
				if ply == activator then continue end

				ply:SetPos(Vector(-4700, 490, -3260))
				ply:SetEyeAngles(Angle(0,90,0))
				ply:SetVelocity(-ply:GetVelocity())
			end

			net.Start("hl2ce_music")
			net.WriteBool(false)
			net.Broadcast()

			local e1 = ents.FindByName("cavezombies_1_case")[1]
			local e2 = ents.FindByName("cavezombies_2_case")[1]

			e1:Fire("kill")
			e2:Fire("kill")

			for _,ent in ipairs(ents.FindByClass("npc_fastzombie")) do
				ent:Ignite(1000)
			end
		end

		if entname == "cavezombies_away_timer" and inputlower == "kill" then
		end

		local function func(ent)
			local pl = table.Random(player.GetLiving())
			ent:SetEnemy(pl)
			ent:UpdateEnemyMemory(pl, pl:GetPos())
		end
		if entname == "cavezombies_1_case" and inputlower == "pickrandom" then
			for i=1,3 do
				func(SpawnNPC("npc_fastzombie", Vector(-4520+(i-1)*40, -690, -3126), Angle(0,90,0)))
			end
		end
		if entname == "cavezombies_2_case" and inputlower == "pickrandom" then
			for i=1,3 do
				func(SpawnNPC("npc_fastzombie", Vector(-4520+(i-1)*40, -650, -3126), Angle(0,90,0)))
			end
		end
	end
	hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)

else

	NEXT_MAP = "d1_town_03"

	if CLIENT then return end

	-- Player spawns
	function hl2cPlayerSpawn(ply)
	
		ply:Give( "weapon_crowbar" )
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_smg1" )
		ply:Give( "weapon_357" )
		ply:Give( "weapon_frag" )
		ply:Give( "weapon_physcannon" )
	
	end
	hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)
	
	
	-- Accept input
	function hl2cAcceptInput(ent, input, activator)
		local entname = ent:GetName()
		local inputlower = input:lower()


		if ( !game.SinglePlayer() && ( ent:GetName() == "freightlift_lift" ) && ( string.lower(input) == "startforward" ) ) then
		
			for _, ply in pairs( player.GetLiving() ) do
				if ply == activator then continue end
				ply:SetVelocity( Vector( 0, 0, 0 ) )
				ply:SetPos( Vector( -2943, 896, -3136 ) )
			
			end
			GAMEMODE:CreateSpawnPoint( Vector( -2944, 1071, -3520 ), -90 )

		end
	end
	hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)

end


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "startobjects_template" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
