-- Allow admins to noclip [0 = No, 1 = Yes] (Default: 1)
ADMIN_NOCLIP = 1


-- Give admins the physgun [0 = No, 1 = Yes] (Default: 0)
ADMIN_PHYSGUN = 0


-- Range the difficulty scale can be in [{Min, Max}] (Default: { 1, 3 })
DIFFICULTY_RANGE = {1, 3}


-- Percent of players that need to have completed the map in order to continue. Does not include dead players. (Default: 40)
NEXT_MAP_PERCENT = 40


-- Percent of players that need to be in the loading section for the next map to load (Default: 90)
NEXT_MAP_INSTANT_PERCENT = 90


-- Seconds before the next map loads (Default: 60)
NEXT_MAP_TIME = 60


-- Points to give a player for killing an NPC (if non-one)
NPC_POINT_VALUES = {
	["npc_antlionguard"] = 2,
	["npc_citizen"] = 0,
	["npc_combinedropship"] = 3,
	["npc_combinegunship"] = 2,
	["npc_crow"] = 0,
	["npc_helicopter"] = 3,
	["npc_ministrider"] = 2,
	["npc_pigeon"] = 0,
	["npc_strider"] = 3
}

NPC_XP_VALUES = {
	["npc_antlion"] = 0.87, -- in some maps the antlions can spawn indefinitely so best is to make them give least amount of xp per kill
	-- ["npc_antlion_worker"] = 21.7, -- doesn't work
	["npc_antlionguard"] = 285,
	["npc_barnacle"] = 11.7,
	["npc_combinedropship"] = 63,
	["npc_combinegunship"] = 66,
	["npc_combine_s"] = 33.5,
	["npc_cscanner"] = 6.4,
	["npc_clawscanner"] = 7.1,
	["npc_fastzombie"] = 19.5,
	["npc_fastzombie_torso"] = 11.2,
	["npc_headcrab"] = 3.1,
	["npc_headcrab_fast"] = 3.9,
	["npc_headcrab_black"] = 5.2,
	["npc_headcrab_poison"] = 5.2,
	["npc_helicopter"] = 55,
	["npc_hunter"] = 70,
	["npc_manhack"] = 9.5,
	["npc_metropolice"] = 22.4,
	["npc_ministrider"] = 15,
	["npc_stalker"] = 18,
	["npc_strider"] = 218,
	["npc_zombie"] = 16,
	["npc_zombine"] = 27.6,
	["npc_poisonzombie"] = 42.7,
	["npc_zombie_torso"] = 11.8,
}

NPC_MONEYS_VALUES = {
	["npc_antlion"] = 0.8,
	["npc_antlionguard"] = 280,
	["npc_barnacle"] = 11,
	["npc_combinedropship"] = 60,
	["npc_combinegunship"] = 69,
	["npc_combine_s"] = 33,
	["npc_cscanner"] = 6,
	["npc_clawscanner"] = 7,
	["npc_fastzombie"] = 19,
	["npc_fastzombie_torso"] = 11,
	["npc_headcrab"] = 3,
	["npc_headcrab_fast"] = 4,
	["npc_headcrab_black"] = 5,
	["npc_headcrab_poison"] = 5,
	["npc_helicopter"] = 55,
	["npc_hunter"] = 45,
	["npc_manhack"] = 9,
	["npc_metropolice"] = 22,
	["npc_ministrider"] = 15,
	["npc_stalker"] = 18,
	["npc_strider"] = 210,
	["npc_zombie"] = 16,
	["npc_zombine"] = 27,
	["npc_poisonzombie"] = 42,
	["npc_zombie_torso"] = 11,
}

