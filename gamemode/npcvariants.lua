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
			ent:SetColor(Color(128,128,255,255))
			timer.Simple(0, function()
				if !ent:IsValid() then return end
				ent:SetColor(Color(128,128,255,255))
				ent:SetMaxHealth(1.3 * ent:Health())
				ent:SetHealth(1.3 * ent:Health())
			end)
		end
	elseif ent:GetClass() == "npc_combine_s" then
		if ent.VariantType == 1 then
			ent:SetColor(Color(255,128,128,255))
			timer.Simple(0, function()
				if !ent:IsValid() then return end
				ent:SetColor(Color(255,128,128,255))
				ent:SetMaxHealth(0.4 * ent:Health())
				ent:SetHealth(0.4 * ent:Health())
			end)
		elseif ent.VariantType == 2 then
			timer.Simple(0, function()
				if !ent:IsValid() then return end
				ent:SetMaxHealth(1.2 * ent:Health())
				ent:SetHealth(1.2 * ent:Health())
			end)
		end
	elseif ent:GetClass() == "npc_zombie" then
		if ent.VariantType == 1 then
			ent:SetColor(Color(255,128,128,255))
			timer.Simple(0, function()
				if !ent:IsValid() then return end
				ent:SetColor(Color(255,128,128,255))
				ent:SetMaxHealth(0.6 * ent:Health())
				ent:SetHealth(0.6 * ent:Health())
			end)
		end
	elseif ent:GetClass() == "npc_fastzombie" then
		if ent.VariantType == 1 then
			ent:SetColor(Color(255,128,128,255))
			timer.Simple(0, function()
				if !ent:IsValid() then return end
				ent:SetColor(Color(255,128,128,255))
				ent:SetMaxHealth(0.7 * ent:Health())
				ent:SetHealth(0.7 * ent:Health())
			end)
		end
	elseif ent:GetClass() == "npc_antlionguard" then
		ent.VariantType = math.random(1,5) --make medical antlion guard variant less common
		if ent.VariantType == 5 then
			ent:SetColor(Color(0,255,0,255))
			timer.Simple(0, function()
				if !ent:IsValid() then return end
				ent:SetColor(Color(0,255,0,255))
				ent:SetMaxHealth(2 * ent:Health())
				ent:SetHealth(2 * ent:Health())
			end)
		end
	elseif ent:GetClass() == "npc_cscanner" or ent:GetClass() == "npc_clawscanner" then
		if ent.VariantType == 1 then
			ent:SetColor(Color(255,128,128,255))
		end
	end
end
hook.Add("OnEntityCreated", "HL2cEX_NPCVariantsSpawned", HL2cEX_NPCVariantSpawn)

function HL2cEX_NPCVariantKilled(ent)
	if !GAMEMODE.EXMode then return end
	if ent:GetClass() == "npc_zombie" then
		if ent.VariantType == 1 then
			local EDrop = ents.Create("npc_handgrenade")
			EDrop:SetPos(ent:GetPos() + Vector(0, 0, 30))
			EDrop:SetAngles(ent:GetAngles())
			EDrop:Spawn()
			EDrop:Activate()
			local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos() + Vector(0, 0, 60))
			util.Effect("zw_master_strike", effectdata)
			ent:EmitSound("ambient/machines/thumper_hit.wav", 120, 70)
		elseif ent.VariantType == 2 and math.random(1,100) < 35 then
			local EDrop = ents.Create("npc_headcrab")
			EDrop:SetPos(ent:GetPos() + Vector(0, 0, 10))
			EDrop:SetAngles(ent:GetAngles())
			EDrop:Spawn()
			EDrop:Activate()
		end
	elseif ent:GetClass() == "npc_fastzombie" then
		if ent.VariantType == 1 and math.random(1,100) < 15 then
			local EDrop = ents.Create("npc_headcrab_fast")
			EDrop:SetPos(ent:GetPos() + Vector(0, 0, 10))
			EDrop:SetAngles(ent:GetAngles())
			EDrop:Spawn()
			EDrop:Activate()
		end
	elseif ent:GetClass() == "npc_metropolice" then
		if ent.VariantType == 2 and math.random(1,100) < 40 then
				local EDrop = ents.Create("npc_manhack")
				EDrop:SetPos(ent:GetPos() + Vector(0, 0, 50))
				EDrop:SetAngles(ent:GetAngles())
				EDrop:Spawn()
				EDrop:Activate()
		end
		
	elseif ent:GetClass() == "npc_antlionguard" then
		if ent.VariantType == 5 then
			local EDrop = ents.Create("weapon_medkit")
			EDrop:SetPos(ent:GetPos() + Vector(0, 0, 50))
			EDrop:SetAngles(ent:GetAngles())
			EDrop:Spawn()
			EDrop:Activate()
		end
	elseif ent:GetClass() == "npc_poisonzombie" then
		if ent.VariantType == 1 then
			local EDrop = ents.Create("npc_headcrab_poison")
			EDrop:SetPos(ent:GetPos() + Vector(0, 0, 10))
			EDrop:SetAngles(ent:GetAngles())
			EDrop:Spawn()
			EDrop:Activate()
			timer.Simple(0, function()
				EDrop:SetMaxHealth(EDrop:Health() * 2)
				EDrop:SetHealth(EDrop:Health() * 2)
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
			if target:IsPlayer() and dmginfo:GetDamageType() != DMG_DIRECT then
				timer.Create("FastZombieDamage_"..target:UniqueID(), 1, 5, function()
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
	elseif attacker:GetClass() == "npc_antlionguard" then
		dmginfo:ScaleDamage(2.25)
	end
end
hook.Add("EntityTakeDamage", "damagemodshook", HL2cEX_NPCVariantTakeDamage)

timer.Create("NPC_ANTLIONGUARD_AURA", 1, 0, AntlionGuardAURA)