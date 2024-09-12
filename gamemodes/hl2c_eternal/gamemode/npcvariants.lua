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
				if v:Health() < 0 then continue end
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

-- Priority hook function
function HL2cEX_NPCVariantSpawn(ent)
	if !GAMEMODE.EXMode or !ent:IsNPC() then return end

	ent.VariantType = math.random(1,2)
	if ent:GetClass() == "npc_metropolice" then -- Elite variant - Increased damage and Health. (No manhack spawn and launched to the killer upon death)
		if ent.VariantType == 1 then
			ent.ent_Color = Color(128,128,255)
			ent.ent_MaxHealthMul = 1.3
			ent.ent_HealthMul = 1.3
			ent.XPGainMult = 1.2
		elseif ent.VariantType == 2 then -- Deathbringer variant - 0.9x health and damage, Special: Launches a manhack towards the player upon dying, dealing 7x damage on its' first slashing hit, damage then decreases by 0.65x for every hit inflicted, down to 0.5x
			ent.ent_Color = Color(255,128,192)
			ent.ent_MaxHealthMul = 0.9
			ent.ent_HealthMul = 0.9
		end
	elseif ent:GetClass() == "npc_combine_s" then -- Destructive variant - deals massive damage but is also more fragile. Shotgunner damage reduced.
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
			ent.ent_MaxHealthMul = 0.64
			ent.ent_HealthMul = 0.64

		elseif ent.VariantType == 2 then -- Boost health for normal soldiers
			ent.ent_MaxHealthMul = 1.2
			ent.ent_HealthMul = 1.2
		end
	elseif ent:GetClass() == "npc_manhack" then
	elseif ent:GetClass() == "npc_zombie" then -- Explosive variant of regular zombies that explodes upon its' death (Explosions can be chained)
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
			ent.ent_MaxHealthMul = 0.6
			ent.ent_HealthMul = 0.6
		end
	elseif ent:GetClass() == "npc_fastzombie" then -- Infective variant of Fast zombies can deal damage over time
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
			ent.ent_MaxHealthMul = 0.7
			ent.ent_HealthMul = 0.7
		end
	elseif ent:GetClass() == "npc_zombine" then -- Tanky Zombine variant (Deals less damage but has much more health) Still very vulnerable to fire
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,255)
			ent.ent_MaxHealthMul = 2.2
			ent.ent_HealthMul = 2.2
			ent.XPGainMult = 1.3
		end
	elseif ent:GetClass() == "npc_antlionguard" then -- Healer Antlion Guard that slowly heals nearby antlions! (But is rarer!)
		ent.VariantType = math.random(1,5) --make antlion guard variant less common
		if ent.VariantType == 5 then
			ent.ent_Color = Color(0,255,0)
			ent.ent_MaxHealthMul = 2
			ent.ent_HealthMul = 2
			ent.XPGainMult = 2.2
		end
	elseif ent:GetClass() == "npc_cscanner" or ent:GetClass() == "npc_clawscanner" then
		if ent.VariantType == 1 then
			ent.ent_Color = Color(255,128,128)
		end
	elseif ent:GetClass() == "npc_barnacle" then
		ent.VariantType = math.random(1,3) -- Barnacle has 3 variants
		if ent.VariantType == 1 then -- 1. Deadly variant - Deals triple damage, but can die faster
			ent.ent_MaxHealthMul = 0.6
			ent.ent_HealthMul = 0.6
			ent.ent_Color = Color(255,128,128)
		elseif ent.VariantType == 2 then -- 2. Bulky variant - Can take up a lot of damage, but cannot resist single hit of crowbar
			ent.ent_MaxHealthMul = 13.8
			ent.ent_HealthMul = 13.8
			ent.ent_Color = Color(128,128,255)
		else -- 3. Regular - Has 1.4x health, other stats are normal
			ent.ent_MaxHealthMul = 1.4
			ent.ent_HealthMul = 1.4
		end
	end
end
hook.Add("OnEntityCreated", "HL2cEX_NPCVariantsSpawned", HL2cEX_NPCVariantSpawn, HOOK_HIGH)

