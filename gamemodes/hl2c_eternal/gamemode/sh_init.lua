-- Include the required lua files
DeriveGamemode("sandbox")

include("sh_config.lua")
include("sh_globals.lua")
include("sh_player.lua")
include("sh_ents.lua")

-- Create console variables to make these config vars easier to access
local hl2c_admin_physgun = CreateConVar("hl2c_admin_physgun", ADMIN_NOCLIP, FCVAR_REPLICATED + FCVAR_NOTIFY)
local hl2c_admin_noclip = CreateConVar("hl2c_admin_noclip", ADMIN_PHYSGUN, FCVAR_REPLICATED + FCVAR_NOTIFY)
local hl2c_server_force_gamerules = CreateConVar("hl2c_server_force_gamerules", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2c_server_custom_playermodels = CreateConVar("hl2c_server_custom_playermodels", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2c_server_checkpoint_respawn = CreateConVar("hl2c_server_checkpoint_respawn", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2c_server_dynamic_skill_level = CreateConVar("hl2c_server_dynamic_skill_level", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2c_server_lag_compensation = CreateConVar("hl2c_server_lag_compensation", 1, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2c_server_player_respawning = CreateConVar("hl2c_server_player_respawning", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2c_server_jeep_passenger_seat = CreateConVar("hl2c_server_jeep_passenger_seat", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2ce_server_ex_mode_enabled = CreateConVar("hl2ce_server_ex_mode_enabled", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
local hl2ce_server_force_difficulty = CreateConVar("hl2ce_server_force_difficulty", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE)

do
    local base = "player_sandbox"
    if not player_manager.GetPlayerClasses()["player_sandbox"] then base = "player_default" end
    local BASEPLAYER = player_manager.GetPlayerClasses()[base]
    local PLAYER = table.Copy(BASEPLAYER)
    local JUMPING
    function PLAYER:StartMove(move)
        if bit.band(move:GetButtons(), IN_JUMP) ~= 0 and bit.band(move:GetOldButtons(), IN_JUMP) == 0 and self.Player:OnGround() then -- Only apply the jump boost in FinishMove if the player has jumped during this frame -- Using a global variable is safe here because nothing else happens between SetupMove and FinishMove
            JUMPING = true
        end
    end

    function PLAYER:FinishMove(move)
        if JUMPING then -- If the player has jumped this frame
            local forward = move:GetAngles() -- Get their orientation
            forward.p = 0
            forward = forward:Forward()
	    	local speedBoostPerc = ( ( self.Player:Crouching() ) and 1.575 ) or 0.5
            if not self.Player:IsSprinting() and not self.Player:Crouching() then speedBoostPerc = 0.375 end
            local speedAddition = math.abs(move:GetForwardSpeed() * speedBoostPerc)
            local maxSpeed = 1e9
            local newSpeed = speedAddition + move:GetVelocity():Length2D()
            if newSpeed > maxSpeed then -- Clamp it to make sure they can't bunnyhop to ludicrous speed
                speedAddition = speedAddition - (newSpeed - maxSpeed)
            end

            if move:GetVelocity():Dot(forward) < 0 then -- Reverse it if the player is running backwards
                speedAddition = -speedAddition
            end

            move:SetVelocity(forward * speedAddition + move:GetVelocity()) -- Apply the speed boost
        end

        JUMPING = nil
    end

    player_manager.RegisterClass("player_hl2ce", PLAYER, base)
end

-- General gamemode information
GM.Name = "Half-Life 2 Campaign: Eternal" -- Prev: EX mode
GM.OriginalAuthor = "AMT (ported and improved by D4 the Perth Fox)"
GM.Author = "Uklejamini"
GM.Version = "0.7.9-9" -- what version?


-- Constants
FRIENDLY_NPCS = {
	"npc_citizen"
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
	"npc_vortigaunt"
}

hook.Add("Initialize", "ClientsideHookHL2c_EX", function()
	GAMEMODE.EXMode = GetConVar("hl2ce_server_ex_mode_enabled"):GetBool()
end)
-- Create the teams that we are going to use throughout the game
function GM:CreateTeams()

	team.SetUp(TEAM_ALIVE, "alive", Color(192, 192, 192, 255))

	team.SetUp(TEAM_COMPLETED_MAP, "completedmap", Color(255, 215, 0, 255))

	team.SetUp(TEAM_DEAD, "dead", Color(128, 128, 128, 255))

end

function GM:GetReqXP(ply)
	local basexpreq = 152
	local addxpperlevel = 27
	local morelvlreq = 1.0715
	
	local totalxpreq = math.floor(basexpreq + (ply.Level  * addxpperlevel) ^ morelvlreq)

	if ply.Level >= 250 then
		totalxpreq = totalxpreq * math.max(1 + (ply.Level-250) * 0.05, 1)
	end
	if ply.Level >= 1000 then
		totalxpreq = totalxpreq * math.max(1, 1.0046^(ply.Level-1000))
	end
	return math.Round(totalxpreq)
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


-- Player input changes
function GM:StartCommand(ply, ucmd)
	if (ucmd:KeyDown(IN_SPEED) && IsValid(ply) && !ply:IsSuitEquipped()) then
		ucmd:RemoveKey(IN_SPEED)
	end

	if (ucmd:KeyDown(IN_WALK) && IsValid(ply) && !ply:IsSuitEquipped()) then
		ucmd:RemoveKey(IN_WALK)
	end
end


-- Players should never collide with each other or NPC's
function GM:ShouldCollide(entA, entB)

	-- Player and NPCs
	if (IsValid(entA) && IsValid(entB) && ((entA:IsPlayer() && (entB:IsPlayer() || entB:IsGodlikeNPC() or entB:IsFriendlyNPC())) || (entB:IsPlayer() && (entA:IsPlayer() || entA:IsGodlikeNPC() || entA:IsFriendlyNPC())))) then
		return false
	end

	-- Passenger seating
	if (IsValid(entA) && IsValid(entB) && ((entA:IsPlayer() && entA:InVehicle() && entA:GetAllowWeaponsInVehicle() && entB:IsVehicle()) || (entB:IsPlayer() && entB:InVehicle() && entB:GetAllowWeaponsInVehicle() && entA:IsVehicle()))) then
		return false
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

local SpecialPerson={
	["some some steamid"]={img="icon16/sheild.png",tooltip="insert some text here"}
}

function GM:IsSpecialPerson(ply, image)
	local img, tooltip
--i know this was copied from zombiesurvival gamemode but i was too lazy to make one by myself anyway
--you can add new special person table by yourself but you must keep the original ones and the new ones must be after steamid
	if ply:SteamID64() == "76561198274314803" then
		img = "icon16/award_star_gold_3.png"
		tooltip = "HL2c EX coder"
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

	if not img and not tooltip then
		if SpecialPerson[ply:SteamID()] or SpecialPerson[ply:SteamID64()] then
			local tbl=SpecialPerson[ply:SteamID()] or SpecialPerson[ply:SteamID64()]
			img=tbl.img
			tooltip=tbl.tooltip
		end
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

function GM:SetDifficulty(val, noncvar)
	local diffcvarvalue = tonumber(hl2ce_server_force_difficulty:GetString()) or 0

	if noncvar or diffcvarvalue <= 0 then
		SetGlobalString("hl2c_difficulty", tostring(math.Clamp(val, 0.3, 1e150)))
	end
end

-- Why 1e150 max difficulty? -- It might seem possible to go further.. But damage is only limited to 3.40e38. After that value it overflows to infinity.

function GM:GetDifficulty(noncvar)
	local str = GetGlobalString("hl2c_difficulty", 1)
	local diffcvarvalue = tonumber(hl2ce_server_force_difficulty:GetString()) or 1

	if not noncvar and diffcvarvalue > 0 then
		return math.Clamp(diffcvarvalue, 0.3, 1e150)
	end

	return math.Clamp(tonumber(str), 0.3, 1e150)
end


function FormatNumber(val, roundval)
	local log10_value = math.floor(math.log10(val))

	local txt
	local negative = val < 0
	roundval = roundval or 2
	val = math.abs(val)
	if val >= math.huge then return translate.Get("Inf") end
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

	if negative then
		val = -math.abs(val)
	end

	if txt then return txt end
	return math.floor(val*(10^(roundval or 1)))/(10^(roundval or 1))
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
