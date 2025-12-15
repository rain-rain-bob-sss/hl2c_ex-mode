GM.AdminPhysgun = CreateConVar("hl2c_admin_physgun", ADMIN_PHYSGUN, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_admin_physgun", function(cvar, old, new)
	GAMEMODE.AdminPhysgun = tobool(new)
end, "hl2c_admin_physgun")

GM.AdminNoclip = CreateConVar("hl2c_admin_noclip", ADMIN_NOCLIP, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_admin_noclip", function(cvar, old, new)
	GAMEMODE.AdminNoclip = tobool(new)
end, "hl2c_admin_noclip")

GM.ForceGamerules = CreateConVar("hl2c_server_force_gamerules", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_force_gamerules", function(cvar, old, new)
	GAMEMODE.ForceGamerules = tobool(new)
end, "hl2c_server_force_gamerules")

GM.CustomPMs = CreateConVar("hl2c_server_custom_playermodels", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_custom_playermodels", function(cvar, old, new)
	GAMEMODE.CustomPMs = tobool(new)
end, "hl2c_server_custom_playermodels")

GM.CheckpointRespawn = CreateConVar("hl2c_server_checkpoint_respawn", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_checkpoint_respawn", function(cvar, old, new)
	GAMEMODE.CheckpointRespawn = tobool(new)
end, "hl2c_server_checkpoint_respawn")

GM.DynamicSkillLevel = CreateConVar("hl2c_server_dynamic_skill_level", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_dynamic_skill_level", function(cvar, old, new)
	GAMEMODE.DynamicSkillLevel = tobool(new)
end, "hl2c_server_dynamic_skill_level")

GM.LagCompensation = CreateConVar("hl2c_server_lag_compensation", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_lag_compensation", function(cvar, old, new)
	GAMEMODE.LagCompensation = tobool(new)
end, "hl2c_server_lag_compensation")

GM.PlayerRespawning = CreateConVar("hl2c_server_player_respawning", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_player_respawning", function(cvar, old, new)
	GAMEMODE.PlayerRespawning = tobool(new)
end, "hl2c_server_player_respawning")

GM.JeepPassengerSeat = CreateConVar("hl2c_server_jeep_passenger_seat", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2c_server_jeep_passenger_seat", function(cvar, old, new)
	GAMEMODE.JeepPassengerSeat = tobool(new)
end, "hl2c_server_jeep_passenger_seat")


GM.EnableEXMode = CreateConVar("hl2ce_server_ex_mode_enabled", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2ce_server_ex_mode_enabled", function(cvar, old, new)
	GAMEMODE.EnableEXMode = tobool(new)
end, "hl2ce_server_ex_mode_enabled")

GM.ForceDifficulty = CreateConVar("hl2ce_server_force_difficulty", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE):GetString()
cvars.AddChangeCallback("hl2ce_server_force_difficulty", function(cvar, old, new)
	GAMEMODE.ForceDifficulty = new
end, "hl2ce_server_force_difficulty")

GM.SkillsDisabled = CreateConVar("hl2ce_server_skills_disabled", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE):GetBool()
cvars.AddChangeCallback("hl2ce_server_skills_disabled", function(cvar, old, new)
	GAMEMODE.SkillsDisabled = tobool(new)
end, "hl2ce_server_skills_disabled")

GM.PlayerMedkitOnSpawn = CreateConVar("hl2ce_server_player_medkit", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Give medkits for players on spawn"):GetBool()
cvars.AddChangeCallback("hl2ce_server_player_medkit", function(cvar, old, new)
	GAMEMODE.PlayerMedkitOnSpawn = tobool(new)
end, "hl2ce_server_player_medkit")

