-- Allow admins to noclip [0 = No, 1 = Yes] (Default: 0)
ADMIN_NOCLIP = 1


-- Give admins the physgun [0 = No, 1 = Yes] (Default: 0)
ADMIN_PHYSGUN = 0


-- Range the difficulty scale can be in [{Min, Max}] (Default: { 1, 3 })
DIFFICULTY_RANGE = {2, 6}


-- Percent of players that need to be in the loading section for the next map to load (Default: 60)
NEXT_MAP_PERCENT = 60


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


XP_GAIN_MUL=1


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


-- Seconds before the map is restarted (Default: 13)
RESTART_MAP_TIME = 13


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

local automake=function(name,merge)
	merge = merge or {}
	return table.Merge({Name=translate.Get(name),Description=translate.Get(name.."_d"),DescriptionEndless=translate.Get(name.."_ed")},merge)
end

GM.SkillsInfo = {
	["Gunnery"] = automake("Gunnery"),

	["Defense"] = automake("Defense"),

	["Medical"] = automake("Medical"),

	["Surgeon"] = automake("Surgeon"),

	["Vitality"] = automake("Vitality"),

	["Knowledge"] = automake("Knowledge"),

	["BetterEngine"] = automake("BetterEngine"),

	["BetterWeapon"] = automake("BetterWeapon"),

}

timer.Create("HL2CE_TRANSLATE SKILL INFO",3,0,function()
	GAMEMODE.SkillsInfo = {
		["Gunnery"] = automake("Gunnery"),
	
		["Defense"] = automake("Defense"),
	
		["Medical"] = automake("Medical"),
	
		["Surgeon"] = automake("Surgeon"),
	
		["Vitality"] = automake("Vitality"),
	
		["Knowledge"] = automake("Knowledge"),
	
		["BetterEngine"] = automake("BetterEngine"),
	
		["BetterWeapon"] = automake("BetterWeapon"),
	
	}
end)

GM.PerksData = {
	["healthboost_1"] = automake("hpboost_1",{
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 1
	}),

	["damageboost_1"] = automake("dmgboost_1",{
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 1
	}),

	["damageresistanceboost_1"] = automake("damageresistanceboost_1",{
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 1
	}),

	["antipoison_1"] = automake("antipoison_1",{
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 1
	}),

	/* uncomment this if it works.
	["difficult_decision_1"] = {
		Name = "Difficult Decision",
		Description = "+25% personal difficulty (Functions same as difficulty, but only affects you, ignores the difficulty cap.)\nDoesn't work yet",
		DescriptionEndless = "+50% difficulty gain on NPC kill, increases xp gain by 15%",
		Cost = 1,
		PrestigeReq = 2,
		PrestigeLevel = 1
	},
	*/
	

	["critical_damage_1"] = automake("critical_damage_1",{
		Cost = 2,
		PrestigeReq = 4,
		PrestigeLevel = 1
	}),

	["better_knowledge_1"] = automake("better_knowledge_1",{
		Cost = 3,
		PrestigeReq = 6,
		PrestigeLevel = 1
	}),

	/* doesn't work yet,uncomment if it works.
		["vampiric_killer_1"] = {
			Name = "Vampiric Killer",
			Description = "You gain +2 HP upon killing an NPC.",
			DescriptionEndless = "You gain +4% health upon killing an NPC. Recovers max of 50 HP.",
			Cost = 5,
			PrestigeReq = 10,
			PrestigeLevel = 1
		},
	*/


	-- Eternity

	/* doesn't work yet,uncomment if it works.
	["damage_of_eternity_2"] = {
		Name = "Damage of Eternity",
		Description = "Does nothing.",
		DescriptionEndless = "Has 15% chance to triple the damage and convert the damage done to Delayed Damage.\nDelayed damage damages NPC's every 0.5 seconds for 20% of remaining Delayed Damage.",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeLevel = 2
	},
	*/

	/* doesn't work yet,uncomment if it works.
		["difficult_decision_2"] = {
			Name = "A very difficult decision",
			Description = "Doesn't do anything.",
			DescriptionEndless = "2.25x difficulty gain per NPC kill",
			Cost = 1,
			PrestigeReq = 2,
			PrestigeLevel = 2
		},
	*/

	["critical_damage_2"] = automake("critical_damage_2",{
		Cost = 2,
		PrestigeReq = 4,
		PrestigeLevel = 2
	}),

}

timer.Create("HL2CE_TRANSLATE PERKSDATA",3,0,function()
	GAMEMODE.PerksData = {
		["healthboost_1"] = automake("hpboost_1",{
			Cost = 1,
			PrestigeReq = 1,
			PrestigeLevel = 1
		}),
	
		["damageboost_1"] = automake("dmgboost_1",{
			Cost = 1,
			PrestigeReq = 1,
			PrestigeLevel = 1
		}),
	
		["damageresistanceboost_1"] = automake("damageresistanceboost_1",{
			Cost = 1,
			PrestigeReq = 1,
			PrestigeLevel = 1
		}),
	
		["antipoison_1"] = automake("antipoison_1",{
			Cost = 1,
			PrestigeReq = 2,
			PrestigeLevel = 1
		}),
	
		/* uncomment this if it works.
		["difficult_decision_1"] = {
			Name = "Difficult Decision",
			Description = "+25% personal difficulty (Functions same as difficulty, but only affects you, ignores the difficulty cap.)\nDoesn't work yet",
			DescriptionEndless = "+50% difficulty gain on NPC kill, increases xp gain by 15%",
			Cost = 1,
			PrestigeReq = 2,
			PrestigeLevel = 1
		},
		*/
		
	
		["critical_damage_1"] = automake("critical_damage_1",{
			Cost = 2,
			PrestigeReq = 4,
			PrestigeLevel = 1
		}),
	
		["better_knowledge_1"] = automake("better_knowledge_1",{
			Cost = 3,
			PrestigeReq = 6,
			PrestigeLevel = 1
		}),
	
		/* doesn't work yet,uncomment if it works.
			["vampiric_killer_1"] = {
				Name = "Vampiric Killer",
				Description = "You gain +2 HP upon killing an NPC.",
				DescriptionEndless = "You gain +4% health upon killing an NPC. Recovers max of 50 HP.",
				Cost = 5,
				PrestigeReq = 10,
				PrestigeLevel = 1
			},
		*/
	
	
		-- Eternity
	
		/* doesn't work yet,uncomment if it works.
		["damage_of_eternity_2"] = {
			Name = "Damage of Eternity",
			Description = "Does nothing.",
			DescriptionEndless = "Has 15% chance to triple the damage and convert the damage done to Delayed Damage.\nDelayed damage damages NPC's every 0.5 seconds for 20% of remaining Delayed Damage.",
			Cost = 1,
			PrestigeReq = 1,
			PrestigeLevel = 2
		},
		*/
	
		/* doesn't work yet,uncomment if it works.
			["difficult_decision_2"] = {
				Name = "A very difficult decision",
				Description = "Doesn't do anything.",
				DescriptionEndless = "2.25x difficulty gain per NPC kill",
				Cost = 1,
				PrestigeReq = 2,
				PrestigeLevel = 2
			},
		*/
	
		["critical_damage_2"] = automake("critical_damage_2",{
			Cost = 2,
			PrestigeReq = 4,
			PrestigeLevel = 2
		}),
	
	}
end)