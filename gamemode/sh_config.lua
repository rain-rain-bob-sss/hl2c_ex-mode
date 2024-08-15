-- Allow admins to noclip [0 = No, 1 = Yes] (Default: 0)
ADMIN_NOCLIP = 1


-- Give admins the physgun [0 = No, 1 = Yes] (Default: 0)
ADMIN_PHYSGUN = 0


-- Range the difficulty scale can be in [{Min, Max}] (Default: { 1, 3 })
DIFFICULTY_RANGE = {1, 3}


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

NPC_XP_VALUES = {
	["npc_antlion"] = 0.17, -- in some maps the antlions can spawn indefinitely so best is to make them give least amount of xp per kill
	["npc_antlion_worker"] = 5.7,
	["npc_antlionguard"] = 27,
	["npc_barnacle"] = 1.7,
	["npc_combinedropship"] = 12,
	["npc_combinegunship"] = 9.5,
	["npc_combine_s"] = 5.7,
	["npc_cscanner"] = 1.5,
	["npc_clawscanner"] = 1.6,
	["npc_fastzombie"] = 3.8,
	["npc_fastzombie_torso"] = 2.7,
	["npc_headcrab"] = 0.6,
	["npc_headcrab_fast"] = 0.8,
	["npc_headcrab_black"] = 1.2,
	["npc_headcrab_poison"] = 1.2,
	["npc_helicopter"] = 11,
	["npc_hunter"] = 14.1,
	["npc_manhack"] = 2.1,
	["npc_metropolice"] = 4.4,
	["npc_ministrider"] = 2,
	["npc_stalker"] = 3,
	["npc_strider"] = 16,
	["npc_zombie"] = 3.4,
	["npc_zombine"] = 5.1,
	["npc_poisonzombie"] = 9.1,
	["npc_zombie_torso"] = 2.1,
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


-- Number of seconds before a player is vulnerable after they spawn (Default: 10)
VULNERABLE_TIME = 10


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
		DescriptionEndless = "+1% damage dealt with firearms",
	},

	["Defense"] = {
		Name = "Defense",
		Description = "+0.5% damage resistance from enemy bullets",
		DescriptionEndless = "+0.5% damage resistance from enemy bullets",
	},

	["Medical"] = {
		Name = "Medical",
		Description = "+0.1 to regen / +2% effectiveness to medkits",
		DescriptionEndless = "+5 health"
	},

	["Vitality"] = {
		Name = "Vitality",
		Description = "+1 health",
		DescriptionEndless = "+5 health"
	},

}

GM.PerksData = {
	["healthboost"] = {
		Name = "Health Boost",
		Description = "Increases health by 5",
		DescriptionEndless = "Increases health by 30",
		Cost = 1,
		PrestigeReq = 1,
		PrestigeType = "prestige"
	}
}
