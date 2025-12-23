-- Send the required lua files to the client
AddCSLuaFile("break_infinity.lua")
AddCSLuaFile("cl_calcview.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_playermodels.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_scoreboard_playerlist.lua")
AddCSLuaFile("cl_scoreboard_playerrow.lua")
AddCSLuaFile("cl_viewmodel.lua")
AddCSLuaFile("cl_net.lua")
AddCSLuaFile("cl_options.lua")
AddCSLuaFile("cl_perksmenu.lua")
AddCSLuaFile("cl_prestige.lua")
AddCSLuaFile("cl_config.lua")
AddCSLuaFile("cl_upgradesmenu.lua")

AddCSLuaFile("sh_cvars.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_ents.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_translate.lua")
AddCSLuaFile("sh_pets.lua")

-- Include the required lua files
include("sh_init.lua")
include("sh_translate.lua")

include("npcvariants.lua")
-- include("database_manager/config.lua")
include("database_manager/player.lua")
include("database_manager/server.lua")

include("sv_netstuff.lua")
include("sv_player.lua")

include("player_leveling.lua")


-- Include the configuration for this map
if file.Exists(GM.VaultFolder.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	AddCSLuaFile("maps/"..game.GetMap()..".lua")
	include("maps/"..game.GetMap()..".lua")
end

-- Create data folders
if !file.IsDir(GM.VaultFolder, "DATA") then
	file.CreateDir(GM.VaultFolder)
end

if !file.IsDir(GM.VaultFolder.."/players", "DATA") then
	file.CreateDir(GM.VaultFolder.."/players")
end


-- Create console variables to make these config vars easier to access
COldGetConvar=COldGetConvar or GetConvar
function GetConvar(n)
	if(string.StartsWith(n,"hl2c_"))then
		return COldGetConvar("hl2ce"..string.sub(n,5))
	end
	return COldGetConvar(n)
end

-- Precache all the player models ahead of time
for _, playerModel in pairs(PLAYER_MODELS) do
	util.PrecacheModel(playerModel)
end


-- Called when the player attempts to suicide
function GM:CanPlayerSuicide(ply)
	if ply:Team() == TEAM_COMPLETED_MAP then
	
		ply:ChatPrint("You cannot suicide once you've completed the map.")
		return false
	elseif ply:Team() == TEAM_DEAD then
	
		ply:ChatPrint("This may come as a surprise, but you are already dead.")
		return false
	end

/*
	if !ply.vulnerable then
		ply:ChatPrint("You're currently invulnerable. Suicide attempt blocked!")
		return false
	end
*/
	return true
end 


-- Creates a spawn point
function GM:CreateSpawnPoint(pos, yaw)
	local ips = ents.Create("info_player_start")
	ips:SetPos(pos)
	ips:SetAngles(Angle(0, yaw, 0))
	ips:SetKeyValue("spawnflags", "1")
	ips:Spawn()
end

function GM:ReplaceSpawnPoint(pos, yaw)
	for _,ent in ipairs(ents.FindByClass("info_player_start")) do
		ent:Remove()
	end

	local ips = ents.Create("info_player_start")
	ips:SetPos(pos)
	ips:SetAngles(Angle(0, yaw, 0))
	ips:SetKeyValue("spawnflags", "1")
	ips:Spawn()
end


-- Creates a trigger delaymapload
function GM:CreateTDML(min, max)
	tdmlPos = max - ((max - min) / 2)

	local tdml = ents.Create("trigger_delaymapload")
	tdml:SetPos(tdmlPos)
	tdml.min = min
	tdml.max = max
	tdml:Spawn()
end


-- Called when the player dies
function GM:DoPlayerDeath(ply, attacker, dmgInfo)
	ply.deathPos = ply:EyePos()

	-- Add to deadPlayers table to prevent respawning on re-connect
	if ((!self.PlayerRespawning and !FORCE_PLAYER_RESPAWNING) or OVERRIDE_PLAYER_RESPAWNING) and !table.HasValue(deadPlayers, ply:SteamID()) then
		table.insert(deadPlayers, ply:SteamID())
	end
	
	ply:RemoveVehicle()
	if (ply:FlashlightIsOn()) then ply:Flashlight(false); end
	ply:CreateRagdoll()
	ply:SetTeam(TEAM_DEAD)
	ply:AddDeaths(1)

	-- Clear player info
	ply.info = nil

	-- RIP Eternity Upgrades
	ply.EternityUpgradeValues = {}
	for upgrade,_ in pairs(self.UpgradesEternity) do
		ply.EternityUpgradeValues[upgrade] = 0
	end


	if attacker:IsNPC() then
		net.Start("hl2ce_playerkilled")
		net.WriteString(attacker:GetClass())
		net.Send(ply)
	end
	
	local diff = self:GetDifficulty(true, true)
	self:SetDifficulty(infmath.max(1, diff * (
		diff >= InfNumber(1000) and 0.957 or diff >= InfNumber(100) and 0.962 or
		diff >= InfNumber(10) and 0.968 or diff >= InfNumber(4) and 0.974 or 0.98
	)))


	local lowermodelname = string.lower(ply:GetModel())

	-- Cache the voice set.

	ply:EmitSound("vo/npc/"..(string.find(lowermodelname, "female", 1, true) and "female01" or "male01").."/no0"..math.random(2)..".wav")

end


-- Called when the player is waiting to spawn
function GM:PlayerDeathThink(ply)
	if ply.NextSpawnTime and (ply.NextSpawnTime > CurTime()) then
		return
	end

	if ply:GetObserverMode() != OBS_MODE_ROAMING and (ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP)) then
		if (!self.PlayerRespawning and !FORCE_PLAYER_RESPAWNING) or OVERRIDE_PLAYER_RESPAWNING then
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetPos(ply.deathPos)
			ply:SetNoTarget(true)
		else
			ply:SetTeam(TEAM_ALIVE)
			ply:Spawn()
		end
	end
end


-- Called when entities are created
function GM:OnEntityCreated(ent)

	-- NPC Lag Compensation
	if self.LagCompensation and ent:IsNPC() or !table.HasValue(NPC_EXCLUDE_LAG_COMPENSATION, ent:GetClass()) then
		ent:SetLagCompensated(true)
	end

	-- Vehicle Passenger Seating
	if self.JeepPassengerSeat and !GetConVar("hl2_episodic"):GetBool() and ent:IsVehicle() and string.find(ent:GetClass(), "prop_vehicle_jeep") then
		ent.passengerSeat = ents.Create("prop_vehicle_prisoner_pod")
		ent.passengerSeat:SetPos(ent:LocalToWorld(Vector(21, -32, 18)))
		ent.passengerSeat:SetAngles(ent:LocalToWorldAngles(Angle(0, -3.5, 0)))
		ent.passengerSeat:SetModel("models/nova/jeep_seat.mdl")
		ent.passengerSeat:SetMoveType(MOVETYPE_NONE)
		ent.passengerSeat:SetParent(ent)
		ent.passengerSeat:Spawn()
		ent.passengerSeat:Activate()
		ent.passengerSeat.allowWeapons = true
	end

	if ent:IsNPC() and not ent:IsFriendlyNPC() and not table.HasValue(GODLIKE_NPCS, ent:GetClass()) then
		local diff = self:GetDifficulty()^0.1
		local diff2 = infmath.min(1e200, infmath.max(1, diff/1e10)^0.1)

		ent.ent_MaxHealthMul = (ent.ent_MaxHealthMul or 1) * infmath.min(diff, 1e5) * diff2
		ent.ent_HealthMul = (ent.ent_HealthMul or 1) * infmath.min(diff, 1e5) * diff2

		-- ent:EnableCustomCollisions(true)
	end

	timer.Simple(0, function()
		if !ent:IsNPC() then return end
		if ent.ent_MaxHealthMul then
			ent:SetMaxHealth(infmath.ConvertInfNumberToNormalNumber(ent.ent_MaxHealthMul * ent:Health()))
		end
		if ent.ent_HealthMul then
			ent:SetHealth(infmath.ConvertInfNumberToNormalNumber(ent.ent_HealthMul * ent:Health()))
		end
		if ent.ent_Color then
			ent:SetColor(ent.ent_Color)
		end
	end)
end


-- Called when map entities spawn
function GM:EntityKeyValue(ent, key, value)
	if ent:GetClass() == "trigger_changelevel" and key == "map" then
		ent.map = value
	end

	if ent:GetClass() == "npc_combine_s" and key == "additionalequipment" and value == "weapon_shotgun" then
		ent:SetSkin(1)
	end
end