function HL2cEX_NPCVariantKilled(ent, attacker)
	if !GAMEMODE.EXMode then return end
	if ent:GetClass() == "npc_zombie" then
		if ent.VariantType == 1 then
			local entdrop = ents.Create("env_explosion")
			entdrop:SetOwner(attacker)
			entdrop:SetKeyValue("iMagnitude", 45)
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 30))
			entdrop:SetAngles(ent:GetAngles())
			entdrop:Spawn()
			entdrop:Activate()
			entdrop:Fire("explode")
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
		if ent.VariantType == 2 and math.random(1,100) < 45 then
			local entdrop = ents.Create("npc_manhack")
			entdrop.VariantType = 3 -- Spawn in a special manhack variant - Damage increased up to 5.5x on first hit but next hit will deal a weaker attack down to 0.5x damage
			entdrop.NextDamageMul = 5.5
			entdrop:SetPos(ent:GetPos() + Vector(0, 0, 50))
			entdrop:SetAngles(ent:GetAngles())
			entdrop.ent_Color = Color(128,192,255)
			entdrop:Spawn()
			entdrop:Activate()
			entdrop:GetPhysicsObject():SetVelocityInstantaneous((attacker:GetPos() - entdrop:GetPos()) * 2)
		end
	elseif ent:GetClass() == "npc_sniper" then
		PrintMessage(3, "WTF YOU KILLED HIM!")
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

function HL2cEX_NPCVariantTakeDamage(ent, dmginfo)
	if !GAMEMODE.EXMode then return end
	local dmg, attacker = dmginfo:GetDamage(), dmginfo:GetAttacker()
	if attacker:GetClass() == "npc_metropolice" then
		if attacker.VariantType == 1 then
			dmginfo:ScaleDamage(1.5)
		elseif attacker.VariantType == 2 then
			dmginfo:ScaleDamage(0.9)
		end
	elseif attacker:GetClass() == "npc_manhack" then
		if attacker.VariantType == 3 then
			local dmgmul = attacker.NextDamageMul
			timer.Simple(0, function()
				if !dmgmul then return end
				attacker.NextDamageMul = math.max(0.5, dmgmul * 0.65)
			end)
		end
	elseif attacker:GetClass() == "npc_combine_s" then
		if attacker.VariantType == 1 then
			local wep = attacker:GetActiveWeapon()
			if wep:IsValid() and wep:GetClass() == "weapon_shotgun" then
				dmginfo:ScaleDamage(1.85)
			else
				dmginfo:ScaleDamage(2.55)
			end
		end
	elseif attacker:GetClass() == "npc_sniper" then
		if attacker.VariantType == 1 then
			dmginfo:ScaleDamage(215790)
		end
	elseif attacker:GetClass() == "npc_fastzombie" then
		if attacker.VariantType == 1 then
			if dmginfo:GetDamageType() != DMG_DIRECT then
				timer.Create("FastZombieDamage_"..ent:EntIndex(), 1, 5, function()
					if !ent:IsValid() then return end
					local d = DamageInfo()
					d:SetDamage(1)
					if attacker:IsValid() then
						d:SetAttacker(attacker)
					else
						d:SetAttacker(game.GetWorld())
					end
					d:SetDamageType(DMG_DIRECT)
					ent:TakeDamageInfo(d)
				end)
				dmginfo:ScaleDamage(0.5)
			elseif !ent:IsPlayer() then
				dmginfo:ScaleDamage(2)
			end
		end
	elseif attacker:GetClass() == "npc_zombine" then
		dmginfo:ScaleDamage(0.6)
	elseif attacker:GetClass() == "npc_headcrab" then
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:ScaleDamage(1.4)
	elseif attacker:GetClass() == "npc_headcrab_fast" then
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:ScaleDamage(1.2)
	elseif attacker:GetClass() == "npc_antlionguard" then
		dmginfo:ScaleDamage(2.25)
	elseif attacker:GetClass() == "npc_barnacle" then
		if attacker.VariantType == 1 then
			dmginfo:ScaleDamage(3)
		elseif attacker.VariantType == 2 then
			dmginfo:ScaleDamage(0.5)
		end
	end

	if ent:GetClass() == "npc_barnacle" then
	end
end
hook.Add("EntityTakeDamage", "damagemodshook", HL2cEX_NPCVariantTakeDamage)

timer.Create("NPC_ANTLIONGUARD_AURA", 1, 0, AntlionGuardAURA)


