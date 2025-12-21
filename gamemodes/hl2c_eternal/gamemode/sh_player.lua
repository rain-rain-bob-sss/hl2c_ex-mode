local player_GetAll = player.GetAll	

function player.GetLiving()
	local i = 0
	local t = {}
	for _,ply in pairs(player_GetAll()) do
		if ply:Alive() and ply:Team() == TEAM_ALIVE then
			i = i + 1
			t[i] = ply
		end
	end

	return t
end

function player.GetLivingHumans()
	local i = 0
	local t = {}
	for _,ply in pairs(player_GetAll()) do
		if ply:Alive() and ply:Team() == TEAM_ALIVE and !ply:IsBot() then
			i = i + 1
			t[i] = ply
		end
	end

	return t
end

-- Finds the player meta table or terminates
local meta = FindMetaTable("Player")
if !meta then return end


-- Remove the vehicle
function meta:RemoveVehicle()
	if CLIENT or !self:IsValid() then
		return
	end

	if IsValid(self.vehicle) then
		if IsValid(self.vehicle:GetDriver()) and self.vehicle:GetDriver():IsPlayer() then
			self.vehicle:GetDriver():ExitVehicle()
		end
		self.vehicle:Remove()
	end
end

function meta:GetMaxDifficultyXPGainMul()
	-- return math.huge
	return self:HasEternityUnlocked() and 250 or self:HasPrestigeUnlocked() and 75 or 15
end

function meta:GetMaxDifficultyMoneyGainMul()
	-- return math.huge
	return self:HasEternityUnlocked() and 250 or self:HasPrestigeUnlocked() and 75 or 15
end

function meta:GetSkillAmount(stat)
	if GAMEMODE.NoProgressionAdvantage then return 0 end
	return math.Clamp(self.Skills[stat] or 0, 0, GAMEMODE.EndlessMode and 1e6 or 10)
end

function meta:HasPerkUnlocked(perk)
	return self.UnlockedPerks[perk]
end

function meta:HasPerkActive(perk)
	-- do return false end -- temporarily disabled

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
	return infmath.ConvertInfNumberToNormalNumber(self.Level) > MAX_LEVEL or infmath.ConvertInfNumberToNormalNumber(self.Level) >= MAX_LEVEL and
	self.XP >= GAMEMODE:GetReqXP(self)
end

function meta:CanEternity() -- higher prestige ignores CanPrestige requireent
	return self.PrestigePoints >= InfNumber(2)^31
end

function meta:CanCelestiality()
	return self.Eternities > MAX_ETERNITIES or self:CanPrestige() and self:CanEternity() and self.Eternities >= MAX_ETERNITIES
end

function meta:HasPrestigeUnlocked()
	return infmath.ConvertInfNumberToNormalNumber(self.Prestige) > 0 or self:HasEternityUnlocked()
end

function meta:HasEternityUnlocked()
	return infmath.ConvertInfNumberToNormalNumber(self.Eternities) > 0 or self:HasCelestialityUnlocked()
end

function meta:HasCelestialityUnlocked()
	return infmath.ConvertInfNumberToNormalNumber(self.Celestiality) > 0
end

function meta:GetPrestigeGainMul()
	return infmath.floor(infmath.max(self.XPUsedThisPrestige / GAMEMODE:CalculateXPNeededForLevels(MAX_LEVEL) * 0.6, 1))
--[[
	return infmath.floor(infmath.Clamp(
		self.XPUsedThisPrestige / GAMEMODE:CalculateXPNeededForLevels(MAX_LEVEL) * 0.6,
		1, self:GetMaxPrestige() - self.Prestige))
]]
end

function meta:GetEternityGainMul()
	return 1
--[[
	return infmath.floor(math.Clamp(self.Prestige / MAX_ETERNITIES,
	1, self:GetMaxEternity() - self.Eternity))
	]]
end

function meta:GetMaxLevel()
	return self:HasCelestialityUnlocked() and 500 or (self:HasEternityUnlocked() and 250 or MAX_LEVEL)
end

function meta:GetMaxPrestige()
	return self:HasCelestialityUnlocked() and 200 or (self:HasEternityUnlocked() and 30 or MAX_PRESTIGE)
end

function meta:GetMaxEternity()
	return self:HasCelestialityUnlocked() and 25 or MAX_ETERNITIES
end

function meta:GetMaxCelestiality()
	return MAX_ETERNITIES --???
end

function meta:GetMaxSkillLevel(perk)
	if GAMEMODE.SkillsDisabled then return 0 end

	return self:HasEternityUnlocked() and (self:HasPerkActive("2_skills_improver") and 80 or 60) or self:HasPrestigeUnlocked() and 35 or 20
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

	if self.Eternities > 0 then
		score = score + 2000*self.Eternities
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



	local amt = math.max(0, forcevalue or self.EternityUpgradeValues[upg] or 0)
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

	local amt = math.max(0, forcevalue or self.EternityUpgradeValues[upg] or 0)
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
	local damagemul = self:GetMinDamageMul(dmgInfo, ent)

	if attacker:HasPerkActive("1_critical_damage") and math.random(100) <= (GM.EndlessMode and 12 or 7) then
		damagemul = damagemul * (GM.EndlessMode and 2.2 or 1.2)
	end


	return damagemul
end

function meta:LastStand()
	return self:Health() <= self:GetMaxHealth() * EndlessModeValue(0.2,0.4)
end