-- Exclude these NPCs from lag compensation
NPC_EXCLUDE_LAG_COMPENSATION = {
	"cycler",
	"cycler_actor",
	"generic_actor",
	"npc_alyx",
	"npc_barney",
	"npc_barnacle",
	"npc_breen",
	"npc_bullseye",
	"npc_citizen",
	"npc_combinedropship",
	"npc_combinegunship",
	"npc_combine_camera",
	"npc_cranedriver",
	"npc_dog",
	"npc_eli",
	"npc_enemyfinder",
	"npc_fisherman",
	"npc_furniture",
	"npc_gman",
	"npc_helicopter",
	"npc_kleiner",
	"npc_magnusson",
	"npc_monk",
	"npc_mossman",
	"npc_rollermine",
	"npc_strider",
	"npc_turret_ceiling",
	"npc_turret_floor",
	"npc_turret_ground",
	"npc_vehicledriver",
	"npc_vortigaunt"
}


-- Play Episode 1 after HL2 [false = No, true = Yes] (Default: false)
PLAY_EPISODE_1 = false


-- Play Episode 2 after Episode 1 [false = No, true = Yes] (Default: false)
PLAY_EPISODE_2 = false


-- Seconds before the map is restarted (Default: 12)
RESTART_MAP_TIME = 12


-- Models the player can be
PLAYER_MODELS = {
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_06.mdl",
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
	"models/player/group03/female_01.mdl",
	"models/player/group03/female_02.mdl",
	"models/player/group03/female_03.mdl",
	"models/player/group03/female_04.mdl",
	"models/player/group03/female_06.mdl",
	"models/player/group03/male_01.mdl",
	"models/player/group03/male_02.mdl",
	"models/player/group03/male_03.mdl",
	"models/player/group03/male_04.mdl",
	"models/player/group03/male_05.mdl",
	"models/player/group03/male_06.mdl",
	"models/player/group03/male_07.mdl",
	"models/player/group03/male_08.mdl",
	"models/player/group03/male_09.mdl"
}


-- Number of seconds before a player is vulnerable after they spawn (Default: 5)
VULNERABLE_TIME = 5


-- Only administrators can hold these weapons (Default: weapon_physgun)
ADMINISTRATOR_WEAPONS = {
	"weapon_physgun",
	"weapon_base",
	"weapon_flechettegun",
}

--Give shared weapons. If weapon is in list, gives everyone else the same gun. 
WHITELISTED_WEAPONS = {
	"weapon_crowbar",
	"weapon_physcannon",
	"weapon_pistol",
	"weapon_357",
	"weapon_smg1",
	"weapon_ar2",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_frag",
	"weapon_rpg",
	"weapon_bugbait"
}

GM.SkillsInfo = {
	["Gunnery"] = {
		Name = "Gunnery",
		Description = "+1% damage dealt with firearms",
		DescriptionEndless = "+3% damage dealt with firearms\nAbove Gunnery Level 15: +2.5% damage dealt with non-firearms per point",
	},

	["Defense"] = {
		Name = "Defense",
		Description = "+0.8% damage resistance from enemy bullets",
		DescriptionEndless = "+2.5% damage resistance from enemy bullets\nAbove Level 15: +2% damage resistance all sources but guns",
	},

	["Medical"] = {
		Name = "Medical",
		Description = "+2% effectiveness to medkits",
		DescriptionEndless = "+5% effectiveness to medkits"
	},

	["Surgeon"] = {
		Name = "Surgeon",
		Description = "+2% max ammo to medkits / +2% increased medkit recharge speed",
		DescriptionEndless = "+10% max ammo to medkits / +10% increased medkit recharge speed"
	},

	["Vitality"] = {
		Name = "Vitality",
		Description = "+1 health",
		DescriptionEndless = "+5 health",
		OnApply = function(ply, oldamt, newamt)
			local oldmhp = ply:GetMaxHealth()
			local newmhp = ply:GetOriginalMaxHealth()

			ply:SetHealth(ply:Health() * (newmhp / oldmhp))
			ply:SetMaxHealth(newmhp)
		end
	},

	["Knowledge"] = {
		Name = "Knowledge",
		Description = "+3% xp gain",
		DescriptionEndless = "+5% xp gain\nAbove Level 15: +2% difficulty gain on NPC Kill"
	},

}

