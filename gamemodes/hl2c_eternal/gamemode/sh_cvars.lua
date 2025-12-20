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

local function callback()
	local jumped = {}
	local function bhop(enable)
		if enable then
			hook.Add("SetupMove", "hl2ce_bhop", function(ply, mv, ucmd)
				if !ALLOWBHOP then return end
				if ply:GetMoveType() ~= MOVETYPE_WALK or ply:WaterLevel() > 1 then return end
				local buttons = ucmd:GetButtons()
				local jumping = bit.band(buttons, IN_JUMP) ~= 0

				if jumping and !jumped[ply] and ply:OnGround() then
					if ply:Crouching() and bit.band(buttons, IN_DUCK) == 0 then
						buttons = buttons + IN_DUCK
					end
					jumped[ply] = true

				else
					if jumping and !ply:OnGround() then
						buttons = buttons - IN_JUMP
					end

					jumped[ply] = nil
				end
			
				mv:SetButtons(buttons)
			end)
		else
			hook.Remove("SetupMove", "hl2ce_bhop")
		end
	end

	local GM = GAMEMODE or GM
	bhop(tobool(GM.BHopEnabled))
end
GM.BHopEnabled = CreateConVar("hl2ce_server_bhop_enable", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Enable bhop... for fun!"):GetBool()
cvars.AddChangeCallback("hl2ce_server_bhop_enable", function(cvar, old, new)
	GAMEMODE.BHopEnabled = tobool(new)

	callback()
end, "hl2ce_server_bhop_enable")

if GM.BHopEnabled then
	callback()
end

