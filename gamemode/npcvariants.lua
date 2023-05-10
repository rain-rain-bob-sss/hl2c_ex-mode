function AntlionGuardAURA()
	for k,ent in pairs(ents.FindByClass("npc_antlionguard")) do
		if !ent:IsValid() or ent.VariantType != 5 or ent:Health() < 0 then continue end 
		local effectdata = EffectData()
		ent:SetHealth(math.Clamp(ent:Health() + 3, 0, ent:GetMaxHealth()))
		if !timer.Exists("NPC_ANTLIONGUARD_AURA_FX") then
			timer.Create("NPC_ANTLIONGUARD_AURA_FX", 2, 1, function()
				if !ent:IsValid() then return end
				ent:EmitSound("ambient/machines/thumper_hit.wav", 120, 70)
				effectdata:SetOrigin(ent:GetPos() + Vector(0, 0, 60))
				util.Effect("zw_master_strike", effectdata)
			end)
		end

		for k,v in pairs(ents.FindInSphere(ent:GetPos(), 200)) do
			if (v:GetClass() == "npc_antlion" or v:GetClass() == "npc_antlion_worker") and v:IsNPC() then 
				v:SetHealth(math.Clamp(v:Health() + 10, 0, v:GetMaxHealth()))
				effectdata:SetOrigin(v:GetPos() + Vector(0, 0, 60))
				util.Effect("zw_master_strike", effectdata)
			elseif (v:IsNPC() or v:IsPlayer()) && v:GetClass() != "npc_antlionguard" then
				if v:Health() < 0 then return end
				v:TakeDamage(1, ent)
				if v:IsPlayer() and v:Alive() then
					v:PrintMessage(4, "YOU ARE BEING DAMAGED BY ANTLION GUARD VARIANT,\nGET AWAY FROM IT!!")
				end
				effectdata:SetOrigin(v:GetPos() + Vector(0, 0, 60))
				util.Effect("zw_master_strike", effectdata)
			end 
		end 
	end
end

function HL2cEX_NPCVariantSpawn(ent)
	if !GAMEMODE.EXMode or !ent:IsNPC() then return end

	ent.VariantType = math.random(1,2)
	if ent:GetClass() == "npc_metropolice" then
		if ent.VariantType == 1 then
			ent.ent_Color = Color(128,128,255)
			ent.ent_MaxHealthMul = 1.3
			ent.ent_HealthMul = 1.3
		end
	elseif ent:GetClass() == "npc_combine_s" then
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
			ent.ent_MaxHealthMul = 0.4
			ent.ent_HealthMul = 0.4

		elseif ent.VariantType == 2 then
			ent.ent_MaxHealthMul = 1.2
			ent.ent_HealthMul = 1.2
		end
	elseif ent:GetClass() == "npc_zombie" then
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
			ent.ent_MaxHealthMul = 0.6
			ent.ent_HealthMul = 0.6
		end
	elseif ent:GetClass() == "npc_fastzombie" then
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
			ent.ent_MaxHealthMul = 0.7
			ent.ent_HealthMul = 0.7
		end
	elseif ent:GetClass() == "npc_antlionguard" then
		ent.VariantType = math.random(1,5) --make medical antlion guard variant less common
		if ent.VariantType == 5 then
			ent.ent_Color = Color(0,255,0)
			ent.ent_MaxHealthMul = 2
			ent.ent_HealthMul = 2
		end
	elseif ent:GetClass() == "npc_cscanner" or ent:GetClass() == "npc_clawscanner" then
		if ent.VariantType == 1 then
			ent.ent_color = Color(255,128,128)
		end
	elseif ent:GetClass() == "npc_barnacle" then
		if ent.VariantType == 1 then
			ent.ent_MaxHealthMul = 0.6
			ent.ent_HealthMul = 0.6
			ent.ent_Color = Color(255,128,128)
		else
			ent.ent_MaxHealthMul = 1.5
			ent.ent_HealthMul = 1.5
		end
	end

	timer.Simple(0, function()
		if ent.ent_MaxHealthMul then
			ent:SetMaxHealth(ent.ent_MaxHealthMul * ent:Health())
		end
		if ent.ent_HealthMul then
			ent:SetHealth(ent.ent_HealthMul * ent:Health())
		end
		if ent.ent_Color then
			ent:SetColor(ent.ent_Color)
		end
	end)
