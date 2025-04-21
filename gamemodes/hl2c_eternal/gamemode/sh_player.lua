-- Finds the player meta table or terminates
local meta = FindMetaTable( "Player" )
if !meta then return end


-- Remove the vehicle
function meta:RemoveVehicle()

	if ( CLIENT || !self:IsValid() ) then
	
		return
	
	end

	if ( IsValid( self.vehicle ) ) then
	
		if ( IsValid( self.vehicle:GetDriver() ) && self.vehicle:GetDriver():IsPlayer() ) then
		
			self.vehicle:GetDriver():ExitVehicle()
		
		end
		self.vehicle:Remove()
	
	end

end

function meta:GetMaxDifficultyXPGainMul()
	return self:HasEternityUnlocked() and 250 or self:HasPrestigeUnlocked() and 75 or 15
end

function meta:GetSkillAmount(stat)
	if GAMEMODE.NoProgressionAdvantage then return 0 end
	return math.Clamp(self["Stat"..stat] or 0, 0, GAMEMODE.EndlessMode and 1e6 or 10)
end

function meta:HasPerkUnlocked(perk)
	return self.UnlockedPerks[perk]
end

function meta:HasPerkActive(perk)
	local perkdata = GAMEMODE.PerksData[perk]

	if GAMEMODE.NoProgressionAdvantage then return false end

	return self:HasPerkUnlocked(perk) and not table.HasValue(self.DisabledPerks, perk) and (GAMEMODE.EndlessMode or perkdata.PrestigeLevel < 2)
end




function meta:GetPlayerConfig(data)
	return GAMEMODE.ConfigList[data] and self.ConfigData[data]
end


function meta:CanLevelup()
	return self.XP >= GAMEMODE:GetReqXP(self)
end

function meta:CanPrestige()
	return self.Level > MAX_LEVEL or self.Level >= MAX_LEVEL and self.XP >= GAMEMODE:GetReqXP(self)
end

function meta:CanEternity()
	return self:CanPrestige() and self.Prestige >= MAX_PRESTIGE or self.Prestige > MAX_PRESTIGE
end

function meta:CanCelestiality()
	return self:CanPrestige() and self:CanEternity() or self.Eternity > MAX_ETERNITIES
end

function meta:HasPrestigeUnlocked()
	return self.Prestige > 0 or self:HasEternityUnlocked()
end

function meta:HasEternityUnlocked()
	return self.Eternity > 0 or self:HasCelestialityUnlocked()
end

function meta:HasCelestialityUnlocked()
	return self.Celestiality > 0
end

function meta:GetPrestigeGainMul()
	return math.floor(math.Clamp(
		self.XPUsedThisPrestige / GAMEMODE:CalculateXPNeededForLevels(MAX_LEVEL) * 0.6,
		1, self:GetMaxPrestige() - self.Prestige))
end

function meta:GetEternityGainMul()
	return math.floor(math.Clamp(self.Prestige / MAX_ETERNITIES,
		1, self:GetMaxEternity() - self.Eternity))
end

function meta:GetMaxLevel()
	return self:HasEternityUnlocked() and 250 or MAX_LEVEL
end

function meta:GetMaxPrestige()
	return self:HasEternityUnlocked() and 30 or MAX_PRESTIGE
end

function meta:GetMaxEternity()
	return MAX_ETERNITIES
end

function meta:GetMaxCelestiality()
	return MAX_ETERNITIES
end

function meta:GetMaxSkillLevel(perk)
	return self:HasEternityUnlocked() and (self:HasPerkActive("skills_improver_2") and 80 or 60) or self:HasPrestigeUnlocked() and 35 or 20
end

-- Large function! (Can go up to more than 1e12!) [Expectation, when all prestiges and perks are done]

function meta:GetProgressionScore()
	local score = 0

	if self.Level > 1 then
		score = score + self.Level-1
	end

	if self.Prestige > 0 then
		score = score + 100*self.Prestige
	end

	if self.Eternity > 0 then
		score = score + 2000*self.Eternity
	end

	if self.Celestiality > 0 then
		score = score + 30000*self.Celestiality
	end

	-- May be reconsidered in the future
	-- if self.Celestiality > 0 then
		-- score = score + 30000*self.Celestiality
	-- end


	return score^0.8 -- Why? Need this to be a *bit* more accurate
end

-- Eternity Upgrades
function meta:GetEternityUpgradeEffectValue(upg, forcevalue)
	local upgrade = GAMEMODE.UpgradesEternity[upg]
	if not upgrade then return 1 end
	


	local amt = math.max(0, forcevalue or self.EternityUpgradeValues[upg])
	if isfunction(upgrade.EffectValue) then
		return upgrade.EffectValue(self, amt)
	end

	if upgrade.EffectType == EFFECTTYPE_ADDITIVE then
		return 1 + (amt*upgrade.EffectIncrease)
	elseif upgrade.EffectType == EFFECTTYPE_MULTIPLICATIVE then
		return (1 + upgrade.EffectIncrease) ^ amt
	end

	return 1
end