function meta:GetMaxDamageMul(dmgInfo, ent)
	local attacker = self
	local GM = GAMEMODE
	local damagemul = self:GetMinDamageMul(dmgInfo, ent)

	if attacker:HasPerkActive("1_critical_damage") then
		damagemul = damagemul * (GM.EndlessMode and 2.2 or 1.2)
	end

	if attacker:HasPerkActive("last_stand") and attacker:LastStand() then 
		damagemul = damagemul * 2
	end

	if attacker:HasPerkActive("bleed_for_8_seconds") then 
		damagemul = damagemul * 1.25
	end

	return damagemul
end

function meta:GetMinDamageMul(dmgInfo, ent)
	local attacker = self
	local GM = GAMEMODE
	local damagemul = InfNumber(1)

	if dmgInfo and dmgInfo:IsBulletDamage() then
		damagemul = damagemul * (1 + ((GM.EndlessMode and 0.03 or 0.01) * attacker:GetSkillAmount("Gunnery")))
	elseif attacker:GetSkillAmount("Gunnery") > 15 then
		damagemul = damagemul * (1 + (0.025 * (attacker:GetSkillAmount("Gunnery")-15)))
	end

	if attacker:HasPerkActive("1_damageboost") then
		damagemul = damagemul * (1 + (GM.EndlessMode and 0.47 or 0.06))
	end

	if attacker:HasPerkActive("2_damage_of_eternity") then
		damagemul = damagemul * 2
	end

	if attacker:HasPerkActive("2_damageboost") then
		local d = attacker.PrestigePoints*0.05

		damagemul = damagemul * infmath.max(1, 1.4 + (
			d > InfNumber(1) and
			d^(1/(d:log10())^0.5) or d))
	end

	if attacker:HasPerkActive("3_celestial") then
		damagemul = damagemul * 1.6
	end

	if attacker:HasEternityUnlocked() then
		damagemul = damagemul * attacker:GetEternityUpgradeEffectValue("damage_upgrader")
	end

	if attacker:HasPerkActive("last_stand") and attacker:LastStand() then 
		damagemul = damagemul *2
	end

	if attacker:HasPerkActive("bleed_for_8_seconds") then 
		damagemul = damagemul * 1.25
	end

	return damagemul
end

function meta:GetDamageResistanceMul(dmgInfo)
	local damageresistancemul = self:GetMinDamageResistanceMul(dmgInfo)
	local ent = self
	local GM = GAMEMODE

	return damageresistancemul
end

function meta:GetMaxDamageResistanceMul(dmgInfo)
	local damageresistancemul = self:GetMinDamageResistanceMul(dmgInfo)
	local ent = self
	local GM = GAMEMODE

	return damageresistancemul
end

function meta:GetMinDamageResistanceMul(dmgInfo)
	local damageresistancemul = InfNumber(1)
	local ent = self
	local GM = GAMEMODE

	if dmgInfo and dmgInfo:IsBulletDamage() then
		damageresistancemul = damageresistancemul * (1 + ((GM.EndlessMode and 0.025 or 0.008) * ent:GetSkillAmount("Defense")))
	elseif ent:GetSkillAmount("Defense") > 15 then
		damageresistancemul = damageresistancemul * (1 + (0.02 * ent:GetSkillAmount("Defense")))
	end

	if ent:HasPerkActive("1_damageresistanceboost") then
		damageresistancemul = damageresistancemul * (1 + (GM.EndlessMode and 0.57 or 0.07))
	end

	if ent:HasPerkActive("1_super_armor") and ent:Armor() > 0 then
		local limit = GM.EndlessMode and 0.45 or 0.05
		damageresistancemul = damageresistancemul * (1 + (math.Clamp(limit*ent:Armor()/100, 0, limit)))
	end

	if ent:HasPerkActive("3_celestial") then
		damageresistancemul = damageresistancemul * 1.7
	end

	if infmath.ConvertInfNumberToNormalNumber(ent.PrestigePoints) < 0 then
		damageresistancemul = damageresistancemul / (1 - ent.PrestigePoints*0.2)
	end

	if ent:HasEternityUnlocked() then
		damageresistancemul = damageresistancemul * ent:GetEternityUpgradeEffectValue("damageresistance_upgrader")
	end

	return damageresistancemul
end

function meta:GetOriginalMaxHealth()
	local maxhp = 100 + ((GAMEMODE.EndlessMode and 5 or 1) * self:GetSkillAmount("Vitality")) -- calculate their max health
	if self:HasPerkActive("1_healthboost") then
		maxhp = maxhp + (GAMEMODE.EndlessMode and 85 or 15)
	end
	if GAMEMODE.EndlessMode then
		if self:HasPerkActive("2_healthboost") then
			maxhp = maxhp + 450
		end
		if self:HasPerkActive("3_celestial") then
			maxhp = maxhp + 320
		end
	end

	return maxhp
end

function meta:GetXPMul(nomul)
	if nomul then return InfNumber(XP_GAIN_MUL) end

	local xpmul = InfNumber(XP_GAIN_MUL)
    xpmul = xpmul + (self:GetSkillAmount("Knowledge") * (GAMEMODE.EndlessMode and (self:HasPerkActive("1_better_knowledge") and 0.065 or 0.05) or 0.03))

    if GAMEMODE.EndlessMode then
        if self:HasPerkActive("1_difficult_decision") then
            xpmul = xpmul * 1.1
        end

        if self:HasPerkActive("1_aggressive_gameplay") then
            xpmul = xpmul * 1.35
        end
    end

	local prestigexpmul = 1
    prestigexpmul = prestigexpmul + math.min(self.Prestige*0.2, 100) + math.min(self.Eternity*1.2, 100) + math.min(self.Celestiality*5, 100)

    xpmul = xpmul * prestigexpmul
	return xpmul
end

function meta:GetMoneyMul(nomul)
	if nomul then return MONEY_GAIN_MUL end
	local moneymul = MONEY_GAIN_MUL
	return moneymul
end