end
hook.Add("OnEntityCreated", "HL2cEX_NPCVariantsSpawned", HL2cEX_NPCVariantSpawn, HOOK_HIGH)

function HL2cEX_NPCVariantKilled(ent)
	if !GAMEMODE.EXMode then return end
	if ent:GetClass() == "npc_zombie" then
		if ent.VariantType == 1 then
			local entdrop = ents.Create("npc_handgrenade")
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 30))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
			local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos() + Vector(0, 0, 60))
			util.Effect("zw_master_strike", effectdata)
			ent:EmitSound("ambient/machines/thumper_hit.wav", 120, 70)
		elseif ent.VariantType == 2 and math.random(1,100) < 35 then
			local entdrop = ents.Create("npc_headcrab")
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 10))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
		end
	elseif ent:GetClass() == "npc_fastzombie" then
		if ent.VariantType == 1 and math.random(1,100) < 15 then
			local entdrop = ents.Create("npc_headcrab_fast")
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 10))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
		end
	elseif ent:GetClass() == "npc_metropolice" then
		if ent.VariantType == 2 and math.random(1,100) < 40 then
			local entdrop = ents.Create("npc_manhack")
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 50))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
		end
		
	elseif ent:GetClass() == "npc_antlionguard" then
		if ent.VariantType == 5 then
			local entdrop = ents.Create("weapon_hl2ce_medkit")
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 50))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
		end
	elseif ent:GetClass() == "npc_poisonzombie" then
		if ent.VariantType == 1 then
			local entdrop = ents.Create("npc_headcrab_poison")
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 10))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
			timer.Simple(0, function()
				entdrop:SetMaxHealth(entdrop:Health() * 2)
				entdrop:SetHealth(entdrop:Health() * 2)
			end)
		end
	end
end
hook.Add("OnNPCKilled", "HL2cEX_NPCVariantsKilled", HL2cEX_NPCVariantKilled)

function HL2cEX_NPCVariantTakeDamage(target, dmginfo)
	if !GAMEMODE.EXMode then return end
	local dmg, attacker = dmginfo:GetDamage(), dmginfo:GetAttacker()
	if attacker:GetClass() == "npc_metropolice" then
		if attacker.VariantType == 1 then
			dmginfo:ScaleDamage(1.5)
		end
	elseif attacker:GetClass() == "npc_combine_s" then
		if attacker.VariantType == 1 then
			dmginfo:ScaleDamage(2.75)
		end
	elseif attacker:GetClass() == "npc_fastzombie" then
		if attacker.VariantType == 1 then
			if dmginfo:GetDamageType() != DMG_DIRECT then
				timer.Create("FastZombieDamage_"..target:EntIndex(), 1, 5, function()
					if !target:IsValid() then return end
					local d = DamageInfo()
					d:SetDamage(1)
					if attacker:IsValid() then
						d:SetAttacker(attacker)
					else
						d:SetAttacker(game.GetWorld())
					end
					d:SetDamageType(DMG_DIRECT)
					target:TakeDamageInfo(d)
				end)
				dmginfo:ScaleDamage(0.5)
			elseif !target:IsPlayer() then
				dmginfo:ScaleDamage(2)
			end
		end
	elseif attacker:GetClass() == "npc_headcrab" then
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:ScaleDamage(1.4)
	elseif attacker:GetClass() == "npc_headcrab_fast" then
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:ScaleDamage(1.2)
	elseif attacker:GetClass() == "npc_antlionguard" then
		dmginfo:ScaleDamage(2.25)
	elseif attacker:GetClass() == "npc_barnacle" and attacker.VariantType == 1 then
		dmginfo:ScaleDamage(3)
	end
end
hook.Add("EntityTakeDamage", "damagemodshook", HL2cEX_NPCVariantTakeDamage)

timer.Create("NPC_ANTLIONGUARD_AURA", 1, 0, AntlionGuardAURA)


