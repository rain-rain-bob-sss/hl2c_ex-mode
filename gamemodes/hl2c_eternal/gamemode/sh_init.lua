-- Include the required lua files
DeriveGamemode("sandbox")

include("break_infinity.lua")

include("sh_config.lua")
include("sh_cvars.lua")
include("sh_globals.lua")
include("sh_player.lua")
include("sh_ents.lua")
include("sh_pets.lua")


-- Create console variables to make these config vars easier to access
local hl2ce_server_force_difficulty = CreateConVar("hl2ce_server_force_difficulty", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE)

-- General gamemode information
GM.Name = "Half-Life 2 Campaign: Eternal" -- alt name: Half-Life 2 Campaign: China Edition
GM.OriginalAuthor = "AMT (ported and improved by D4 the Perth Fox)"
GM.Author = "Uklejamini"
GM.Version = "0.inf-9" -- what version?
GM.DateVer = "23-12-2025"


-- Constants
FRIENDLY_NPCS = {
	"npc_citizen",
	"monster_scientist",
	"monster_barney",
}

GODLIKE_NPCS = {
	"npc_alyx",
	"npc_barney",
	"npc_breen",
	"npc_dog",
	"npc_eli",
	"npc_fisherman",
	"npc_gman",
	"npc_kleiner",
	"npc_magnusson",
	"npc_monk",
	"npc_mossman",
	"npc_odessa",
	"npc_vortigaunt"
}

hook.Add("Initialize", "ClientsideHookHL2c_EX", function()
	GAMEMODE.EXMode = GAMEMODE.EnableEXMode
end)
-- Create the teams that we are going to use throughout the game
function GM:CreateTeams()

	team.SetUp(TEAM_ALIVE, "ALIVE", Color(192, 192, 192, 255))

	team.SetUp(TEAM_COMPLETED_MAP, "COMPLETED MAP", Color(255, 215, 0, 255))

	team.SetUp(TEAM_DEAD, "DEAD", Color(128, 128, 128, 255))

end

function GM:CalculateXPNeededForLevels(lvl)
	local xp = 0
	if lvl >= 1000 then
		for i=lvl-1000,lvl do
			xp = xp + self:GetReqXPCount(i)
		end
	else
		for i=1,infmath.ConvertInfNumberToNormalNumber(infmath.min(1e6, lvl)) do
			xp = xp + self:GetReqXPCount(i)
		end
	end

	return xp
end

function GM:GetReqXP(ply)
	return self:GetReqXPCount(ply.Level)
end

function GM:GetReqXPCount(lvl)
	local basexpreq = 152
	local addxpperlevel = 27
	local morelvlreq = 1.0715
	lvl_inf = lvl
	lvl = infmath.ConvertInfNumberToNormalNumber(lvl)

	local totalxpreq = InfNumber(basexpreq)
	totalxpreq = totalxpreq + ((lvl_inf * addxpperlevel) ^ morelvlreq)

	if lvl >= 250 then
		totalxpreq = totalxpreq * infmath.max(1 + (lvl_inf-250) * 0.05, 1)
	end
	if lvl >= 400 then
		totalxpreq = totalxpreq * infmath.max(InfNumber(1) + (lvl_inf-400) * (0.05+(lvl_inf-400)*0.01), 1)
	end
	if lvl >= 1000 then
		local l = lvl_inf-1000
		totalxpreq = totalxpreq * infmath.max(1, (1.0046+(l/1e5))^(l))
	end

	return infmath.Round(totalxpreq)
end

-- Called when a gravity gun is attempting to punt something
function GM:GravGunPunt(ply, ent) 
	if (IsValid(ent) && ent:IsVehicle() && (ent != ply.vehicle) && IsValid(ent.creator)) then
		return false
	end

	return true
end 


-- Called when a physgun tries to pick something up
function GM:PhysgunPickup(ply, ent)
	if (string.find(ent:GetClass(), "trigger_") || (ent:GetClass() == "player")) then
		return false
	end

	return true
end

hook.Add("CanProperty", "Hl2ce_CanProperty", function(ply, property, ent)
	if not ply:IsAdmin() then return false end
end)

hook.Add("EntityEmitSound", "EXModeChanges", function(snd)
	-- PrintTable(snd)
	-- print(snd.SoundName)
	if snd.SoundName == "npc/attack_helicopter/aheli_weapon_fire_loop3.wav" then
		snd.Pitch = snd.Pitch * 0.65
		return true
	end
end)