-- Called when an entity has received damage
function GM:EntityTakeDamage(ent, dmgInfo)
	-- Gets the attacker
	local attacker = dmgInfo:GetAttacker()
	local damage = InfNumber(math.min(dmgInfo:GetDamage(), 2^128)) -- fuck the infinite damage's float limits
	local dmgdirect = bit.band(DMG_DIRECT, dmgInfo:GetDamageType()) ~= 0
	local difficulty = self:GetDifficulty()
	local eff_difficulty = ent:IsPlayer() and self:GetEffectiveDifficulty(ent) or attacker:IsPlayer() and self:GetEffectiveDifficulty(attacker) or difficulty

	-- Godlike NPCs take no damage ever
	if IsValid(ent) and table.HasValue(GODLIKE_NPCS, ent:GetClass()) and not MAP_FORCE_NO_FRIENDLIES then
		return true
	end

	-- NPCs cannot be damaged by friends
	if (IsValid(ent) and ent:IsNPC() and ent:GetClass() != "npc_turret_ground" and IsValid(attacker) and ent:Disposition(attacker) == D_LI) and not MAP_FORCE_NO_FRIENDLIES then
		return true
	end

	-- Gravity gun punt should kill NPC's (This isn't really needed anymore, as gmod has updated to be able to support Super Gravity Gun by itself)
	-- if (IsValid(ent) && ent:IsNPC() && IsValid(attacker) && attacker:IsPlayer()) then
		-- if (GetGlobalBool("SUPER_GRAVITY_GUN") && IsValid(attacker:GetActiveWeapon()) && (dmgInfo:GetInflictor():GetClass() == "weapon_physcannon")) then
			-- dmgInfo:SetDamage(ent:Health())
		-- end
	-- end

	-- Crowbar and Stunstick should follow skill level (Redundant)
	--[[
	if (IsValid(ent) && IsValid(attacker) && attacker:IsPlayer()) then
		if (IsValid(attacker:GetActiveWeapon()) && ((attacker:GetActiveWeapon():GetClass() == "weapon_crowbar" && dmgInfo:GetDamageType() == DMG_CLUB))) then
			damage = GetConVar("sk_plr_dmg_crowbar"):GetFloat()
		elseif IsValid(attacker:GetActiveWeapon()) && attacker:GetActiveWeapon():GetClass() == "weapon_stunstick" && dmgInfo:GetDamageType() == DMG_CLUB then
			damage = GetConVar("sk_plr_dmg_stunstick"):GetFloat()
		end
	end]]

	if attacker.NextDamageMul and (ent:IsNPC() or ent:IsPlayer()) then
		damage = damage * attacker.NextDamageMul
		attacker.NextDamageMul = nil
	end

	local attackerisworld = attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "trigger_waterydeath"
	local ispoisonheadcrab = attacker:GetClass() == "npc_headcrab_poison" or attacker:GetClass() == "npc_headcrab_black"

	if attacker:IsPlayer() then
		damage = damage * attacker:GetDamageMul(dmgInfo, ent)
	end

	if ent:IsPlayer() and not attackerisworld and not ispoisonheadcrab then
		damage = damage / ent:GetDamageResistanceMul(dmgInfo)
	end


	if ent:IsPlayer() and attacker:IsValid() and attackerisworld then
		damage = damage * math.max(1, ent:GetMaxHealth()*0.01)
	elseif ent:IsPlayer() and attacker == game.GetWorld() and dmgInfo:GetDamageType() == DMG_FALL then
		damage = damage * math.max(1, ent:GetMaxHealth()*0.01) * eff_difficulty^0.2
	end

	-- if (ent:IsPlayer() or ent:IsNPC() and ent:IsFriendlyNPC()) and attacker:IsNPC() then
	if (ent:IsPlayer() or ent:IsNPC() and ent:IsFriendlyNPC()) and attacker:IsNPC() and not attacker:IsFriendlyNPC() then
		-- print("increase damage", ent:IsFriendlyNPC(), attacker:IsFriendlyNPC())
		if not ispoisonheadcrab then
			damage = damage * eff_difficulty^0.7
		elseif ent:IsPlayer() and ent:HasPerkActive("1_antipoison") then
			damage = damage - math.min(self.EndlessMode and 100 or 25, ent:Health()/2)
		end
	end

	-- if ent:IsNPC() and not ent:IsFriendlyNPC() then
	if ent:IsNPC() and not ent:IsFriendlyNPC() and (attacker:IsFriendlyNPC() or attacker:IsPlayer()) then
		-- print("decrease damage", ent:IsFriendlyNPC())
		if ent:GetClass() ~= "npc_combinegunship" then
			damage = damage / eff_difficulty^0.55
		end
	end

	if ent:IsPlayer() and attacker:IsNPC() and not dmgdirect then
		local chance = (10 + math.max(0, (ent:GetMaxHealth()*0.75 - ent:Health())/ent:GetMaxHealth()*10)) / math.Clamp(1.1^math.max(0, ent.UnoReverseTimesActivated), 0, 100)
		if ent:HasPerkActive("3_uno_reverse") and ent:Health() <= ent:GetMaxHealth()*0.75 and math.Rand(1,100) <= chance then
			local d = DamageInfo()
			d:SetDamage(damage)
			d:SetDamageType(DMG_DIRECT)
			d:SetDamagePosition(dmgInfo:GetDamagePosition())
			d:SetDamageForce(dmgInfo:GetDamageForce())
			d:SetAttacker(ent)
			d:SetInflictor(inflictor or game.GetWorld())
			attacker:TakeDamageInfo(d)

			ent.UnoReverseTimesActivated = ent.UnoReverseTimesActivated + 1
			ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + ent:GetMaxHealth()*0.25))
			return true
		end

	end

	if ent:IsNPC() and attacker:IsPlayer() and not dmgdirect then
		if attacker:HasPerkActive("2_damage_of_eternity") then
			if math.random(100) <= 15 then
				local delayed = infmath.ConvertInfNumberToNormalNumber(damage)*2
				if ent.DelayedDamage then
					ent.DelayedDamage = ent.DelayedDamage + delayed
				else
					ent.DelayedDamage = delayed
				end
				ent.DelayedDamageAttacker = attacker
			end
		end

		if attacker:HasPerkActive("2_vampiric_killer") then
			local heal = math.ceil(infmath.ConvertInfNumberToNormalNumber(infmath.min(ent:Health(), damage)*0.2))
			attacker:SetHealth(math.min(attacker:Health() + heal, attacker:GetMaxHealth()))
		end
	end


	if ent ~= attacker and ent:IsNPC() and attacker:IsNPC() and (not attacker:IsFriendlyNPC() and not ent:IsFriendlyNPC()) then
		local diff = difficulty^0.1
		local diff2 = infmath.min(1e200, infmath.max(1, diff/1e10)^0.1)

		damage = damage * infmath.min(diff, 1e5) * diff2
	end

	infmath.ConvertInfNumberToNormalNumber(damage)
	dmgInfo:SetDamage(damage)

	-- if attacker:IsPlayer() then
		-- attacker:PrintMessage(3, tostring(damage))
	-- end

	if self.EXMode and attacker:GetClass() == "npc_sniper" and attacker.VariantType == 1 then
		PrintMessage(3, tostring(attacker).." "..(ent:IsPlayer() and ent:Nick() or ent:GetClass()).." "..dmgInfo:GetDamage())
	end

	local cantakedamage = ent:IsValid() and ent:IsPlayer() and not (ent:HasGodMode() or not gamemode.Call("PlayerShouldTakeDamage", ent, attacker)) or ent:IsValid() and !ent:IsPlayer()
	if cantakedamage then
		if ent:Inf_Health() > 2e9 then
			if infmath.ConvertInfNumberToNormalNumber(damage) < ent:Inf_Health() then
				dmgInfo:SetDamage(infmath.ConvertInfNumberToNormalNumber(infmath.min(damage, 2e9-1)))
			end

			ent:Inf_SetHealth(infmath.ConvertInfNumberToNormalNumber(ent:Inf_Health() - damage))
		end
	else return true
	end
end

function GM:PostEntityTakeDamage(ent, dmginfo, wasdamagetaken)
	local tookdamage = ent:IsPlayer() and not ent:HasGodMode() and wasdamagetaken or not ent:IsPlayer() and wasdamagetaken
	if tookdamage then
		if ent:Inf_Health() > 2e9 then
			ent:OldSetHealthEX(2.1e9)
		end
		ent:Inf_SetHealth(math.max(ent:OldHealthEX(), ent:Inf_Health()))
	end
end


-- Clears the player data folder
function GM:ClearPlayerDataFolder()
	local tableFiles, tableFolders = file.Find(self.VaultFolder.."/players/*", "DATA")
	for k, v in ipairs(tableFiles) do
		file.Delete(self.VaultFolder.."/players/"..v)
	end
