NEXT_MAP = "d1_town_01"

TRIGGER_CHECKPOINT = {
	{ Vector( -1939, 1833, -2736 ), Vector( -1897, 2001, -2629 ) }
}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


local function SpawnNPC(class, pos, ang, func)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if func then
		func(ent)
	end
	ent:Spawn()
	ent:Activate()

	return ent
end



-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "brush_doorAirlock_PClip_2" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

local function SpawnNPC(class, pos, ang, func)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if func then
		func(ent)
	end
	ent:Spawn()
	ent:Activate()

	return ent
end

-- Accept input
function hl2cAcceptInput(ent, input, activator)
	local entname = ent:GetName()
	local inputlower = input:lower()

	if !GAMEMODE.EXMode and !game.SinglePlayer() then
		if (entname == "airlock_south_door_exit") or entname == "airlock_south_door_exitb" and inputlower == "close" then 
			return true
		end
	
	end

	if !game.SinglePlayer() and entname == "command_physcannon" and inputlower == "command" then
		for _, ply in pairs(player.GetLiving()) do
			ply:Give("weapon_physcannon")
		end
	end

	if GAMEMODE.EXMode then
		if entname == "lcs_alyxtour04b" and inputlower == "start" then
			timer.Simple(3, function() PrintMessage(3, "Chapter 5a") end)
			timer.Simple(5.5, function() PrintMessage(3, "The impending doom") end)
		end

		if entname == "lcs_gravgun01" and inputlower == "start" then
			GAMEMODE:ReplaceSpawnPoint(Vector(-600, 774, -2684), -90)
			for _,ply in ipairs(player.GetLiving()) do
				if ply == activator then continue end
				ply:SetPos(Vector(-600, 774, -2684))
				ply:SetEyeAngles(Angle(0, -90, 0))
			end
		end

		if entname == "lcs_al_allright" and inputlower == "start" then
			local eff = EffectData()
			eff:SetOrigin(ents.FindByName("alyx")[1]:GetPos())
			for i=1,10 do
				util.Effect("Explosion", eff)
			end
		end

		if entname == "logic_skip_training" and inputlower == "trigger" then
			local e = ents.FindByName("door_scrapyard_gate")[1]
			local eff = EffectData()
			eff:SetOrigin(e:GetPos())
			for i=1,10 do
				util.Effect("Explosion", eff)
			end
			e:Fire("kill")
		end

		if entname == "lcs_dog_intro" and inputlower == "start" then
			local function func()
				if !IsValid(ent) then return end
				for i=1,16 do
					SpawnNPC("npc_fastzombie", Vector(-1400-(i-1)*75, 1200, -2812), Angle(0,-90,0))
				end
			end

			PrintMessage(3, ">:))))))")

			timer.Simple(6, func)
			timer.Simple(36, func)
			timer.Simple(66, func)
			timer.Simple(96, func)
			timer.Simple(126, func)
			timer.Simple(156, func)
		end

		if entname == "lcs_attack02" and inputlower == "start" then
			GAMEMODE:ReplaceSpawnPoint(Vector(-564, 1024, -2684), 180)
			for _,ply in ipairs(player.GetLiving()) do
				if ply == attacker then continue end
				ply:SetPos(Vector(-564, 1024, -2684))
				ply:SetEyeAngles(Angle(0, 180, 0))
			end
		end

		if entname == "logic_disable_airlockB_1" and inputlower == "enablerefire" then
			ents.FindByName("alyx")[1]:Ignite(5)
		end

		if entname == "monitor_airlock_south" and inputlower == "disable" then
			local e = EffectData()
			e:SetOrigin(ent:GetPos())
			for i=1,10 do
				PrintMessage(3, "YOU FUCKED UP")
				util.Effect("Explosion", e)
			end

			timer.Simple(0, function()
				ent:Remove()
			end)

			local function DoIt()
				for i=1,6 do
					SpawnNPC("npc_zombie", Vector(-640 + i*22, 1104, -2684), Angle(0, -90, 0))
				end
			end
			DoIt()
			timer.Simple(3, DoIt)
			timer.Simple(6, DoIt)
		end

		local s = "ambient_attack_explode_"
		if string.sub(entname, 1, #s) == s and inputlower=="playsound" then
			PrintMessage(3, "YOU FUCKED UP")
		end

		if ent:GetClass() == "env_headcrabcanister" and inputlower == "firecanister" then
			PrintMessage(3, "YOU FUCKED UP")
		end

		if ent:GetClass() == "env_explosion" and inputlower == "explode" then
			PrintMessage(3, "YOU FUCKED UP")
		end

		if entname == "relay_found_HEVplate" and inputlower == "trigger" then
			local eff = EffectData()
			eff:SetOrigin(activator:GetPos())
			for i=1,10 do
				util.Effect("Explosion", eff)
			end

			local npc = ents.Create("npc_combine_s")
			npc:SetHealth(500)
			npc:SetMaxHealth(500)
			npc:SetPos(activator:GetPos())
			npc:SetAngles(Angle(0,180,0))
			npc:Give("weapon_ar2")
			npc:Spawn()

			activator:Remove()
		end
	end


end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)

function HL2cEXPreventRollermineDamage(target, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker:GetClass() == "npc_rollermine" and target:IsPlayer() then
		dmginfo:SetDamage(0)
		return true
	end
end
hook.Add("EntityTakeDamage", "HL2cEX_d1_eli_02_rollerminedoesnodamage", HL2cEXPreventRollermineDamage)