-- Player input changes
function GM:StartCommand(ply, ucmd)
	if (ucmd:KeyDown(IN_SPEED) && IsValid(ply) && !ply:IsSuitEquipped()) then
		ucmd:RemoveKey(IN_SPEED)
	end

	if (ucmd:KeyDown(IN_WALK) && IsValid(ply) && !ply:IsSuitEquipped()) then
		ucmd:RemoveKey(IN_WALK)
	end
end

-- function GM:Move(ply, mv)
	-- print(mv:GetFinalIdealVelocity())
-- end


-- Players should never collide with each other or NPC's
function GM:ShouldCollide(entA, entB)

	if IsValid(entA) && IsValid(entB) then
		local classa,classb = entA:GetClass(),entB:GetClass()
		-- Prevent antlion guards from colliding each other
		if classa == classb or classa == "npc_antlion" and classb == "npc_antlionguard" or classa == "npc_antlionguard" and classb == "npc_antlion" then
			return false
		end

		-- Player and NPCs
		if (entA:IsPlayer() && (entB:IsPlayer() || entB:IsGodlikeNPC() or entB:IsFriendlyNPC())) || (entB:IsPlayer() && (entA:IsPlayer() || entA:IsGodlikeNPC() || entA:IsFriendlyNPC())) then
			return false
		end

		-- Passenger seating
		if (entA:IsPlayer() && entA:InVehicle() && entA:GetAllowWeaponsInVehicle() && entB:IsVehicle()) || (entB:IsPlayer() && entB:InVehicle() && entB:GetAllowWeaponsInVehicle() && entA:IsVehicle()) then
			return false
		end
	end
	
	return true
end


-- Called when a player is being attacked
function GM:PlayerShouldTakeDamage(ply, attacker)
	if ((ply:Team() != TEAM_ALIVE) || !ply.vulnerable || (attacker:IsPlayer() && (attacker != ply)) || (attacker:IsVehicle() && IsValid(attacker:GetDriver()) && attacker:GetDriver():IsPlayer()) || attacker:IsGodlikeNPC() || attacker:IsFriendlyNPC()) then	
		return false
	end

	return true
end


function GM:IsSpecialPerson(ply, image)
	local img, tooltip
--i know this was copied from zombiesurvival gamemode but i was too lazy to make one by myself anyway
--you can add new special person table by yourself but you must keep the original ones and the new ones must be after steamid
	if ply:SteamID64() == "76561198274314803" then
		img = "icon16/award_star_gold_3.png"
		tooltip = "HL2c Eternal coder"
	elseif ply:SteamID64() == "76561198058929932" then
		img = "icon16/medal_gold_3.png"
		tooltip = "Original Creator of Half-Life 2 Campaign"


	elseif ply:IsBot() then
		img = "icon16/plugin.png"
		tooltip = "BOT"
	elseif ply:IsSuperAdmin() then
		img = "icon16/shield_add.png"
		tooltip = "Super Admin"
	elseif ply:IsAdmin() then
		img = "icon16/shield.png"
		tooltip = "Admin"
	end

	if img then
		if CLIENT then
			image:SetImage(img)
			image:SetTooltip(tooltip)
		end
		return true
	end
	return false
end


-- Called after the player's think
function GM:PlayerPostThink(ply)
	-- Manage server data on the player
	if SERVER then
		if IsValid(ply) && ply:Alive() && (ply:Team() == TEAM_ALIVE) then
			-- Give them weapons they don't have
			for _, ply2 in ipairs(player.GetAll()) do
				if (ply != ply2) && ply2:Alive() && !ply:InVehicle() && !ply2:InVehicle() && IsValid(ply2:GetActiveWeapon()) && !ply:HasWeapon(ply2:GetActiveWeapon():GetClass()) && !table.HasValue(ply.givenWeapons, ply2:GetActiveWeapon():GetClass()) && (ply2:GetActiveWeapon():GetClass() != "weapon_physgun" and table.HasValue(WHITELISTED_WEAPONS, ply2:GetActiveWeapon():GetClass())) then
					ply:Give(ply2:GetActiveWeapon():GetClass())
					table.insert(ply.givenWeapons, ply2:GetActiveWeapon():GetClass())
				end
			end
		end
	end
end