end

function GM:WriteCampaignSaveData(ply, save)
	if !ply or !ply:IsValid() then return end
	local plyID = ply:SteamID64() || ply:UniqueID()
	if ply.hl2cSavedData and save then
		file.Write(self.VaultFolder.."/players/"..plyID..".txt", util.TableToJSON(ply.hl2cSavedData))
		return
	end


	local plyInfo = {}
	local plyWeapons = ply:GetWeapons()

	plyInfo.predicted_map = NEXT_MAP
	plyInfo.health = ply:Health()
	plyInfo.armor = ply:Armor()
	plyInfo.score = ply:Frags()
	plyInfo.deaths = ply:Deaths()
	plyInfo.model = ply.modelName
	plyInfo.SessionStats = ply.SessionStats
	if (IsValid(ply:GetActiveWeapon())) then plyInfo.weapon = ply:GetActiveWeapon():GetClass(); end
	if (plyWeapons && #plyWeapons > 0) then
		plyInfo.loadout = {}
		for _, wep in ipairs(plyWeapons) do
			plyInfo.loadout[wep:GetClass()] = {
				wep:Clip1(),
				wep:Clip2(),
				ply:GetAmmoCount(wep:GetPrimaryAmmoType()),
				ply:GetAmmoCount(wep:GetSecondaryAmmoType())
			}
		end
	end
	plyInfo.EternityUpgradeValues = ply.EternityUpgradeValues

	ply.hl2cSavedData = plyInfo

	if save then
		file.Write(self.VaultFolder.."/players/"..plyID..".txt", util.TableToJSON(plyInfo))
	end
end


-- Called by GoToNextLevel
function GM:GrabAndSwitch()
	changingLevel = true

	-- Since the file can build up with useless files we should clear it
	hook.Call("ClearPlayerDataFolder", GAMEMODE)

	-- Store player information
	for _, ply in ipairs(player.GetAll()) do
		self:WriteCampaignSaveData(ply, true)
		self:SavePlayer(ply)
	end

	timer.Simple(1, function() game.ConsoleCommand("changelevel "..NEXT_MAP.."\n") end)
end

function GM:ShutDown()
	for _,ply in ipairs(player.GetAll()) do
		self:SavePlayer(ply)
	end
	self:SaveServerData()
end

-- Called immediately after starting the gamemode  
function GM:Initialize()
	-- Variables and stuff
	deadPlayers = {}
	changingLevel = false
	checkpointPositions = {}
	nextAreaOpenTime = 0
	startingWeapons = {}

	self.XP_REWARD_ON_MAP_COMPLETION = self.XP_REWARD_ON_MAP_COMPLETION or 1 -- because it would call true if it was false, we use other values
	self:SetDifficulty(1)
	self.EXMode = self.EnableEXMode
	
	-- Network strings
	util.AddNetworkString("SetCheckpointPosition")
	util.AddNetworkString("NextMap")
	util.AddNetworkString("PlayerInitialSpawn")
	util.AddNetworkString("RestartMap")
	util.AddNetworkString("ShowHelp")
	util.AddNetworkString("ShowTeam")
	util.AddNetworkString("UpdatePlayerModel")
	util.AddNetworkString("ObjectiveTimer")
	
	util.AddNetworkString("XPGain")
	util.AddNetworkString("UpdateSkills")
	util.AddNetworkString("UpgradePerk")

	util.AddNetworkString("hl2c_playerready")
	util.AddNetworkString("hl2ce_prestige")
	util.AddNetworkString("hl2ce_firstprestige")
	util.AddNetworkString("hl2ce_unlockperk")
	util.AddNetworkString("hl2c_updatestats")
	util.AddNetworkString("hl2ce_updateperks")
	util.AddNetworkString("hl2ce_buyupgrade")
	util.AddNetworkString("hl2ce_updateeternityupgrades")
	util.AddNetworkString("hl2ce_finishedmap")
	util.AddNetworkString("hl2ce_boss")
	util.AddNetworkString("hl2ce_music")
	util.AddNetworkString("hl2ce_fail")
	util.AddNetworkString("hl2ce_map_event")
	util.AddNetworkString("hl2ce_playerkilled")

	-- We want regular fall damage and the ai to attack players and stuff
	game.ConsoleCommand("ai_disabled 0\n")
	game.ConsoleCommand("ai_ignoreplayers 0\n")
	game.ConsoleCommand("ai_serverragdolls 0\n")
	game.ConsoleCommand("npc_citizen_auto_player_squad 1\n")
	game.ConsoleCommand("mp_falldamage 1\n")
	game.ConsoleCommand("physgun_limited 1\n")
	game.ConsoleCommand("sv_alltalk 1\n")
	game.ConsoleCommand("sv_defaultdeployspeed 1\n")

	-- Physcannon
	game.ConsoleCommand("physcannon_tracelength 250\n")
	game.ConsoleCommand("physcannon_maxmass 250\n")
	game.ConsoleCommand("physcannon_pullforce 4000\n")
	
	-- Episodic
	if string.find(game.GetMap(), "ep1_") || string.find(game.GetMap(), "ep2_") then
		game.ConsoleCommand("hl2_episodic 1\n")
	else
		game.ConsoleCommand("hl2_episodic 0\n")
	end
	
	-- Force game rules such as aux power and max ammo
	if self.ForceGamerules then
		if !AUXPOW then game.ConsoleCommand("gmod_suit 1\n"); end
		game.ConsoleCommand("gmod_maxammo 0\n")	
	end

	-- Kill global states
	-- Reasoning behind this is because changing levels would keep these known states and cause issues on other maps
	hook.Call("KillAllGlobalStates", GAMEMODE)
	
	-- Jeep
	local jeep = {
		Name = "Jeep",
		Class = "prop_vehicle_jeep_old",
		Model = "models/buggy.mdl",
		KeyValues = {
			TargetName = "jeep",
			vehiclescript =	"scripts/vehicles/jeep_test.txt"
		}
	}
	list.Set("Vehicles", "Jeep", jeep)
	
	-- Airboat
	local airboat = {
		Name = "Airboat Gun",
		Class = "prop_vehicle_airboat",
		Category = Category,
		Model = "models/airboat.mdl",
		KeyValues = {
			TargetName = "airboat",
			vehiclescript = "scripts/vehicles/airboat.txt",
			EnableGun = 0
		}
	}
	list.Set("Vehicles", "Airboat", airboat)
	
	-- Airboat w/gun
	local airboatGun = {
		Name = "Airboat Gun",
		Class = "prop_vehicle_airboat",
		Category = Category,
		Model = "models/airboat.mdl",
		KeyValues = {
			TargetName = "airboat",
			vehiclescript = "scripts/vehicles/airboat.txt",
			EnableGun = 1
		}
	}
	list.Set("Vehicles", "Airboat Gun", airboatGun)
	
	-- Jalopy
	local jalopy = {
		Name = "Jalopy",
		Class = "prop_vehicle_jeep",
		Model = "models/vehicle.mdl",
		KeyValues = {
			TargetName = "jeep",
			vehiclescript =	"scripts/vehicles/jalopy.txt"
		}
	}
	list.Set("Vehicles", "Jalopy", jalopy)

	self:AddResources()
	self:LoadServerData()
	
	print(GAMEMODE.Name.." ("..GAMEMODE.Version..") gamemode loaded")
end

function GM:OnMapCompleted()
end

function GM:OnCampaignCompleted()
end

function GM:PostOnMapCompleted()
end

function GM:PostOnCampaignCompleted()
end

function GM:PlayerCompletedMap(ply)
	-- XP
	local txp = 0
	local xp = math.Round(math.Rand(4,7)) * infmath.min(self:GetDifficulty(), ply:GetMaxDifficultyXPGainMul())

	if (self.XP_REWARD_ON_MAP_COMPLETION or 1) > 0 then
		xp = xp * self.XP_REWARD_ON_MAP_COMPLETION
		txp = txp + xp
	end
	if ply.MapStats.GainedXP then
		xp = infmath.floor(ply.MapStats.GainedXP * 0.15)
		txp = txp + xp
	end

	if infmath.ConvertInfNumberToNormalNumber(txp) > 0 then
		ply:GiveXP(txp, true)
		ply:PrintMessage(HUD_PRINTTALK, Format("You were given additional %s XP for completing this map.", tostring(txp)))
	end

	-- Moneys
	local gain = ply.MoneysGain

	if infmath.ConvertInfNumberToNormalNumber(gain) > 0 then
		ply.MoneysGain = 0
		ply.Moneys = ply.Moneys + gain
		ply:PrintMessage(3, "You have gained +"..tostring(gain).." moneys")
	end

	if ply.MapStats then -- Map stats display after completing the map (Not yet.)
		net.Start("hl2ce_finishedmap")
		net.WriteTable(ply.MapStats)
		net.Send(ply)
	end

	self:NetworkString_UpdateStats(ply)
end

function GM:PlayerCompletedCampaign(ply)
	if !(ply and ply:IsValid()) then return end
	local map = game.GetMap()
	local gamename = "[INVALID]"
	if map == "d3_breen_01" then
		gamename = "Half-Life 2"
	elseif map == "ep1_c17_06" then
		gamename = "Half-Life 2: Episode One"
	elseif map == "ep2_outland_12a" then
		gamename = "Half-Life 2: Episode Two"
	end

	local xp = 1 + (2+math.max(0, math.log10(ply:Frags()))*0.2)
	if ply.MapStats.GainedXP then
		xp = xp * ply.MapStats.GainedXP*0.15
	end

	ply:PrintMessage(3, Format("Congratulations - you have completed %s", gamename))
	ply:PrintMessage(3, Format("You were awarded %s XP", ply:GiveXP(xp)))
end


-- Function for spawn points
local function MasterPlayerStartExists()

	-- Returns true if conditions are met
	for _, ips in pairs(ents.FindByClass("info_player_start")) do
		if (ips:HasSpawnFlags(1) || INFO_PLAYER_SPAWN) then
			return true
		end
	end

	return false
end

function GM:OnReloaded()
	local dothat = false
	if dothat and not game.IsDedicated() and GetConVar("sv_cheats"):GetBool() then
		for i=1,250 do
			RunConsoleCommand("ent_create","npc_handgrenade") -- oh my god what have i done
		end
	end

	print("Gamemode "..self.Name.." ("..self.Version..") files have been refreshed")
	timer.Simple(1, function()
		for _,ply in ipairs(player.GetAll()) do
			self:NetworkString_UpdateStats(ply)
			self:NetworkString_UpdateSkills(ply)
			self:NetworkString_UpdatePerks(ply)
			self:NetworkString_UpdateEternityUpgrades(ply)
		end
	end)
end

-- Called as soon as all map entities have been spawned 
function GM:MapEntitiesSpawned()

	-- Remove old spawn points
	if (MasterPlayerStartExists()) then
		for _, ips in pairs(ents.FindByClass("info_player_start")) do
			if (!ips:HasSpawnFlags(1) || INFO_PLAYER_SPAWN) then
				ips:Remove()
			end
		end
	end

	-- Setup INFO_PLAYER_SPAWN
	if (INFO_PLAYER_SPAWN) then
		GAMEMODE:CreateSpawnPoint(INFO_PLAYER_SPAWN[ 1 ], INFO_PLAYER_SPAWN[ 2 ])
	end

	-- Setup TRIGGER_CHECKPOINT
	if (!game.SinglePlayer() && TRIGGER_CHECKPOINT) then
		for _, tcpInfo in pairs(TRIGGER_CHECKPOINT) do
			local tcp = ents.Create("trigger_checkpoint")
			tcp.min = tcpInfo[ 1 ]
			tcp.max = tcpInfo[ 2 ]
			tcp.pos = tcp.max - ((tcp.max - tcp.min) / 2)
			tcp.skipSpawnpoint = tcpInfo[ 3 ]
			tcp.OnTouchRun = tcpInfo[ 4 ]
		
			tcp:SetPos(tcp.pos)
			tcp:Spawn()
		
			table.insert(checkpointPositions, tcp.pos)
		end
	end

	-- Setup TRIGGER_DELAYMAPLOAD
	if TRIGGER_DELAYMAPLOAD then
		GAMEMODE:CreateTDML(TRIGGER_DELAYMAPLOAD[1], TRIGGER_DELAYMAPLOAD[2])

		for _, tcl in pairs(ents.FindByClass("trigger_changelevel")) do
			tcl:Remove()
		end
	else
		for _, tcl in pairs(ents.FindByClass("trigger_changelevel")) do
			if (tcl.map == NEXT_MAP) then
				local tclMin, tclMax = tcl:WorldSpaceAABB()
				GAMEMODE:CreateTDML(tclMin, tclMax)
			end
			tcl:Remove()
		end
	end
	table.insert(checkpointPositions, tdmlPos)

	-- Remove all triggers that cause the game to "end"
	for _, trig in pairs(ents.FindByClass("trigger_*")) do
		if trig:GetName() == "fall_trigger" then
			trig:Remove()
		end
	end

	-- Call a map edit (used by map lua hooks)
	hook.Call("MapEdit", GAMEMODE, GAMEMODE)
end
function GM:InitPostEntity()
	RunConsoleCommand("sv_sticktoground", "0")

	gamemode.Call("MapEntitiesSpawned")
end
function GM:PostCleanupMap()
	gamemode.Call("MapEntitiesSpawned")
end

-- Called automatically or by the console command
function GM:NextMap()
	if changingLevel then return end

	changingLevel = true

	net.Start("NextMap")
	net.WriteFloat(CurTime())
	net.Broadcast()

	timer.Create("hl2c_next_map", NEXT_MAP_TIME, 1, function()
		self:GrabAndSwitch()
	end)
end
concommand.Add("hl2ce_next_map", function(ply) if (IsValid(ply) && ply:IsAdmin()) then NEXT_MAP_TIME = 0; hook.Call("NextMap", GAMEMODE); else ply:PrintMessage(HUD_PRINTTALK, "You are not admin!") end end)
concommand.Add("hl2ce_admin_respawn", function(ply, cmd, args)
	if IsValid(ply) && ply:IsAdmin() && (!ply:Alive() || table.HasValue(deadPlayers, ply:SteamID()) or args[1] == "force") && !changingLevel then
		table.RemoveByValue(deadPlayers, ply:SteamID())
		ply:SetTeam(TEAM_ALIVE)
		timer.Simple(0, function()
			ply:KillSilent()
			ply:Spawn()
		end)
		print(ply:Nick().." used respawn command!")
	else
		if !ply:IsAdmin() then
			ply:PrintMessage(HUD_PRINTTALK, "You are not admin!")
		elseif ply:Alive() || !table.HasValue(deadPlayers, ply:SteamID()) then
			ply:PrintMessage(HUD_PRINTTALK, "You are not dead!")
		elseif changingLevel then
			ply:PrintMessage(HUD_PRINTTALK, "Map is currenlty being changed, you can't respawn at this time!")
		end
	end
end)

-- Called when an NPC dies
function GM:OnNPCKilled(npc, killer, weapon)
	if (IsValid(killer) && killer:IsVehicle() && IsValid(killer:GetDriver()) && killer:GetDriver():IsPlayer()) then
		killer = killer:GetDriver()
	end

	-- If the killer is a player then decide what to do with their points
	if IsValid(killer) && killer:IsPlayer() && IsValid(npc) then
		local npcclass = npc:GetClass()
		if NPC_POINT_VALUES[npcclass] then
			killer:AddFrags(NPC_POINT_VALUES[npcclass])
		else
			killer:AddFrags(1)
		end

		local difficulty,nonmoddiff = self:GetDifficulty(), self:GetDifficulty(nil, true)
		if NPC_XP_VALUES[npcclass] then
			-- Too many local this is fine.
			local xp = NPC_XP_VALUES[npcclass] 
			local npckillxpmul,npckilldiffgainmul = self.XpGainOnNPCKillMul or 1, self.DifficultyGainOnNPCKillMul or 1
			local npcxpmul = npc.XPGainMult or 1

			local gainfromdifficultymul = infmath.min(difficulty^0.8, killer:GetMaxDifficultyXPGainMul())
			local better_knowledge_gain = killer:HasPerkActive("1_better_knowledge") and (self.EndlessMode and (infmath.ConvertInfNumberToNormalNumber(nonmoddiff) >= 6.50 and 1.55 or 1.3) or !self.EndlessMode and 1.25) or 1
			local xpmul = gainfromdifficultymul * npckillxpmul * npcxpmul * better_knowledge_gain

			if killer:GetSkillAmount("Knowledge") > 15 then
				npckilldiffgainmul = npckilldiffgainmul * (1 + (killer:GetSkillAmount("Knowledge")-15)*0.02)
			end
			if self.EndlessMode then
				if killer:HasPerkActive("1_difficult_decision") then
					npckilldiffgainmul = npckilldiffgainmul * 1.75
				end

				if killer:HasPerkActive("1_aggressive_gameplay") then
					npckilldiffgainmul = npckilldiffgainmul * 2.3
				end

				if killer:HasPerkActive("2_difficult_decision") then
					xpmul = xpmul * 1.45
					npckilldiffgainmul = npckilldiffgainmul * 3.35
				end

				if killer:HasPerkActive("3_difficult_decision") then
					xpmul = xpmul * 1.25
					npckilldiffgainmul = npckilldiffgainmul * difficulty:log10()*2.5
				end
			end
			killer:GiveXP(NPC_XP_VALUES[npcclass] * xpmul)
			self:SetDifficulty(nonmoddiff + xp*0.0005*npckilldiffgainmul*killer:GetEternityUpgradeEffectValue("difficultygain_upgrader"))
		end

		if NPC_MONEYS_VALUES[npcclass] then
			local moneys = NPC_MONEYS_VALUES[npcclass]
			local npckillxpmul,npckilldiffgainmul = self.MoneysGainOnNPCKillMul or 1
			local npcxpmul = npc.MoneyGainMult or 1
			killer:GiveMoneysGain(infmath.Round(NPC_MONEYS_VALUES[npcclass]*(infmath.min(killer:GetMaxDifficultyMoneyGainMul(), difficulty)^0.25)))
		end

		if killer:HasPerkActive("2_vampiric_killer") then
			if self.EndlessMode then
				killer:SetHealth(math.min(killer:GetMaxHealth(), killer:Health() + math.min(50, killer:GetMaxHealth()*0.04)))
			else
				killer:SetHealth(math.min(killer:GetMaxHealth(), killer:Health() + 2))
			end
		end
	end

	-- If the NPC is godlike and they die
	if IsValid(npc) then
		if npc:IsGodlikeNPC() then
			if IsValid(killer) and killer:IsPlayer() then
				game.KickID(killer:UserID(), "You killed an important NPC actor!")
			end

			PrintMessage(HUD_PRINTTALK, "Important NPC actor died!")
			gamemode.Call("FailMap", ply, "Important NPC died!")
		end
	end

	-- Convert the inflictor to the weapon that they're holding if we can
	if (IsValid(weapon) && (killer == weapon) && (weapon:IsPlayer() || weapon:IsNPC())) then
	
		weapon = weapon:GetActiveWeapon() 
		if (!IsValid(killer)) then weapon = killer; end 
	
	end 

	-- Defaults
	local weaponClass = "World" 
	local killerClass = "World" 

	-- Change to actual values if not default
	if (IsValid(weapon)) then weaponClass = weapon:GetClass(); end 
	if (IsValid(killer)) then killerClass = killer:GetClass(); end 

	-- Send a message
	if (IsValid(killer) && killer:IsPlayer()) then
	
		net.Start("PlayerKilledNPC")
		net.WriteString(npc:GetClass())
		net.WriteString(weaponClass)
		net.WriteEntity(killer)
		net.Broadcast()
	
	end
end

hook.Add("OnNPCKilled", "!NoMoreHarpoonInstaKills", function(ent, atk, inf)
	if inf:IsValid() and inf:GetModel() == "models/props_junk/harpoon002a.mdl" then return false end
end, HOOK_HIGH)

-- Called when a player tries to pickup a weapon
local gmod_maxammo = GetConVar("gmod_maxammo")
function GM:PlayerCanPickupWeapon(ply, wep)
	local wepclass = wep:GetClass()
	if ((ply:Team() != TEAM_ALIVE) || (table.HasValue(ADMINISTRATOR_WEAPONS, wepclass) && !ply:IsAdmin())) then
		return false
	end

	if ((wep:GetPrimaryAmmoType() <= 0) && ply:HasWeapon(wepclass)) then
		return false
	end

	if !gmod_maxammo:GetBool() then
		if (wep:GetPrimaryAmmoType() > 0) then
			if ply:HasWeapon(wepclass) && (ply:GetAmmoCount(wep:GetPrimaryAmmoType()) >= game.GetAmmoMax(wep:GetPrimaryAmmoType())) then
				return false
			end
		elseif (wep:GetSecondaryAmmoType() > 0) then
			if ply:HasWeapon(wepclass) && (ply:GetAmmoCount(wep:GetSecondaryAmmoType()) >= game.GetAmmoMax(wep:GetSecondaryAmmoType())) then
				return false
			end
		end
	end

	if (tonumber(wep.Slot) or 0) > 5 then
		ply:PrintMessage(HUD_PRINTCONSOLE, "Please type in console 'use "..wepclass.."' if you want to equip that weapon if you have one. (sorry about that)")
	end
	return true
end


-- Called when a player tries to pickup an item
function GM:PlayerCanPickupItem(ply, item)

	if (ply:Team() != TEAM_ALIVE) then
		return false
	end
	local class = item:GetClass()
	if class == "item_healthkit" then
		if ply:HasPerkActive("3_medkit_enhancer") then
			if ply:Health() < ply:GetMaxHealth() then
				timer.Simple(0, function() -- using a timer bcoz directly trying to set health while calling the hook won't really work much well
					-- but even with timer sethealth will still be called 1 tick later (Troublesome, no?)
					if not ply:IsValid() or not ply:Alive() then return end
					ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 100 + ply:GetMaxHealth()*0.2))
				end)
				return true
			end
		end
	elseif class == "item_healthvial" then
	end

	return true

