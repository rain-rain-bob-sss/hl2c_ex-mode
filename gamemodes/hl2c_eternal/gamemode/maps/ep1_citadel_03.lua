NEXT_MAP = "ep1_citadel_04"
GM.XpGainOnNPCKillMul = 0.35
GM.DifficultyGainOnNPCKillMul = 0.5


-- TRIGGER_CHECKPOINT = {
	-- { Vector( 364, 1764, -2730 ), Vector( 549, 1787, -2575 ) }
-- }

-- TRIGGER_DELAYMAPLOAD = { Vector( 5120, 4840, -6720 ), Vector( 5136, 4480, -6480) }

INFO_PLAYER_SPAWN = { Vector( -714, 12184, 5368 ) , 0}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)
	ply:Give("weapon_physcannon")
end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


hook.Add("Think", "hl2cThink", function()
	if game.GetGlobalState("super_phys_gun") == GLOBAL_ON then
		for _, ent in pairs( ents.FindByClass( "weapon_*" ) ) do
			if ( IsValid( ent ) && ent:IsWeapon() && ( ent:GetClass() != "weapon_physcannon" ) && ( !IsValid( ent:GetOwner() ) || ( IsValid( ent:GetOwner() ) && ent:GetOwner():IsPlayer() ) ) ) then
				ent:Remove()
			end
		end
	end
end)

-- Initialize entities
function hl2cMapEdit()

	game.SetGlobalState( "super_phys_gun", GLOBAL_ON )

	-- ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	-- ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	-- ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

-- Accept input
function hl2cAcceptInput(ent, input)
	if ent:GetName() == "beam_core_death" and string.lower(input) == "turnon" then
		timer.Create("ep1_citadel_03_deathbeam_off", 1, 1, function()
			ent:Fire("turnoff")
		end)
	end
	if ent:GetName() == "super_phys_gun" and string.lower(input) == "turnoff" then
		for _,ply in ipairs(player.GetAll()) do
			ply:SetArmor(0)
		end
	end
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)


local combinekilled = 0
function hl2cOnNPCKilled( ent, attacker, wep )
	local entname = ent:GetName()
	if entname == "npc_elite_controltype_1" or entname == "npc_elite_controltype_2" or entname == "npc_elite_controlroom" then
		combinekilled = combinekilled + 1
		print(combinekilled)

		if combinekilled == 5 then
			ents.FindByName("alyx")[1]:SetPos(Vector(1672, 12130, 5316))
		end
	end
end
hook.Add( "OnNPCKilled", "hl2cOnNPCKilled", hl2cOnNPCKilled )