-- why i'm using GlobalString instead of Float value:
-- Allows to be broadcasted to client with numbers like 2^128 (3.40e38) and above until 2^1024 (1.79e308) values
-- break infinity update: NOW UP TO 10^(1.79e308)!!!!!

function GM:SetDifficulty(val, noncvar)
	local diffcvarvalue = tonumber(hl2ce_server_force_difficulty:GetString()) or 0

	if noncvar or diffcvarvalue <= 0 then
		SetGlobalString("hl2c_difficulty", isinfnumber(val) and val:DefaultFormat() or ConvertStringToInfNumber(val):DefaultFormat())
	end
end

-- Why 1e150 max difficulty? -- It might seem possible to go further.. But damage is only limited to 3.40e38. After that value it overflows to infinity. honestly, fuck it

function GM:GetDifficulty(noncvar, noadditionalmul)
	local diffcvarvalue = tonumber(hl2ce_server_force_difficulty:GetString()) or 1
	
	if not noncvar and diffcvarvalue > 0 then
		return InfNumber(diffcvarvalue)
	end

	local value = ConvertStringToInfNumber(GetGlobalString("hl2c_difficulty", 1))
	if not noadditionalmul and FORCE_DIFFICULTY then
		value = value * FORCE_DIFFICULTY
	end


	return value
end

function GM:GetEffectiveDifficulty(ply)
	if !ply then return self:GetDifficulty() end

	local power = 1

	if ply:HasPerkActive("3_extremility") then
		power = power * 0.9
	end

	return self:GetDifficulty()^power
end


function FormatNumber(val, roundval)
	local log10_value = math.floor(isinfnumber(val) and val:log10() or math.log10(val))

	if isinfnumber(val) then
		if log10_value < 33 then
			val = infmath.ConvertInfNumberToNormalNumber(val)
		else
			return tostring(val)
		end
	end

	local txt
	local negative = val < 0 and "-" or ""
	roundval = roundval or 2
	val = math.abs(val)
	if val >= math.huge then return val end
	if val >= 1e33 then
		val = val / (10^log10_value)

		txt = math.floor(val*(10^roundval))/(10^roundval) .."e"..log10_value
	elseif val >= 1e30 then
		val = val / 1e30

		txt = math.floor(val*(10^roundval))/(10^roundval) .." No"
	elseif val >= 1e27 then
		val = val / 1e27

		txt = math.floor(val*(10^roundval))/(10^roundval) .." Oc"
	elseif val >= 1e24 then
		val = val / 1e24

		txt = math.floor(val*(10^roundval))/(10^roundval) .." Sp"
	elseif val >= 1e21 then
		val = val / 1e21

		txt = math.floor(val*(10^roundval))/(10^roundval) .." Sx"
	elseif val >= 1e18 then
		val = val / 1e18

		txt = math.floor(val*(10^roundval))/(10^roundval) .." Qt"
	elseif val >= 1e15 then
		val = val / 1e15

		txt = math.floor(val*(10^roundval))/(10^roundval) .." Qa"
	elseif val >= 1e12 then
		val = val / 1e12

		txt = math.floor(val*(10^roundval))/(10^roundval) .." T"
	elseif val >= 1e9 then
		val = val / 1e9

		txt = math.floor(val*(10^roundval))/(10^roundval) .." B"
	elseif val >= 1e6 then
		val = val / 1e6

		txt = math.floor(val*(10^roundval))/(10^roundval) .." M"
	elseif val >= 1e3 then
		val = val / 1e3

		txt = math.floor(val*(10^roundval))/(10^roundval) .." K"
	elseif val == 0 then txt = 0
	elseif val > -(10^-(roundval or 1)) and val < 10^-(roundval or 1) then
		val = val / (10^log10_value)

		txt = math.floor(val*(10^roundval))/(10^roundval) .."e-"..math.abs(log10_value)
	end

	if txt then return negative..txt end
	return negative..math.floor(val*(10^(roundval or 1)))/(10^(roundval or 1))
end

function GlitchedText(text, prob)
	local str = ""

	return str
end

/*
function FormatNumber(value)
	if value == math.huge then return "Infinite" end
	if value >= 1e3 then
		value = value / 1e3
		return math.Round(value, 2).." K"
	end

	-- return string.format("%d.%02d", value, value/math.floor(math.log10(value)))
	return value
end
*/