end


-- Called when a player disconnects
function GM:PlayerDisconnected(ply)
	local plyID = ply:SteamID64() || ply:UniqueID()
	if file.Exists(self.VaultFolder.."/players/"..plyID..".txt", "DATA") then
		file.Delete(self.VaultFolder.."/players/"..plyID..".txt")
	end

	ply:RemoveVehicle()

	if game.IsDedicated() && player.GetCount() <= 1 then
		game.ConsoleCommand("changelevel "..game.GetMap().."\n")
	end
	self:SavePlayer(ply)
end


-- Called just before the player's first spawn 
function GM:PlayerInitialSpawn(ply)
	ply.startTime = CurTime()
	ply:SetTeam(TEAM_ALIVE)

	ply.XP = InfNumber(0)
	ply.Level = InfNumber(0)
	ply.StatPoints = InfNumber(0)


	-- a HUGE EXTREME LIST OF PRESTIGE LAYERS. (nah we stick to the ones previously for now)

	ply.Prestige = InfNumber(0)
	ply.PrestigePoints = InfNumber(0)
	ply.Eternities = InfNumber(0)
	ply.EternityPoints = InfNumber(0)
	ply.Celestiality = InfNumber(0)
	ply.CelestialityPoints = InfNumber(0)

	--[[
	ply.Resets = InfNumber(0) -- 2nd layer
	ply.ResetPoints = InfNumber(0)

	-- Infinite (XP: Past 1.8e308)
	ply.Infinities = InfNumber(0)
	ply.InfinityPoints = InfNumber(0)
	ply.Ascensions = InfNumber(0)
	ply.AscensionPoints = InfNumber(0)

	-- Extreme (XP: Past ~e100,000)
	ply.Transcendences = InfNumber(0)
	ply.TranscendencePoints = InfNumber(0)
	ply.Singularities = InfNumber(0)
	ply.SingularityPoints = InfNumber(0)
	ply.Hyperions = InfNumber(0)
	ply.HyperionPoints = InfNumber(0)
	ply.Omnipotence = InfNumber(0)
	ply.OmnipotencePoints = InfNumber(0)

	-- Godlous (XP: Past ~ee20)
	ply.Absolutes = InfNumber(0)
	ply.AbsolutePoints = InfNumber(0)
	ply.Voids = InfNumber(0)
	ply.VoidPoints = InfNumber(0)

	-- Ultimated (Past ~ee308)
	ply.Brokens = InfNumber(0)
	ply.BrokenPoints = InfNumber(0)
	ply.Transfinities = InfNumber(0)
	ply.TransfinityPoints = InfNumber(0)
	ply.Continuum = InfNumber(0)
	ply.ContinuumPoints = InfNumber(0)
	ply.Oblivion = InfNumber(0)
	ply.OblivionPoints = InfNumber(0)

	-- Hyper-Broken. (Past ~eee308)
	ply.Endlessness = InfNumber(0)
	ply.EndlessnessPoints = InfNumber(0)

	-- The END (Past eeee30)
	ply.Terminus = InfNumber(0)
	ply.TerminusPoints = InfNumber(0)
]]



	ply.Moneys = InfNumber(0)
	ply.MoneysGain = 0 -- Resets on restart and only gives after map completion


	ply.Skills = {}
	for k, v in pairs(self.SkillsInfo) do
		ply.Skills[k] = 0
	end

	ply.XPUsedThisPrestige = InfNumber(0)

	ply.UnlockedPerks = {}
	ply.DisabledPerks = {}

	ply.ConfigData = {}

	ply.MapStats = {}
	ply.SessionStats = {}

	ply.EternityUpgradeValues = {}
	for upgrade,_ in pairs(self.UpgradesEternity) do
		ply.EternityUpgradeValues[upgrade] = 0
	end

	-- Grab previous map info
	local plyID = ply:SteamID64() || ply:UniqueID()
	if (file.Exists(self.VaultFolder.."/players/"..plyID..".txt", "DATA")) then
		ply.info = util.JSONToTable(file.Read(self.VaultFolder.."/players/"..plyID..".txt", "DATA"))
		if ((ply.info.predicted_map != game.GetMap()) || RESET_PL_INFO) then
			file.Delete(self.VaultFolder.."/players/"..plyID..".txt")
			ply.info = nil
		elseif (RESET_WEAPONS) then
			ply.info.loadout = nil
		end
	end

	ply:SetFrags(0)
	ply:SetDeaths(0)

	self:LoadPlayer(ply)


	-- Objective Timer (OUT OF DATE)
	-- net.Start("ObjectiveTimer")
	-- net.WriteFloat(self.ObjectiveTimer or 0)
	-- net.Broadcast()
	

	-- Send initial player spawn to client
	net.Start("PlayerInitialSpawn")
	net.WriteBool(self.CustomPMs)
	net.Send(ply)

	-- Send current checkpoint position
	if (#checkpointPositions > 0) then
		net.Start("SetCheckpointPosition")
		net.WriteVector(checkpointPositions[1])
		net.Send(ply)
	end

	-- Prompt players that they can spawn vehicles
	if ALLOWED_VEHICLE then
		ply:ChatPrint("Vehicle spawning is allowed! Press F3 (Spare 1) to spawn it.")
	end

	self:NetworkString_UpdateStats(ply)

	-- EP1 and EP2 maps might be buggy with npc spawns. By then, Restart Map upon starting the game.
	if player.GetCount() == 1 and (self.WasForcedRestart or 0) < (FORCE_RESTART_COUNT or 1) and (string.find(game.GetMap(), "ep1_") or string.find(game.GetMap(), "ep2_")) and not NEVER_FORCE_RESTART then
    	timer.Simple(1, function()
    	    self.WasForcedRestart = (self.WasForcedRestart or 0) + 1
    	    GAMEMODE:RestartMap(0, true)
    	    print("forced restart initiate")
    	end)
    	print("force restart in 1 sec")
	end
end 

function GM:PlayerReady(ply)
	self:NetworkString_UpdateStats(ply)
	self:NetworkString_UpdateSkills(ply)
	self:NetworkString_UpdatePerks(ply)
	self:NetworkString_UpdateEternityUpgrades(ply)
end

function GM:ReachedCheckpoint(ply) -- ply is activator, not working yet

end


-- Called by GM:PlayerSpawn
function GM:PlayerLoadout(ply)

	if (ply.info && ply.info.loadout) then
	
		for wep, ammo in pairs(ply.info.loadout) do
		
			ply:Give(wep)
		
		end
	
		if (ply.info.weapon) then
		
			ply:SelectWeapon(ply.info.weapon)
		
		end
	
		ply:RemoveAllAmmo()
	
		for _, wep in ipairs(ply:GetWeapons()) do
		
			local wepClass = wep:GetClass()
		
			if (ply.info.loadout[ wepClass ]) then
			
				wep:SetClip1(tonumber(ply.info.loadout[ wepClass ][ 1 ]))
				wep:SetClip2(tonumber(ply.info.loadout[ wepClass ][ 2 ]))
				ply:GiveAmmo(tonumber(ply.info.loadout[ wepClass ][ 3 ]), wep:GetPrimaryAmmoType())
				ply:GiveAmmo(tonumber(ply.info.loadout[ wepClass ][ 4 ]), wep:GetSecondaryAmmoType())
			
			end
		
		end
	
	elseif (startingWeapons && (#startingWeapons > 0)) then
	
		for _, wep in pairs(startingWeapons) do
			if wep[WHITELISTED_WEAPONS] then
				ply:Give(wep)
			end
		
		end
	
	end

	-- Lastly give physgun to admins
	if self.AdminPhysgun and ply:IsAdmin() then
		ply:Give("weapon_physgun")
	end

	if ply:IsSuitEquipped() and self.PlayerMedkitOnSpawn then
		ply:Give("weapon_hl2ce_medkit")
	end

	hook.Call("PostPlayerLoadout", GAMEMODE, ply)

end


-- Called when the player attempts to noclip
function GM:PlayerNoClip(ply)
	if !ply:Alive() then
		-- ply:PrintMessage(HUD_PRINTTALK, "You can't noclip when you are dead, can't you see?!")
		return false
	end

	return ply:IsAdmin() && self.AdminNoclip
end


-- Returns whether the spawnpoint is suitable or not
function GM:IsSpawnpointSuitable(ply, spawnpointEnt, bMakeSuitable)

	return true

end


-- Select the player spawn
function hl2cPlayerSelectSpawn(ply)

	if (MasterPlayerStartExists()) then
	
		local spawnPoints = ents.FindByClass("info_player_start")
		return spawnPoints[ #spawnPoints ]
	
	end

end
hook.Add("PlayerSelectSpawn", "hl2cPlayerSelectSpawn", hl2cPlayerSelectSpawn)


-- Set the player model
function GM:PlayerSetModel(ply)

	-- Stores the model as a variable part of the player
	if (!self.CustomPMs && ply.info && ply.info.model) then
	
		ply.modelName = ply.info.model
	
	else
	
		local modelName = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))
	
		if (self.CustomPMs || (modelName && table.HasValue(PLAYER_MODELS, string.lower(modelName)))) then
		
			ply.modelName = modelName
		
		else
		
			ply.modelName = table.Random(PLAYER_MODELS)
		
		end
	
	end

	if (!self.CustomPMs) then
	
		if (ply:IsSuitEquipped()) then
		
			ply.modelName = string.gsub(string.lower(ply.modelName), "group01", "group03")
		
		else
		
			ply.modelName = string.gsub(string.lower(ply.modelName), "group03", "group01")
		
		end
	
	end

	-- Precache and set the model
	util.PrecacheModel(ply.modelName)
	ply:SetModel(ply.modelName)
	ply:SetupHands()

	-- Skin, modelgroups and player color are primarily a custom playermodel thing
	if (self.CustomPMs) then
	
		ply:SetSkin(ply:GetInfoNum("cl_playerskin", 0))
	
		ply.modelGroups = ply:GetInfo("cl_playerbodygroups")
		if (ply.modelGroups == nil) then ply.modelGroups = "" end
		ply.modelGroups = string.Explode(" ", ply.modelGroups)
		for k = 0, (ply:GetNumBodyGroups() - 1) do
		
			ply:SetBodygroup(k, (tonumber(ply.modelGroups[ k + 1 ]) || 0))
		
		end
	
		ply:SetPlayerColor(Vector(ply:GetInfo("cl_playercolor")))
	
	end

	-- A hook for those who want to call something after the player model is set
	hook.Call("PostPlayerSetModel", GAMEMODE, ply)

end


-- Called when a player spawns 
function GM:PlayerSpawn(ply)
	player_manager.SetPlayerClass(ply, "player_default")

	if (((!self.PlayerRespawning && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING) && (ply:Team() == TEAM_DEAD)) then
	
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetPos(ply.deathPos)
		ply:SetNoTarget(true)
	
		return
	
	end

	-- If we made it this far we might might not even be dead
	ply:SetTeam(TEAM_ALIVE)

	-- Player vars
	ply.givenWeapons = {}
	ply.vulnerable = false
	timer.Simple(VULNERABLE_TIME, function() if IsValid(ply) then ply.vulnerable = true; end end)

	-- Player statistics
	ply:UnSpectate()
	ply:ShouldDropWeapon((!self.PlayerRespawning && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING)
	ply:AllowFlashlight(GetConVar("mp_flashlight"):GetBool())
	ply:SetCrouchedWalkSpeed(0.3)
	gamemode.Call("SetPlayerSpeed", ply, 190, 320)
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)

	ply.HyperArmorCharge = 0
	ply.UnoReverseTimesActivated = 0

	-- Set stuff from last level

	local maxhp = ply:GetOriginalMaxHealth()
	local maxap = 100 -- calculate their max armor
	if ply:HasPerkActive("1_super_armor") then
		maxap = maxap + (self.EndlessMode and 30 or 5)
	end
	if self.EndlessMode then
		if ply:HasPerkActive("2_hyper_armor") then
			maxap = maxap + 100
		end
		if ply:HasPerkActive("3_celestial") then
			maxap = maxap + 80
		end
	end
	maxap = math.min(1e9, maxap)


	if ply.info then
		if ply.info.health > 0 then
			ply:SetHealth(ply.info.health)
		end
	
		if ply.info.armor > 0 then
			ply:SetArmor(ply.info.armor)
		end

		if ply.info.Stats then
			
		end
	
		ply:SetFrags(ply.info.score)
		ply:SetDeaths(ply.info.deaths)

		if ply.info.EternityUpgradeValues then
			ply.EternityUpgradeValues = ply.info.EternityUpgradeValues
		end
	else
		ply:SetHealth(maxhp)
	end
	ply:SetMaxHealth(maxhp)
	ply:SetMaxArmor(maxap)

	-- Players should avoid players
	ply:SetCustomCollisionCheck(!game.SinglePlayer())
	ply:SetAvoidPlayers(false)
	ply:SetNoTarget(false)

	-- If the player died before, kill them again
	if table.HasValue(deadPlayers, ply:SteamID()) then
		ply:PrintMessage(HUD_PRINTTALK, "You cannot respawn now.")
		ply.deathPos = ply:EyePos()
	
		ply:RemoveVehicle()
		ply:Flashlight(false)
		ply:SetTeam(TEAM_DEAD)
		ply:KillSilent()
	end
end


-- Called when a player uses their flashlight
function GM:PlayerSwitchFlashlight(ply, on)
	-- Dead players cannot use it
	if ply:Team() != TEAM_ALIVE && on then
		return false
	end

	-- Handle flashlight with AUX
	if ply:GetSuitPower() < 10 && on then
		return false
	end

	return ply:IsSuitEquipped() && ply:CanUseFlashlight()
end


-- Called when a player uses something
function GM:PlayerUse(ply, ent)

	if ((ent:GetName() == "telescope_button") || (ply:Team() != TEAM_ALIVE)) then
	
		return false
	
	end

	return true

end


-- Called to control whether a player can enter the vehicle or not
function GM:CanPlayerEnterVehicle(ply, vehicle, role)

	-- Used for passenger seating
	ply:SetAllowWeaponsInVehicle(vehicle.allowWeapons)

	return true

end


-- Called automatically and by the console command
function GM:RestartMap(overridetime, noplayerdatasave)
	if changingLevel then return end

	overridetime = overridetime or RESTART_MAP_TIME
	changingLevel = true

	net.Start("RestartMap")
	net.WriteFloat(CurTime())
	net.Broadcast()

	timer.Create("hl2c_restart_map", overridetime, 1, function()
		if not noplayerdatasave then
			for k,v in ipairs(player.GetAll()) do
				self:SavePlayer(v)
			end

			self:SaveServerData()
		end

		timer.Simple(1, function()
			if MAP_FORCE_CHANGELEVEL_ON_MAPRESTART then
				if noplayerdatasave then self.DisableDataSave = true end
				RunConsoleCommand("changelevel", game.GetMap())
			else
				net.Start("RestartMap")
				net.WriteFloat(-1)
				net.Broadcast()
				self:Initialize() -- why run GAMEMODE:Initialize() again? so that difficulty will also reset if noplayerdatasave is true
				changingLevel = true
				game.CleanUpMap(false, {"env_fire", "entityflame", "_firesmoke"}, function()
					changingLevel = nil
					local plyrespawn = FORCE_PLAYER_RESPAWNING
					FORCE_PLAYER_RESPAWNING = true
					for k,v in ipairs(player.GetAll()) do
						self:PlayerInitialSpawn(v)
						v:KillSilent()
						v:SetTeam(TEAM_ALIVE)
						timer.Simple(0.05, function()
							v:Spawn()
						end)
					end
					changingLevel = false
					FORCE_PLAYER_RESPAWNING=plyrespawn
				end)
			end
		end)
	end)
end
concommand.Add("hl2ce_restart_map", function(ply) if (IsValid(ply) && ply:IsAdmin()) then gamemode.Call("RestartMap", 0); end end)

function GM:OnMapFailed(ply)
	local diff = self:GetDifficulty(true, true)
	if diff > InfNumber(math.huge) then
		local result = 0.8/(1+math.log10(diff:log10())-math.log10(33))
		self:SetDifficulty(diff^(0.9/math.log10(diff:log10())))
	elseif diff > InfNumber(1, 33) then
		local result = 0.9/(1+math.log10(diff:log10())-math.log10(33))
		self:SetDifficulty(diff^(0.9/math.log10(diff:log10())))
	elseif diff > InfNumber(1, 4) then
		self:SetDifficulty(diff^0.95)
	else
		self:SetDifficulty(infmath.max(1, diff * (
			diff >= InfNumber(1000) and 0.85 or diff >= InfNumber(100) and 0.87 or
			diff >= InfNumber(10) and 0.87 or diff >= InfNumber(4) and 0.89 or 0.91
		)))
	end
end

function GM:FailMap(ply, reason) -- ply is the one who caused the map to fail, giving them a quite big penalty
	if changingLevel then return end
	net.Start("hl2ce_fail")
	net.WriteString(reason or "Map failed!")
	net.Broadcast()

	self:RestartMap()

	if ply and ply:IsValid() and ply:IsPlayer() then
		local xploss = ply.XP*0.1 + ply.MapStats.XPGained*1.1
		ply.XP = ply.XP - xploss

		ply:PrintMessage(3, "Don't cause the map to fail.")
		ply:PrintMessage(3, "Lost "..xploss.." XP.")
	end

	gamemode.Call("OnMapFailed", ply)
end


-- Called every time a player does damage to an npc
function GM:ScaleNPCDamage(npc, hitGroup, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	-- Where are we hitting?
	if (hitGroup == HITGROUP_HEAD) then
		hitGroupScale = GetConVarNumber("sk_npc_head")
	elseif (hitGroup == HITGROUP_CHEST) then
		hitGroupScale = GetConVarNumber("sk_npc_chest")
	elseif (hitGroup == HITGROUP_STOMACH) then
		hitGroupScale = GetConVarNumber("sk_npc_stomach")
	elseif ((hitGroup == HITGROUP_LEFTARM) || (hitGroup == HITGROUP_RIGHTARM)) then
		hitGroupScale = GetConVarNumber("sk_npc_arm")
	elseif ((hitGroup == HITGROUP_LEFTLEG) || (hitGroup == HITGROUP_RIGHTLEG)) then
		hitGroupScale = GetConVarNumber("sk_npc_leg")
	else
		hitGroupScale = 1
	end

	-- Calculate the damage
end


-- Scale the damage based on being shot in a hitbox 
function GM:ScalePlayerDamage(ply, hitGroup, dmgInfo)

	-- Where are we even hitting?
	if (hitGroup == HITGROUP_HEAD) then
		hitGroupScale = GetConVarNumber("sk_player_head")
	elseif (hitGroup == HITGROUP_CHEST) then
		hitGroupScale = GetConVarNumber("sk_player_chest")
	elseif (hitGroup == HITGROUP_STOMACH) then
		hitGroupScale = GetConVarNumber("sk_player_stomach")
	elseif ((hitGroup == HITGROUP_LEFTARM) || (hitGroup == HITGROUP_RIGHTARM)) then
		hitGroupScale = GetConVarNumber("sk_player_arm")
	elseif ((hitGroup == HITGROUP_LEFTLEG) || (hitGroup == HITGROUP_RIGHTLEG)) then
		hitGroupScale = GetConVarNumber("sk_player_leg")
	else
		hitGroupScale = 1
	end

	-- Calculate the damage
end 


-- Called when player presses their help key
function GM:ShowHelp(ply)

	net.Start("ShowHelp")
	net.Send(ply)

end


-- Called when a player presses their show team key
function GM:ShowTeam(ply)

	net.Start("ShowTeam")
	net.Send(ply)

end


-- Called when player wants a vehicle
function GM:ShowSpare1(ply)

	if ((ply:Team() != TEAM_ALIVE) || ply:InVehicle()) then
		return
	end

	if (!ALLOWED_VEHICLE) then
		ply:PrintMessage(HUD_PRINTTALK, "You may not spawn a vehicle at this time.")
		return
	end

	for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 256)) do
		if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent != ply then
			ply:PrintMessage(HUD_PRINTTALK, "There are players around you! Find an open space to spawn your vehicle.")
			return
		end
	end

	-- Spawn the vehicle
	if ALLOWED_VEHICLE then
	
		local vehicleList = list.Get("Vehicles")
		local vehicle = vehicleList[ ALLOWED_VEHICLE ]
	
		if !vehicle then
			return
		end
	
		local plyAngle = ply:EyeAngles()
		local startpos = ply:GetPos() + Vector(0, 0, 48)
		local spawnpos = startpos + plyAngle:Forward() * 160

		local tr = {}
		local trace = util.TraceLine({
			start = startpos,
			endpos = spawnpos
		})
		if trace.HitWorld or not util.IsInWorld(spawnpos) then
			ply:ChatPrint("Insufficient space for spawning in a vehicle!")
			return
		end

		ply:RemoveVehicle()

		-- Create the new entity
		ply.vehicle = ents.Create(vehicle.Class)
		ply.vehicle:SetModel(vehicle.Model)
	
		-- Set keyvalues
		for a, b in pairs(vehicle.KeyValues) do
			ply.vehicle:SetKeyValue(a, b)
		end
	
		-- Enable gun on jeep
		if ALLOWED_VEHICLE == "Jeep" then
			ply.vehicle:Fire("EnableGun", "1")
		end
	
		-- Set pos/angle and spawn
		ply.vehicle:SetPos(spawnpos)
		ply.vehicle:SetAngles(Angle(0, plyAngle.y - 90, 0))
		ply.vehicle:Spawn()
		ply.vehicle:Activate()
		if ALLOWED_VEHICLE == "Jeep" then ply.vehicle:SetBodygroup(1, 1) end
		ply.vehicle.creator = ply
	end
end


-- Called when player wants to remove their vehicle
function GM:ShowSpare2(ply)
	if (ply:Team() != TEAM_ALIVE) || ply:InVehicle() then
		return
	end

	if !ALLOWED_VEHICLE then
		ply:PrintMessage(HUD_PRINTTALK, "You may not remove your vehicle at this time.")
		return
	end

	ply:RemoveVehicle()
end

local SecondTick = 0
local delayedDMGTick = 0
-- Called every frame 
function GM:Think()

	-- Restart the map if all players are dead
	if ((!self.PlayerRespawning and !FORCE_PLAYER_RESPAWNING) or OVERRIDE_PLAYER_RESPAWNING) and player.GetCount() > 0 and ((team.NumPlayers(TEAM_ALIVE) + team.NumPlayers(TEAM_COMPLETED_MAP)) <= 0) then
		if !changingLevel then
			gamemode.Call("FailMap", nil, "All players have died!")

			for _,ply in ipairs(player.GetAll()) do
				if ply:Team() ~= TEAM_ALIVE and ply:Team() ~= TEAM_COMPLETED_MAP and ply:Team() ~= TEAM_DEAD then
					PrintMessage(3, "One of the players are on the invalid team!")
					if ULib and ULib.isSandbox and ULib.isSandbox() then
						PrintMessage(3, "It's likely it's due to a team being applied to one of the player's groups!")
					end

					break
				end
			end
		end
	end

	-- Change the difficulty according to number of players
	if player.GetCount() > 0 then
		if self.EndlessMode then
			game.SetSkillLevel(2)
			-- game.SetSkillLevel(math.Clamp(math.floor(self:GetDifficulty()), 1, 3))
		elseif self.DynamicSkillLevel then
			self:SetDifficulty(math.Clamp((0.55 + (player.GetCount() / 4.7)), DIFFICULTY_RANGE[1], DIFFICULTY_RANGE[2]))
			game.SetSkillLevel(2)
			-- game.SetSkillLevel(math.Clamp(math.floor(self:GetDifficulty()), 1, 3))
		end
	end

	if SecondTick < CurTime() then
		SecondTick = CurTime() + 1

		for _,ply in ipairs(player.GetAll()) do
			if ply:HasPerkActive("2_hyper_armor") then
				if ply:WaterLevel() < 3 and ply:GetSuitPower() < 100 then
					ply:SetSuitPower(math.min(100, ply:GetSuitPower() + 1))
					ply.HyperArmorCharge = 0
				elseif ply:GetSuitPower() >= 100 and ply:Armor() < ply:GetMaxArmor() then
					ply.HyperArmorCharge = ply.HyperArmorCharge + 0.2
					ply:SetArmor(ply:Armor() + math.floor(ply.HyperArmorCharge))
					ply.HyperArmorCharge = ply.HyperArmorCharge - math.floor(ply.HyperArmorCharge)
				end
			end
		end
	end

	-- Open area portals
	if nextAreaOpenTime <= CurTime() then
		for _, fap in ipairs(ents.FindByClass("func_areaportal")) do
			fap:Fire("Open")
		end
		nextAreaOpenTime = CurTime() + 1
	end

	/*
	for _,ent in pairs(ents.FindByClass("npc_*")) do
		if ent.IsPet then
			-- print(ent)
			ent:AddRelationship("player D_FR 99")
			for k,v in pairs(FRIENDLY_NPCS) do
				for _,e in pairs(ents.FindByClass(v)) do
					ent:AddEntityRelationship(e, D_FR, 99)
					e:AddEntityRelationship(ent, D_FR, 99)
				end
			end
			for k,v in pairs(GODLIKE_NPCS) do
				for _,e in pairs(ents.FindByClass(v)) do
					ent:AddEntityRelationship(e, D_FR, 99)
					e:AddEntityRelationship(ent, D_FR, 99)
				end
			end
		end
	end
*/

	if delayedDMGTick + 0.5 < CurTime() then
		for _,ent in ipairs(ents.GetAll()) do
			if ent.DelayedDamage and ent.DelayedDamage >= 1 then
				local mult = (1 - (0.8 / math.max(1, math.log10(ent.DelayedDamage) - 2)))
				ent.DelayedDamage = ent.DelayedDamage - math.ceil(ent.DelayedDamage*mult)



				local dmg = DamageInfo()
				dmg:SetDamage(math.ceil(ent.DelayedDamage*mult))
				dmg:SetDamageType(DMG_DIRECT)
				dmg:SetAttacker(ent.DelayedDamageAttacker or game.GetWorld())
				dmg:SetInflictor(game.GetWorld())
				ent:TakeDamageInfo(dmg)
			end
		end

		delayedDMGTick = CurTime()
	end
end


-- Player just picked up or was given a weapon
function GM:WeaponEquip(wep)
	if IsValid(wep) and !table.HasValue(startingWeapons, wep:GetClass()) then
		table.insert(startingWeapons, wep:GetClass())
	end
end


-- Tell the game to update the player's playermodel
local function UpdatePlayerModel(len, ply)
	if IsValid(ply) and ply:Team() == TEAM_ALIVE then
		hook.Call("PlayerSetModel", GAMEMODE, ply)
	end
end
net.Receive("UpdatePlayerModel", UpdatePlayerModel)

net.Receive("hl2c_playerready", function(len, ply)
	gamemode.Call("PlayerReady", ply)
end)


-- Dynamic skill level console variable was changed
local function DynamicSkillToggleCallback(name, old, new)
	if GAMEMODE.EndlessMode then
		game.SetSkillLevel(2)
		-- game.SetSkillLevel(math.Clamp(math.floor(GAMEMODE:GetDifficulty()), 1, 3))
	elseif !self.DynamicSkillLevel then
		GAMEMODE:SetDifficulty(DIFFICULTY_RANGE[1])
		game.SetSkillLevel(2)
		-- game.SetSkillLevel(math.Clamp(math.floor(GAMEMODE:GetDifficulty()), 1, 3))
	end
end
cvars.AddChangeCallback("hl2c_server_dynamic_skill_level", DynamicSkillToggleCallback, "DynamicSkillToggleCallback")

function GM:OnDamagedByExplosion(ply)
	if ply:GetInfoNum("hl2ce_cl_noearringing", 0) >= 1 then
		return
	end

	ply:SetDSP(35)
end

-- function GM:PlayerHurt(victim, attacker)
-- end

function GM:AcceptInput(ent, input, activator, caller, value)
	if string.lower(input) == "sethealth" then
		if value == "0" and (ent:IsPlayer() or ent:IsNPC()) then
			ent:SetHealth(0)
			ent:TakeDamage(0)
		elseif value == "100" and ent:IsPlayer() then -- fucking instakills on trigger
			ent:SetHealth(ent:GetMaxHealth())
			return true
		-- else
		-- 	ent:SetHealth(value)
		-- 	return true			
		end
	end
end


function GM:PlayerSpawnEffect(ply, model)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnNPC(ply, npc, weapon)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnObject(ply, model, skin)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnProp(ply, model)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnRagdoll(ply, model)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnSENT(ply, class)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnSWEP(ply, weapon, swep)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:PlayerSpawnVehicle(ply, model, name, tbl)
	if !ply:IsSuperAdmin() then return false end
	return true
end

function GM:AddResources()
	resource.AddFile("sound/hl2c_eternal/music/chopper_fight.wav")
end
