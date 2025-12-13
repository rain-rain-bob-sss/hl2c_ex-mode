NEXT_MAP = "d1_town_01"

TRIGGER_CHECKPOINT = {
	{ Vector( -1939, 1833, -2736 ), Vector( -1897, 2001, -2629 ) }
}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


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


-- Accept input
function hl2cAcceptInput( ent, input, activator )

	if !GAMEMODE.EXMode and !game.SinglePlayer() then
		if (ent:GetName() == "airlock_south_door_exit") or ent:GetName() == "airlock_south_door_exitb" and string.lower( input ) == "close" then 
			return true
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "command_physcannon" ) && ( string.lower( input ) == "command" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:Give( "weapon_physcannon" )
		
		end
	
	end

	if GAMEMODE.EXMode then
		local entname = ent:GetName()
		
		if entname == "lcs_alyxtour04b" and string.lower(input) == "start" then
			timer.Simple(3, function() PrintMessage(3, "Chapter 5a") end)
			timer.Simple(6.5, function() PrintMessage(3, "The impending doom") end)
		end

		if entname == "lcs_gravgun01" and input:lower() == "start" then
			GAMEMODE:ReplaceSpawnPoint(Vector(-600, 774, -2684), -90)
			for _,ply in ipairs(player.GetAll()) do
				ply:SetPos(Vector(-600, 774, -2684))
				ply:SetEyeAngles(Angle(0, -90, 0))
			end
		end

		if entname == "lcs_attack02" and input:lower() == "start" then
			GAMEMODE:ReplaceSpawnPoint(Vector(-564, 1024, -2684), 180)
			for _,ply in ipairs(player.GetAll()) do
				ply:SetPos(Vector(-564, 1024, -2684))
				ply:SetEyeAngles(Angle(0, 180, 0))
			end
		end

		if entname == "logic_disable_airlockB_1" and string.lower(input) == "enablerefire" then
			ents.FindByName("alyx")[1]:Ignite(5)
		end

		if entname == "monitor_airlock_south" and string.lower(input) == "disable" then
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
		if string.sub(entname, 1, #s) == s and input:lower()=="playsound" then
			PrintMessage(3, "YOU FUCKED UP")
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


