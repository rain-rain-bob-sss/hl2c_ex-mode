-- Allow admins to noclip [0 = No, 1 = Yes] (Default: 0)
ADMIN_NOCLIP = 1


-- Give admins the physgun [0 = No, 1 = Yes] (Default: 0)
ADMIN_PHYSGUN = 0


-- Range the difficulty scale can be in [{Min, Max}] (Default: { 1, 3 })
DIFFICULTY_RANGE = { 1, 3 }


-- Percent of players that need to be in the loading section for the next map to load (Default: 60)
NEXT_MAP_PERCENT = 60


-- Seconds before the next map loads (Default: 60)
NEXT_MAP_TIME = 60


-- Points to give a player for killing an NPC (if non-one)
NPC_POINT_VALUES = {
	[ "npc_antlionguard" ] = 2,
	[ "npc_citizen" ] = 0,
	[ "npc_combinedropship" ] = 3,
	[ "npc_combinegunship" ] = 2,
	[ "npc_crow" ] = 0,
	[ "npc_helicopter" ] = 3,
	[ "npc_ministrider" ] = 2,
	[ "npc_pigeon" ] = 0,
	[ "npc_strider" ] = 3
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


-- Seconds before the map is restarted (Default: 10)
RESTART_MAP_TIME = 15


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
	[ "weapon_physgun" ] = true,
	[ "weapon_base" ] = true,
	[ "weapon_flechettegun" ] = true
}

--Give shared weapons. If weapon is in list, will give everyone else the same gun. 
WHITELISTED_WEAPONS = {
	["weapon_crowbar"] = true,
	["weapon_physcannon"] = true,
	["weapon_pistol"] = true,
	["weapon_357"] = true,
	["weapon_smg1"] = true,
	["weapon_ar2"] = true,
	["weapon_shotgun"] = true,
	["weapon_crossbow"] = true,
	["weapon_frag"] = true,
	["weapon_rpg"] = true,
	["weapon_bugbait"] = true,
	
}