GM.PerksData = {
	["1_healthboost"] = {
		Name = "Health Boost",
		Description = "Increases health by 15",
		DescriptionEndless = "Increases health by 85",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 1
	},

	["1_damageboost"] = {
		Name = "Damage Boost",
		Description = "+6% damage dealt",
		DescriptionEndless = "+47% damage dealt",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 1
	},

	["1_damageresistanceboost"] = {
		Name = "Damage Resistance Boost",
		Description = "+7% boost to damage resistance",
		DescriptionEndless = "+57% boost to damage resistance",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 1
	},

	["1_antipoison"] = {
		Name = "Anti-Poison",
		Description = "Reduces damage taken from poison headcrabs by half (reduces up to 25 damage)",
		DescriptionEndless = "Reduces damage taken from poison headcrabs by half (reduces up to 100 damage)",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 1
	},

	["1_difficult_decision"] = {
		Name = "Difficult Decision",
		Description = "+25% personal difficulty (Functions same as difficulty, but only affects you, ignores the difficulty cap.)\nDoesn't work yet",
		DescriptionEndless = "+75% difficulty gain on NPC kill, increases xp gain by 10%",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 1
	},

	["1_critical_damage"] = {
		Name = "Critical Damage I",
		Description = "7% chance to deal 1.2x damage",
		DescriptionEndless = "12% chance to deal 2.2x damage",
		Cost = 1,
		PrestigeReq = 3,
		PrestigeLevel = 1
	},

	["1_super_armor"] = {
		Name = "Super Armor",
		Description = "+5 max armor, up to +5% damage resistance depending on your current armor (max efficiency at 100 armor)",
		DescriptionEndless = "+30 max armor, up to +45% damage resistance depending on your current armor (max efficiency at 100 armor)",
		Cost = 1,
		PrestigeReq = 3,
		PrestigeLevel = 1
	},

	["1_better_knowledge"] = {
		Name = "Better Knowledge",
		Description = "+25% xp gain from NPC kills",
		DescriptionEndless = "1.55x xp gain from NPC kills if difficulty is above 650%, else 1.3x XP.\n+5% boost to bonus xp on map completion, Knowledge skill +1.5% xp gain per point.",
		Cost = 3,
		PrestigeReq = 5,
		PrestigeLevel = 1
	},

	["1_aggressive_gameplay"] = {
		Name = "Aggressive Gameplay I",
		Description = "+15% personal difficulty",
		DescriptionEndless = "2.3x difficulty gain on NPC kill, and +35% xp gain",
		Cost = 3,
		PrestigeReq = 7,
		PrestigeLevel = 1
	},

	["1_vampiric_killer"] = {
		Name = "Vampiric Killer",
		Description = "You gain +2 HP upon killing an NPC.",
		DescriptionEndless = "You gain +4% health upon killing an NPC. Recovers max of 50 HP.",
		Cost = 5,
		PrestigeReq = 10,
		PrestigeLevel = 1
	},
--[[
	["1_critical_damage_2"] = {
		Name = "Critical Damage II",
		Description = "Improves \"Critical Damage I\" perk: chance 12% -> 25%; damage 2.2x -> 2.8x",
		Cost = 15,
		PrestigeReq = 20,
		PrestigeLevel = 1,
		EndlessOnly = true
	},

	["1_break_limits"] = {
		Name = "Break Limits I",
		Description = "Breaks the limits of prestige by greatly increasing max level and increases max skill levels.\n1.5x XP gained",
		Cost = 10,
		PrestigeReq = 42,
		PrestigeLevel = 1
	},

	["1_breaking_point"] = {
		Name = "Breaking Point",
		Description = "Perk points gain increased ^0.9 -> ^0.99;\n^1.25 to xp gain multiplier",
		Cost = 66,
		PrestigeReq = 45,
		PrestigeLevel = 1
	},

	["1_difficult_decision_2"] = {
		Name = "Difficult Decision II",
		Description = "",
		DescriptionEndless = "x1.65 difficulty gain; x(1+log10(difficulty)x0.3) boost to difficulty gain\nDifficulty damage modification effectiveness ^0.9",
		Cost = 789,
		PrestigeReq = 60,
		PrestigeLevel = 1,
		EndlessOnly = true
	},
]]

	-- Eternity

	["2_damage_of_eternity"] = {
		Name = "Damage of Eternity",
		DescriptionEndless = "2x Damage dealt. Has 15% chance to triple the damage and convert that damage to Delayed Damage.\nDelayed damage damages NPC's every 0.5 seconds for 20% of remaining Delayed Damage.",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 2
	},

	["2_skills_improver"] = {
		Name = "Skills Improver I",
		DescriptionEndless = "Automatically uses gained skill points evenly to skills on level up. Only upgrades skills fully, no decimals!\nIncreases skills max level to 80 (only for Eternity)",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 2
	},

	["2_difficult_decision"] = {
		Name = "A very difficult decision",
		DescriptionEndless = "3.35x difficulty gain per NPC kill, and a +45% XP Gain",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 2
	},

	["2_super_critical_damage"] = {
		Name = "Super Critical Damage",
		DescriptionEndless = "Improves Critical Damage I perk, chance 12% -> 19% and damage 2.2x -> 2.5x.\nAlso grants a 6% chance to inflict super critical hit, granting 4x damage!.",
		Cost = 1,
		PrestigeReq = 3,
		PrestigeLevel = 2
	},

	["2_prestige_improvement_2"] = {
		Name = "Prestige Improvement II",
		DescriptionEndless = "On prestige you keep 25% of your XP. You will keep your Prestige perks after Eternity. (Affects your Prestige Points)\nHas a increased damage taken penalty when having negative prestige points.",
		Cost = 1,
		PrestigeReq = 4,
		PrestigeLevel = 2
	},

	["2_perk_points"] = {
		Name = "Perk Points I",
		DescriptionEndless = "+12 Perk Points for each Eternity",
		Cost = 1,
		PrestigeReq = 4,
		PrestigeLevel = 2
	},

	["2_damageboost"] = {
		Name = "Super Damage Boost",
		DescriptionEndless = "+40% damage dealt, +5% damage for every unspent perk point\n(Negative points will apply too but can reduce only up to 40%)",
		Cost = 1,
		PrestigeReq = 4,
		PrestigeLevel = 2
	},

	["2_healthboost"] = {
		Name = "Super Health Boost",
		DescriptionEndless = "+450 health and +1 HP/s to regeneration",
		Cost = 3,
		PrestigeReq = 5,
		PrestigeLevel = 2
	},

	["2_hyper_armor"] = {
		Name = "Hyper Armor",
		DescriptionEndless = "+100 armor, also charges AUX power by +1% per second if not submerged underwater\nIf AUX Power is full, charge +1% armor every 5 seconds.", -- Thinking of another buff for this, but maybe later
		Cost = 3,
		PrestigeReq = 5,
		PrestigeLevel = 2
	},

	["2_vampiric_killer"] = {
		Name = "Vampiric Killer II",
		DescriptionEndless = "You regain HP depending on the damage you do to enemies.",
		Cost = 3,
		PrestigeReq = 5,
		PrestigeLevel = 2
	},


	-- Celestial Perks
	["3_celestial"] = {
		Name = "Celestial.",
		DescriptionEndless = "OP Perks: +320 health, +80 armor, x1.6 damage dealt, 1.7x damage resistance, 1.4x xp gain",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 3
	},
--[[
	["3_prestige_improvement_3"] = {
		Name = "Prestige Improvement III",
		DescriptionEndless = " (NYI)",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 3,
	},
]]
	["3_extremility"] = {
		Name = "Extremility",
		DescriptionEndless = "^0.9 to the effective difficulty.\nEffective difficulty affects only damage dealt to, and taken by NPC's.",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 3,
	},

	["3_medkit_enhancer"] = {
		Name = "Medkit Enhancer",
		DescriptionEndless = "Medkits you pick up refill additional +100hp and 20% of your health",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 3,

	},

	["3_uno_reverse"] = {
		Name = "Uno Reverse",
		DescriptionEndless = "10% chance to deflect all the damage taken to the attacker and quadruples it\n(<75% health needed for this to work, the lower hp the better chance).\nAlso recovers 25% health upon activation. Chance divides by 1.1 each time this ability is activated",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 3,

	},

	["3_difficult_decision"] = {
		Name = "Mega Difficult Decision",
		DescriptionEndless = "Increases difficulty gain from NPC kills by x log10(difficulty)*2.5\n1.25x xp gain",
		Cost = 1,
		PrestigeReq = 3,
		PrestigeLevel = 3
	},

	["3_ultra_armor"] = {
		Name = "Ultra Armor",
		DescriptionEndless = "+500 armor, +25% damage resistance mul, damage vs yourself is powered to ^0.5,\ndamage increases with armor (+1% dmg/10ap) (NYI)",
		Cost = 2,
		PrestigeReq = 4,
		PrestigeLevel = 3
	},

	["3_ultra_tough"] = {
		Name = "Ultra Tough",
		DescriptionEndless = "+6125 health",
		Cost = 2,
		PrestigeReq = 4,
		PrestigeLevel = 3
	},

	["3_exponentially_cursed"] = {
		Name = "Exponentially Cursed",
		DescriptionEndless = "Your health and damage taken becomes logarithmed (min 0.01 damage taken)\nx100 to your health after logarithm (NYI)",
		Cost = 1e100,
		PrestigeReq = 1000000,
		PrestigeLevel = 3
	},

}