function meta:GetEternityUpgradeCost(upg, forcevalue)
	local upgrade = GAMEMODE.UpgradesEternity[upg]
	if not upgrade then return end

	local amt = math.max(0, forcevalue or self.EternityUpgradeValues[upg])
	local cost = upgrade.Cost

	if isfunction(cost) then
		return cost(self, amt)
	end

	return cost
end

-- Can have random stats. That's why I am putting another functions for this.
function meta:GetDamageMul(dmgInfo, ent)
	local attacker = self
	local GM = GAMEMODE
	local damagemul = 1

	damagemul = self:GetMinDamageMul(dmgInfo, ent)

	if attacker:HasPerkActive("critical_damage_1") and math.random(100) <= (GM.EndlessMode and 12 or 7) then
		damagemul = damagemul * (GM.EndlessMode and 2.2 or 1.2)
	end

	return damagemul
end

function meta:GetMaxDamageMul(dmgInfo, ent)
	local attacker = self
	local GM = GAMEMODE
	local damagemul = 1

	damagemul = self:GetMinDamageMul(dmgInfo, ent)

	if attacker:HasPerkActive("critical_damage_1") then
		damagemul = damagemul * (GM.EndlessMode and 2.2 or 1.2)
	end

	return damagemul
end

function meta:GetMinDamageMul(dmgInfo, ent)
	local attacker = self
	local GM = GAMEMODE
	local damagemul = 1

	if dmgInfo and dmgInfo:IsBulletDamage() then
		damagemul = damagemul * (1 + ((GM.EndlessMode and 0.03 or 0.01) * attacker:GetSkillAmount("Gunnery")))
	elseif attacker:GetSkillAmount("Gunnery") > 15 then
		damagemul = damagemul * (1 + (0.025 * (attacker:GetSkillAmount("Gunnery")-15)))
	end

	if attacker:HasPerkActive("damageboost_1") then
		damagemul = damagemul * (1 + (GM.EndlessMode and 0.47 or 0.06))
	end

	if attacker:HasPerkActive("damage_of_eternity_2") then
		damagemul = damagemul * 2
	end

	if attacker:HasPerkActive("damageboost_2") then
		damagemul = damagemul * math.max(1, 1.4 + attacker.PrestigePoints*0.05)
	end

	if attacker:HasPerkActive("celestial_3") then
		damagemul = damagemul * 1.6
	end

	if attacker:HasEternityUnlocked() then
		damagemul = damagemul * attacker:GetEternityUpgradeEffectValue("damage_upgrader")
	end

	return damagemul
end

function meta:GetDamageResistanceMul(dmgInfo)
	local damageresistancemul = 1
	local ent = self
	local GM = GAMEMODE

	damageresistancemul = self:GetMinDamageResistanceMul(dmgInfo)

	return damageresistancemul
end

function meta:GetMaxDamageResistanceMul(dmgInfo)
	local damageresistancemul = 1
	local ent = self
	local GM = GAMEMODE

	damageresistancemul = self:GetMinDamageResistanceMul(dmgInfo)

	return damageresistancemul
end

function meta:GetMinDamageResistanceMul(dmgInfo)
	local damageresistancemul = 1
	local ent = self
	local GM = GAMEMODE

	if dmgInfo and dmgInfo:IsBulletDamage() then
		damageresistancemul = damageresistancemul * (1 + ((GM.EndlessMode and 0.025 or 0.008) * ent:GetSkillAmount("Defense")))
	elseif ent:GetSkillAmount("Defense") > 15 then
		damageresistancemul = damageresistancemul * (1 + (0.02 * ent:GetSkillAmount("Defense")))
	end

	if ent:HasPerkActive("damageresistanceboost_1") then
		damageresistancemul = damageresistancemul * (1 + (GM.EndlessMode and 0.57 or 0.07))
	end

	if ent:HasPerkActive("super_armor_1") and ent:Armor() > 0 then
		local limit = GM.EndlessMode and 0.45 or 0.05
		damageresistancemul = damageresistancemul * (1 + (math.Clamp(limit*ent:Armor()/100, 0, limit)))
	end

	if ent:HasPerkActive("celestial_3") then
		damageresistancemul = damageresistancemul * 1.7
	end

	if ent.PrestigePoints < 0 then
		damageresistancemul = damageresistancemul / (1 - ent.PrestigePoints*0.2)
	end

	if ent:HasEternityUnlocked() then
		damageresistancemul = damageresistancemul * ent:GetEternityUpgradeEffectValue("damageresistance_upgrader")
	end

	return damageresistancemul
end


function meta:GetOriginalMaxHealth()
	local maxhp = 100 + ((GAMEMODE.EndlessMode and 5 or 1) * self:GetSkillAmount("Vitality")) -- calculate their max health
	if self:HasPerkActive("healthboost_1") then
		maxhp = maxhp + (GAMEMODE.EndlessMode and 85 or 15)
	end
	if GAMEMODE.EndlessMode then
		if self:HasPerkActive("healthboost_2") then
			maxhp = maxhp + 450
		end
		if self:HasPerkActive("celestial_3") then
			maxhp = maxhp + 320
		end
	end

	return maxhp
end