GM.UpgradesEternity = {
	["damage_upgrader"] = {
		Name = "Damage Upgrader",
		Description = "Increases damage multiplier by %s%%",
		Cost = function(ply, amt) return InfNumber(100) + InfNumber(25*amt*amt)^(1 + amt*0.01)^math.max(1, amt*0.001) end,
		EffectValue = function(ply, amt)
			return 1 + 0.1*amt
		end,
	},

	["damageresistance_upgrader"] = {
		Name = "Damage Resistance Upgrader",
		Description = "+%s%% damage resistance per upgrade\n(Multiplicative. Past 10x the effect starts getting softcapped.)",
		Cost = function(ply, amt)
			return InfNumber(100) + (InfNumber(25*amt*amt)*(amt > 1e2 and (amt-1e2)^1.1 or 1))^(1 + amt*0.01)^(amt > 1e3 and 1+(amt-1e3)/1e3 or 1)
		end,
		EffectValue = function(ply, amt)
			local val = InfNumber(1.1)
			val = val^amt
			if infmath.ConvertInfNumberToNormalNumber(val) > 10 then
				val = val / infmath.max(1, (val/10)^(1-(0.9/(val:log10()/2.5))))
			end

			return val
		end,
	},

	["difficultygain_upgrader"] = {
		Name = "Difficulty Gain Upgrader",
		Description = "+%s%% difficulty gain\n(Softcaps after 10x)",
		Cost = function(ply, amt) return InfNumber(100) + InfNumber(25*amt*amt)^(1 + amt*0.01)^math.max(1, 0.5+amt/2e3) end,
		EffectValue = function(ply, amt)
			local val = 1 + 0.1*amt
			if val > 10 then
				val = val / math.max(1, (val/10)^0.25)
			end

			return val
		end,
	},
}


GM.PlayerConfigurables = {
	["AutoPrestige"] = {"number", 0, "AutoPrestige", "When to prestige?", 0, function(ply) return 1e6 end}, -- #1 type, #2 default, #3 name, #4 description, #5 min (func), #6 max (func)
	["ShouldNotifyPrestige"] = {"bool", 0, 1},
}
