-- Send the required lua files to the client
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

AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_ents.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_translate.lua")

-- Include the required lua files
include("sh_translate.lua")
include("sh_init.lua")

include("npcvariants.lua")
-- include("database_manager/config.lua")
include("database_manager/player.lua")
include("database_manager/server.lua")

include("sv_netstuff.lua")
include("player_leveling.lua")

RunConsoleCommand("sv_airaccelerate",9999)
RunConsoleCommand("sv_sticktoground",0)
RunConsoleCommand("sv_maxvelocity",25000)

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
local hl2c_admin_physgun = CreateConVar("hl2c_admin_physgun", ADMIN_NOCLIP, FCVAR_NOTIFY)
local hl2c_admin_noclip = CreateConVar("hl2c_admin_noclip", ADMIN_PHYSGUN, FCVAR_NOTIFY)
local hl2c_server_force_gamerules = CreateConVar("hl2c_server_force_gamerules", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2c_server_custom_playermodels = CreateConVar("hl2c_server_custom_playermodels", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2c_server_checkpoint_respawn = CreateConVar("hl2c_server_checkpoint_respawn", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2c_server_dynamic_skill_level = CreateConVar("hl2c_server_dynamic_skill_level", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2c_server_lag_compensation = CreateConVar("hl2c_server_lag_compensation", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2c_server_player_respawning = CreateConVar("hl2c_server_player_respawning", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2c_server_jeep_passenger_seat = CreateConVar("hl2c_server_jeep_passenger_seat", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
local hl2ce_server_ex_mode_enabled = CreateConVar("hl2ce_server_ex_mode_enabled", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE })
COldGetConvar=COldGetConvar or GetConvar
function GetConvar(n)
	if(string.StartsWith(n,"hl2c_"))then
		local e=COldGetConvar("hl2ce"..string.sub(n,4))
		if IsValid(e) then
			return e
		end
	end
	return COldGetConvar(n)
end

-- Precache all the player models ahead of time
for _, playerModel in pairs(PLAYER_MODELS) do

	util.PrecacheModel(playerModel)

end

function GM:AcceptInput(ent,input,acti,caller,value)
	if ent:GetClass()=="logic_autosave" then
		if acti:IsPlayer() then
			local pos=acti:GetPos()	
			local ang=acti:EyeAngles()
			local foundcp=false
			for i,v in ipairs(ents.FindInSphere(pos,800))do
				if v:GetClass()=="trigger_checkpoint" then
					foundcp=true
					break
				end
			end
			if not foundcp then
				self:CreateSpawnPoint(pos,acti:EyeAngles().y)
				for _, ply in pairs( player.GetAll() ) do
					if ( GetConVar( "hl2c_server_checkpoint_respawn" ):GetBool() && IsValid( ply ) && ( ply != ent ) && ( ply:Team() == TEAM_DEAD ) ) then
						deadPlayers = {}
			
						ply:SetTeam( TEAM_ALIVE )
						ply:Spawn()
						ply:SetPos( pos )
						ply:SetEyeAngles( ang )
					end
					-- Set player positions
					if ( ply:Team() == TEAM_ALIVE and ply~=acti and ply:GetPos():Distance(pos)>1500 ) then
			
						if ( IsValid( ply:GetVehicle() ) ) then
				
							ply:ExitVehicle()
							ply:GetVehicle():Remove()
				
						end
						ply:SetVelocity(ply:GetVelocity()*-1)
						ply:SetPos( pos )
						ply:SetEyeAngles( ang )
			
					end
				end
				PrintTranslatedMessage(HUD_PRINTTALK, "MINICP", acti:Nick())
				--net.Start( "SetCheckpointPosition" )
				--net.WriteVector( pos )
				--net.Broadcast()
			end
		end
	end
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
	ips.gamemodespawnpoint=true

end


-- Creates a trigger delaymapload
function GM:CreateTDML(min, max)
	tdmlPos = max - ((max - min) / 2)

	local tdml = ents.Create("trigger_delaymapload")
	tdml:SetPos(tdmlPos)
	tdml.min = min
	tdml.max = max
	tdml:Spawn()
	return tdml
end


-- Called when the player dies
function GM:DoPlayerDeath(ply, attacker, dmgInfo)

	ply.deathPos = ply:EyePos()

	-- Add to deadPlayers table to prevent respawning on re-connect
	if (((!hl2c_server_player_respawning:GetBool() && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING) && !table.HasValue(deadPlayers, ply:SteamID())) then
		table.insert(deadPlayers, ply:SteamID())
	end
	
	ply:RemoveVehicle()
	if (ply:FlashlightIsOn()) then ply:Flashlight(false); end
	ply:CreateRagdoll()
	ply:SetTeam(TEAM_DEAD)
	ply:AddDeaths(1)

	-- Clear player info
	ply.info = nil


	if attacker:IsNPC() then
		ply:SendLua(string.format([[GAMEMODE:DiedBy('%s')]],attacker:GetClass()))
	end
	
	local lowermodelname = string.lower(ply:GetModel())

	-- Cache the voice set.

	ply:EmitSound("vo/npc/"..(string.find(lowermodelname, "female", 1, true) and "female01" or "male01").."/no0"..math.random(2)..".wav")

end


-- Called when the player is waiting to spawn
function GM:PlayerDeathThink(ply)

	if (ply.NextSpawnTime && (ply.NextSpawnTime > CurTime())) then return; end

	if ((ply:GetObserverMode() != OBS_MODE_ROAMING) && (ply:IsBot() || ply:KeyPressed(IN_ATTACK) || ply:KeyPressed(IN_ATTACK2) || ply:KeyPressed(IN_JUMP))) then
	
		if ((!hl2c_server_player_respawning:GetBool() && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING) then
		
			ply:EquipSuit()
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetPos(ply.deathPos)
			ply:SetNoTarget(true)
			ply:SetNoDraw(true)
		
		else
		
			ply:SetTeam(TEAM_ALIVE)
			ply:Spawn()
		
		end
	
	end

end


-- Called when entities are created
function GM:OnEntityCreated(ent)

	-- NPC Lag Compensation
	if (hl2c_server_lag_compensation:GetBool() && ent:IsNPC() && !table.HasValue(NPC_EXCLUDE_LAG_COMPENSATION, ent:GetClass())) then
	
		ent:SetLagCompensated(true)
	
	end

	-- Vehicle Passenger Seating
	if (hl2c_server_jeep_passenger_seat:GetBool() && !GetConVar("hl2_episodic"):GetBool() && ent:IsVehicle() && string.find(ent:GetClass(), "prop_vehicle_jeep")) then
	
		ent.passengerSeat = ents.Create("prop_vehicle_prisoner_pod")
		ent.passengerSeat:SetPos(ent:LocalToWorld(Vector(21, -32, 18)))
		ent.passengerSeat:SetAngles(ent:LocalToWorldAngles(Angle(0, -3.5, 0)))
		ent.passengerSeat:SetModel("models/nova/jeep_seat.mdl")
		ent.passengerSeat:SetMoveType(MOVETYPE_NONE)
		ent.passengerSeat:SetParent(ent)
		ent.passengerSeat:Spawn()
		ent.passengerSeat:Activate()
		ent.passengerSeat:SetKeyValue("limitview","0")
		ent.passengerSeat.allowWeapons = true
	
	end

	if ent:IsNPC() and not ent:IsFriendlyNPC() and not table.HasValue(GODLIKE_NPCS, ent:GetClass()) then
		ent.ent_MaxHealthMul = (ent.ent_MaxHealthMul or 1) * math.min(self:GetDifficulty()^0.3, 100000)
		ent.ent_HealthMul = (ent.ent_HealthMul or 1) * math.min(self:GetDifficulty()^0.3, 100000)
	end

	timer.Simple(0, function()
		if !ent:IsNPC() then return end
		if ent.ent_MaxHealthMul then
			ent:SetMaxHealth(ent.ent_MaxHealthMul * ent:Health())
		end
		if ent.ent_HealthMul then
			ent:SetHealth(ent.ent_HealthMul * ent:Health())
		end
		if ent.ent_Color then
			ent:SetColor(ent.ent_Color)
		end
	end)
end
local str_len=string.len
local str_lower=string.lower
local string_equal=function(a,b)
	if str_len(a)~=str_len(b) then return false end
	return str_lower(a)==str_lower(b)
end

-- Called when map entities spawn
function GM:EntityKeyValue(ent, key, value)

	if ((ent:GetClass() == "trigger_changelevel")) then

		if (key == "map") then
			ent.map = value
		elseif (string_equal(key,"landmark")) then
			ent.landmark = value
		end
	end

	if ((ent:GetClass() == "npc_combine_s") && (key == "additionalequipment") && (value == "weapon_shotgun")) then
	
		ent:SetSkin(1)
	
	end

end

local NpcsSecondWeapon={
	npc_metropolice=function(ent,oldwep)
		local wep="weapon_stunstick"
		if oldwep:GetClass()=="weapon_smg1" or oldwep:GetClass()=="weapon_shotgun" then
			wep="weapon_pistol"
		end
		if oldwep:GetClass()=="weapon_stunstick" then
			wep="invis stunstick"
		end
		timer.Simple(0.5,function()
			if IsValid(ent) and ent:Health()>0 and wep then
				ent:Give(wep=="invis stunstick" and "weapon_stunstick" or wep)
				if wep=="invis stunstick" and IsValid(ent:GetWeapon("weapon_stunstick")) then
					local wepent=ent:GetWeapon("weapon_stunstick")
					wepent:SetNoDraw(true) wepent:SetNotSolid(true)
					ent:DeleteOnRemove(wepent)
				end
			end
		end)
	end,
	npc_combine_s=function(ent,oldwep)
		local wep="weapon_smg1"
		if oldwep:GetClass()=="weapon_smg1" then
			wep=nil
		end
		timer.Simple(0.5,function()
			if IsValid(ent) and ent:Health()>0 and wep then
				ent:Give(wep)
			end
		end)
	end,
}

local StunstickDamageMul={
	npc_manhack=5,
	npc_cscanner=5
}

-- Called when an entity has received damage
function GM:EntityTakeDamage(ent, dmgInfo)
	-- Gets the attacker
	local attacker = dmgInfo:GetAttacker()
	local damage = dmgInfo:GetDamage()
	local damagemul,damageresistancemul = 1,1

	-- Godlike NPCs take no damage ever
	if (IsValid(ent) && table.HasValue(GODLIKE_NPCS, ent:GetClass())) and not MAP_FORCE_NO_FRIENDLIES then
		return true
	end

	-- NPCs cannot be damaged by friends
	if (IsValid(ent) && ent:IsNPC() && (ent:GetClass() != "npc_turret_ground") && IsValid(attacker) && (ent:Disposition(attacker) == D_LI)) and not MAP_FORCE_NO_FRIENDLIES then
		return true
	end

	-- Gravity gun punt should kill NPC's (This isn't really needed anymore, as gmod has updated to be able to support Super Gravity Gun by itself)
	-- if (IsValid(ent) && ent:IsNPC() && IsValid(attacker) && attacker:IsPlayer()) then
		-- if (GetGlobalBool("SUPER_GRAVITY_GUN") && IsValid(attacker:GetActiveWeapon()) && (dmgInfo:GetInflictor():GetClass() == "weapon_physcannon")) then
			-- dmgInfo:SetDamage(ent:Health())
		-- end
	-- end

	-- Crowbar and Stunstick should follow skill level
	if (IsValid(ent) && IsValid(attacker) && attacker:IsPlayer()) then
		if (IsValid(attacker:GetActiveWeapon()) && ((attacker:GetActiveWeapon():GetClass() == "weapon_crowbar" && dmgInfo:GetDamageType() == DMG_CLUB))) then
			damage = GetConVar("sk_plr_dmg_crowbar"):GetFloat()
		elseif IsValid(attacker:GetActiveWeapon()) && attacker:GetActiveWeapon():GetClass() == "weapon_stunstick" && dmgInfo:GetDamageType() == DMG_CLUB then
			damage = GetConVar("sk_plr_dmg_stunstick"):GetFloat()
			dmgInfo:SetDamageType(DMG_CLUB+DMG_SHOCK)
			damagemul=damagemul*1.6
			if ent:IsNPC() and ((ent:Health()/ent:GetMaxHealth())<=0.75) and not ent:IsFriendlyNPC() then
				local oldwep=ent:GetActiveWeapon()
				ent:DropWeapon(nil,nil,attacker:GetAimVector()*20*dmgInfo:GetDamage())
				if IsValid(oldwep) and NpcsSecondWeapon[ent:GetClass()] then
					NpcsSecondWeapon[ent:GetClass()](ent,oldwep)
				end
			end
			if ent:IsNPC() or IsValid(ent:GetPhysicsObject()) then
				local stunstick=attacker:GetActiveWeapon()
				timer.Simple(0,function()
					if IsValid(stunstick) then
						stunstick:SetNextPrimaryFire(CurTime()+0.45)
					end
				end)
			end
			if StunstickDamageMul[ent:GetClass()] then
				damagemul=damagemul*StunstickDamageMul[ent:GetClass()]
			end
		end
	end

	if attacker.NextDamageMul and (ent:IsNPC() or ent:IsPlayer()) then
		damage = damage * attacker.NextDamageMul
		attacker.NextDamageMul = nil
	end

	local attackerisworld = attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "trigger_waterydeath"
	local ispoisonheadcrab = attacker:GetClass() == "npc_headcrab_poison" or attacker:GetClass() == "npc_headcrab_black"

	if attacker:IsPlayer() then
		if dmgInfo:IsBulletDamage() then
			damagemul = damagemul * (1 + ((self.EndlessMode and 0.03 or 0.01) * attacker:GetSkillAmount("Gunnery")))
		elseif attacker:GetSkillAmount("Gunnery") > 15 then
			damagemul = damagemul * (1 + (0.025 * (attacker:GetSkillAmount("Gunnery")-15)))
		end

		if attacker:HasPerkActive("damageboost_1") then
			damagemul = damagemul * (1 + (self.EndlessMode and 0.47 or 0.06))
		end
		local improvecrit=attacker:HasPerkActive("critical_damage_2")
		if attacker:HasPerkActive("critical_damage_1") and math.random(100) <= (self.EndlessMode and (improvecrit and 19 or 12) or 7) then
			if math.random(1,100)<=6 and improvecrit and self.EndlessMode then
				damagemul = damagemul * 4
			else
				damagemul = damagemul * (self.EndlessMode and (improvecrit and 2.5 or 2.2) or 1.2)
			end
			
		end

		damage = damage * damagemul
	end

	if ent:IsPlayer() and not attackerisworld and not ispoisonheadcrab then
		if dmgInfo:IsBulletDamage() then
			damageresistancemul = damageresistancemul * (1 + ((self.EndlessMode and 0.025 or 0.008) * ent:GetSkillAmount("Defense")))
		elseif ent:GetSkillAmount("Defense") > 15 then
			damageresistancemul = damageresistancemul * (1 + (0.02 * ent:GetSkillAmount("Defense")))
		end

		if ent:HasPerkActive("damageresistanceboost_1") then
			damageresistancemul = damageresistancemul * (1 + (self.EndlessMode and 0.57 or 0.07))
		end

		damage = damage / damageresistancemul
	end


	if ent:IsPlayer() and attacker:IsValid() and attackerisworld then
		damage = damage * math.max(1, ent:GetMaxHealth()*0.01)
	end

	if (ent:IsPlayer() or ent:IsNPC() and ent:IsFriendlyNPC()) and attacker:IsNPC() then
		if not ispoisonheadcrab then
			damage = damage * math.sqrt(self:GetDifficulty()) --could be square rooted
		elseif ent:IsPlayer() and ent:HasPerkActive("antipoison_1") then
			damage = damage - math.min(self.EndlessMode and 100 or 25, ent:Health()/2)
		end
	end
	if ent:IsNPC() and not ent:IsFriendlyNPC() then
		if ent:GetClass() == "npc_combinegunship" then
			damage = damage / math.log10(self:GetDifficulty())
		else
			damage = damage / math.sqrt(self:GetDifficulty())
		end
	end

	dmgInfo:SetDamage(damage)

	if self.EXMode and attacker:GetClass() == "npc_sniper" and attacker.VariantType == 1 then
		--PrintMessage(3, tostring(attacker).." "..(ent:IsPlayer() and ent:Nick() or ent:GetClass()).." "..dmgInfo:GetDamage())
	end
end


-- Clears the player data folder
function GM:ClearPlayerDataFolder()
	local tableFiles, tableFolders = file.Find(self.VaultFolder.."/players/*", "DATA")
	for k, v in ipairs(tableFiles) do
		file.Delete(self.VaultFolder.."/players/"..v)
	end
end


-- Called by GoToNextLevel
function GM:GrabAndSwitch()
	changingLevel = true

	-- Since the file can build up with useless files we should clear it
	hook.Call("ClearPlayerDataFolder", GAMEMODE)

	-- Store player information
	for _, ply in pairs(player.GetAll()) do
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
			for _, wep in pairs(plyWeapons) do
				plyInfo.loadout[ wep:GetClass() ] = {
					wep:Clip1(),
					wep:Clip2(),
					ply:GetAmmoCount(wep:GetPrimaryAmmoType()),
					ply:GetAmmoCount(wep:GetSecondaryAmmoType())
				}
			end
		end
	
		local plyID = ply:SteamID64() || ply:UniqueID()
		file.Write(self.VaultFolder.."/players/"..plyID..".txt", util.TableToJSON(plyInfo))
		self:SavePlayer(ply)
	end
	
	-- PrintMessage(4, "Map change in progress...")
	timer.Simple(1, function() game.ConsoleCommand("changelevel "..NEXT_MAP.."\n") end)
end

function GM:ShutDown()
	for _,ply in pairs(player.GetAll()) do
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
	self.EXMode = GetConVar("hl2ce_server_ex_mode_enabled"):GetBool()
	
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
	if hl2c_server_force_gamerules:GetBool() then
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

	self:LoadServerData()
	
	print(GAMEMODE.Name.." ("..GAMEMODE.Version..") gamemode loaded")
end

function GM:OnMapCompleted()
end

function GM:OnCampaignCompleted()
end

function GM:PlayerCompletedMap(ply)
end

function GM:PlayerCompletedCampaign(ply)
	if !(ply and ply:IsValid()) then return end
	local map = game.GetMap()
	local gamename = ""
	if map == "d3_breen_01" then
		--gamename = "Half-Life 2"
		gamename="hl2"
	elseif map == "ep1_c17_06" then
		--gamename = "Half-Life 2: Episode One"
		gamename="hl2_ep1"
	elseif map == "ep2_outland_12a" then
		--gamename = "Half-Life 2: Episode Two"
		gamename="hl2_ep2"
	end

	local xp = (1 + math.max(0, 2-math.log10(ply:Frags()))*0.2)
	if ply.MapStats.GainedXP then
		xp = xp * ply.MapStats.GainedXP*0.15
	end
	ply:PrintTranslatedMessage(HUD_PRINTTALK, "CompletedCampaign", translate.ClientGet(ply, gamename))
	ply:PrintTranslatedMessage(HUD_PRINTTALK, "AwardedXP", xp)
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
	print("Gamemode "..self.Name.." ("..self.Version..") files have been refreshed")
	timer.Simple(1, function()
		for _,ply in pairs(player.GetAll()) do
			self:NetworkString_UpdateStats(ply)
			self:NetworkString_UpdateSkills(ply)
			self:NetworkString_UpdatePerks(ply)
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
		local TDML=GAMEMODE:CreateTDML(TRIGGER_DELAYMAPLOAD[1], TRIGGER_DELAYMAPLOAD[2])
		local LandMark = INFO_LANDMARK
		for _, tcl in pairs(ents.FindByClass("trigger_changelevel")) do
			if tcl.map == NEXT_MAP then
				LandMark=tcl.landmark
			end
			tcl:Remove()
		end
		TDML.LandMark=LandMark
	else
		for _, tcl in pairs(ents.FindByClass("trigger_changelevel")) do
			if (tcl.map == NEXT_MAP) then
				local tclMin, tclMax = tcl:WorldSpaceAABB()
				local TDML=GAMEMODE:CreateTDML(tclMin, tclMax)
				TDML.LandMark=tcl.landmark
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

local DONOT_TRANSITION={
    ["keyframe_rope"]=true,
    ["info_landmark"]=true,
    ["env_sprite"]=true,
    ["env_lightglow"]=true,
    ["env_soundscape"]=true,
    ["move_rope"]=true,
    ["game_ragdoll_manager"]=true,
    ["env_fog_controller"]=true,
    ["npc_template_maker"]=true,
    ["trigger_transition"]=true,
    ["npc_maker"]=true,
    ["logic_auto"]=true,
    ["_firesmoke"]=true,
    ["env_fire"]=true,
    ["npc_heli_avoidsphere"]=true
}

local TRANSITION_NPCs = {
    ["npc_zombie"]=true,
    ["npc_headcrab"]=true,
    ["npc_fastzombie"]=true
}


local TRAN_PLAYER=function(ply) --TODO --again.
	if not IsValid(INFO_LANDMARK) then return end
	local svtbl=ply:GetSaveTable()
	local lm=INFO_LANDMARK
	local data={}
end

-- Called automatically or by the console command
function GM:NextMap()
	if changingLevel then return end

	changingLevel = true

	net.Start("NextMap")
	net.WriteFloat(CurTime())
	net.Broadcast()
	--TODO
	--[[
	if TRANSITION_ENTITIES and IsValid(INFO_LANDMARK) then
		local tents={}
		for _,v in pairs(TRANSITION_ENTITIES)do
			if IsValid(v) and not v:IsEFlagSet(EFL_KILLME) then
				table.insert(tents,v)
			end
		end
		local entstbl={}
		local transitioned={}
		for _,ent in ipairs(tents)do
			if ent:IsPlayer() and not ent:IsBot() then
				transitioned[ent]=true
				table.insert(entstbl,ent)
				continue
			end

			local caps=ent:ObjectCaps()
			local cl=ent:GetClass()
			local veh=ent:IsVehicle()
			local npc=ent:IsNPC()
			if DONOT_TRANSITION[class] then continue end
			if bit.band(caps,tonumber '0x80000000')~=0 and not veh then
				continue
			end
			if bit.band(caps,tonumber '0x00000002')~=0 then
				transitioned[ent]=true
				table.insert(entstbl,ent)
				continue
			end
			local gn=ent:GetInternalVariable("globalname")
			if gn~="" and not ent:IsDormant() then
				transitioned[ent]=true
				table.insert(entstbl,ent)
				continue
			end
			if npc and TRANSITION_NPCs[cl] then
				transitioned[ent]=true
				table.insert(entstbl,ent)
				continue
			end
			if veh and IsValid(veh:GetDriver()) and veh:GetDriver():IsPlayer() and transitioned[veh:GetDriver()] then
				transitioned[ent]=true
				table.insert(entstbl,ent)
				continue
			end
			local parent,owner=ent:GetParent(),ent:GetOwner()
			if IsValid(parent) and (parent:IsPlayer() or parent:IsNPC() or parent:IsWeapon()) then continue end
			if IsValid(owner) and (owner:IsPlayer() or owner:IsNPC()) then continue end
			if ent:IsWeapon() and IsValid(owner) and owner:IsNPC() then continue end
			if ent:IsPlayerHolding() then
				transitioned[ent]=true
				table.insert(entstbl,ent)
				continue
			end
		end
		print("transitioned:")
		PrintTable(transitioned,2)
		local data={}
		file.Write("hl2ce_transitionnextmap.txt",tostring(NEXT_MAP))
	end
	--]]

	timer.Create("hl2c_next_map", NEXT_MAP_TIME, 1, function()
		self:GrabAndSwitch()
	end)
end
concommand.Add("hl2ce_next_map", function(ply) if (IsValid(ply) && ply:IsAdmin()) then NEXT_MAP_TIME = 0; hook.Call("NextMap", GAMEMODE); else ply:PrintTranslatedMessage(HUD_PRINTTALK, "NotAdmin") end end)
concommand.Add("hl2ce_admin_respawn", function(ply)
	if IsValid(ply) && ply:IsAdmin() && (!ply:Alive() || table.HasValue(deadPlayers, ply:SteamID())) && !changingLevel then
		table.RemoveByValue(deadPlayers, ply:SteamID())
		ply:SetTeam(TEAM_ALIVE)
		timer.Simple(0, function()
			ply:Spawn()
		end)
		print(ply:Nick().." used respawn command!")
	else
		if !ply:IsAdmin() then
			ply:PrintTranslatedMessage(HUD_PRINTTALK, "NotAdmin")
		elseif ply:Alive() || !table.HasValue(deadPlayers, ply:SteamID()) then
			ply:PrintTranslatedMessage(HUD_PRINTTALK, "NotDead")
		elseif changingLevel then
			ply:PrintTranslatedMessage(HUD_PRINTTALK, "CantRespawnWhileChangingMap")
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
		if NPC_POINT_VALUES[npc:GetClass()] then
			killer:AddFrags(NPC_POINT_VALUES[npc:GetClass()])
		else
			killer:AddFrags(1)
		end



		if NPC_XP_VALUES[npc:GetClass()] then
			-- Too many local this is fine.
			local xp,difficulty = NPC_XP_VALUES[npc:GetClass()], self:GetDifficulty()
			local npckillxpmul,npckilldiffgainmul = self.XpGainOnNPCKillMul or 1, self.DifficultyGainOnNPCKillMul or 1
			local npcxpmul = npc.XPGainMult or 1

			local gainfromdifficultymul = math.min(difficulty, killer:GetMaxDifficultyXPGainMul())
			local better_knowledge_gain = killer:HasPerkActive("better_knowledge_1") and (self.EndlessMode and self:GetDifficulty() >= 6.50 and 2.35 or !self.EndlessMode and 1.4) or 1
			local xpmul = gainfromdifficultymul * npckillxpmul * npcxpmul * better_knowledge_gain
			killer:GiveXP(NPC_XP_VALUES[npc:GetClass()] * xpmul)
			self:SetDifficulty(difficulty + xp*0.0005*npckilldiffgainmul)
		end
	end

	-- If the NPC is godlike and they die
	if (IsValid(npc)) then
	
		if npc:IsGodlikeNPC() then
			if killer:IsPlayer() then
				PrintTranslatedMessage(HUD_PRINTTALK, "ImportantNPCKilledByOther",killer:Nick())
			else
				PrintTranslatedMessage(HUD_PRINTTALK, "ImportantNPCDied")
			end

			if (IsValid(killer) && killer:IsPlayer()) then game.KickID(killer:UserID(), translate.ClientGet(killer, "ImportantNPCKilledByYou")); end

			gamemode.Call("RestartMap")
		
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


-- Called when a player tries to pickup a weapon
local gmod_maxammo = GetConVar("gmod_maxammo")
function GM:PlayerCanPickupWeapon(ply, wep)
	local wepclass = wep:GetClass()
	if ((ply:Team() != TEAM_ALIVE) || (table.HasValue(ADMINISTRATOR_WEAPONS, wepclass) && !ply:IsAdmin())) then
		return false
	end

	if ((wep:GetPrimaryAmmoType() <= 0) && ply:HasWeapon(wepclass)) then
		if wepclass=="weapon_stunstick" and not wep.used then
			ply:Give("item_battery")
			wep:Remove()
			wep.used=true
		end
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
	if item:GetClass()=="item_healthkit" then
		ply:Give("weapon_hl2ce_medkit")
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

	ply.XP = 0
	ply.Level = 1
	ply.StatPoints = 0

	ply.Prestige = 0
	ply.PrestigePoints = 0
	ply.Eternity = 0
	ply.EternityPoints = 0

	-- Endless
	ply.Celestiality = 0
	ply.CelestialityPoints = 0
	ply.Rebirths = 0
	ply.RebirthPoints = 0
	ply.Ascensions = 0
	ply.AscensionPoints = 0

	-- True Endless
	-- ...but... you sure?

	for k, v in pairs(self.SkillsInfo) do
		ply["Stat"..k] = 0
	end

	ply.UnlockedPerks = {}
	ply.DisabledPerks = {}


	ply.MapStats = {}
	ply.SessionStats = {}

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


	-- Objective Timer
	net.Start("ObjectiveTimer")
	net.WriteFloat(self.ObjectiveTimer or 0)
	net.Broadcast()
	

	-- Send initial player spawn to client
	net.Start("PlayerInitialSpawn")
	net.WriteBool(hl2c_server_custom_playermodels:GetBool())
	net.Send(ply)

	-- Send current checkpoint position
	if (#checkpointPositions > 0) then
		net.Start("SetCheckpointPosition")
		net.WriteVector(checkpointPositions[1])
		net.Send(ply)
	end

	-- Prompt players that they can spawn vehicles
	if ALLOWED_VEHICLE then
		ply:PrintTranslatedMessage(3,"AllowedVehSpawn")
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
	GAMEMODE:NetworkString_UpdateStats(ply)
	GAMEMODE:NetworkString_UpdateSkills(ply)
	GAMEMODE:NetworkString_UpdatePerks(ply)
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
	
		for _, wep in pairs(ply:GetWeapons()) do
		
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
	if (hl2c_admin_physgun:GetBool() && ply:IsAdmin()) then
	
		ply:Give("weapon_physgun")
	
	end

	timer.Simple(0,function()
		if IsValid(ply) and ply:HasWeapon("weapon_crowbar") and game.GetMap()~="d1_canals_01" then
			ply:Give("weapon_stunstick")
		end
	end)
	timer.Simple(0,function()
		if IsValid(ply) and ply:HasWeapon("weapon_physcannon") then
			ply:Give("weapon_hl2ce_medkit")
		end
	end)

	hook.Call("PostPlayerLoadout", GAMEMODE, ply)

end


-- Called when the player attempts to noclip
function GM:PlayerNoClip(ply)
	if !ply:Alive() then
		-- ply:PrintMessage(HUD_PRINTTALK, "You can't noclip when you are dead, can't you see?!")
		return false
	end

	return ply:IsAdmin() && hl2c_admin_noclip:GetBool()
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
	if (!hl2c_server_custom_playermodels:GetBool() && ply.info && ply.info.model) then
	
		ply.modelName = ply.info.model
	
	else
	
		local modelName = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))
	
		if (hl2c_server_custom_playermodels:GetBool() || (modelName && table.HasValue(PLAYER_MODELS, string.lower(modelName)))) then
		
			ply.modelName = modelName
		
		else
		
			ply.modelName = table.Random(PLAYER_MODELS)
		
		end
	
	end

	if (!hl2c_server_custom_playermodels:GetBool()) then
	
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
	if (hl2c_server_custom_playermodels:GetBool()) then
	
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
	player_manager.SetPlayerClass(ply, "player_hl2ce")

	if (((!hl2c_server_player_respawning:GetBool() && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING) && (ply:Team() == TEAM_DEAD)) then
	
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
	ply:ShouldDropWeapon((!hl2c_server_player_respawning:GetBool() && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING)
	ply:AllowFlashlight(GetConVar("mp_flashlight"):GetBool())
	ply:SetCrouchedWalkSpeed(0.3)
	gamemode.Call("SetPlayerSpeed", ply, 190, 320)
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)

	-- Set stuff from last level
	local maxhp = 100 + ((self.EndlessMode and 5 or 1) * ply:GetSkillAmount("Vitality")) -- calculate their max health
	if ply:HasPerkActive("healthboost_1") then
		maxhp = maxhp + (self.EndlessMode and 85 or 15)
	end

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
	else
		ply:SetHealth(maxhp)
	end
	ply:SetMaxHealth(maxhp)

	-- Players should avoid players
	ply:SetCustomCollisionCheck(!game.SinglePlayer())
	ply:SetAvoidPlayers(false)
	ply:SetNoTarget(false)

	-- If the player died before, kill them again
	if table.HasValue(deadPlayers, ply:SteamID()) then
		--ply:PrintMessage(HUD_PRINTTALK, "You cannot respawn now.")
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


function GM:EntityFireBullets(ent,data)
	if IsValid(ent.BulletIgnore) then
		data.IgnoreEntity=ent.BulletIgnore
		return true
	end
end

-- Called to control whether a player can enter the vehicle or not
function GM:CanPlayerEnterVehicle(ply, vehicle, role)

	-- Used for passenger seating
	ply:SetAllowWeaponsInVehicle(vehicle.allowWeapons)
	ply.BulletIgnore=vehicle

	return true

end

function GM:CanExitVehicle(veh,ply)
	ply.BulletIgnore=nil
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
			for k,v in pairs(player.GetAll()) do
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
				game.CleanUpMap(true, {"env_fire", "entityflame", "_firesmoke"})
				changingLevel = nil
				FORCE_PLAYER_RESPAWNING = true
				for k,v in pairs(player.GetAll()) do
					self:PlayerInitialSpawn(v)
					v:KillSilent()
					v:SetTeam(TEAM_ALIVE)
					timer.Simple(0.05, function()
						v:Spawn()
					end)
				end
				changingLevel = false
				FORCE_PLAYER_RESPAWNING=false
			end
		end)
	end)
end
concommand.Add("hl2ce_restart_map", function(ply) if (IsValid(ply) && ply:IsAdmin()) then hook.Call("RestartMap", GAMEMODE, 0); end end)

function GM:FailMap(ply,reason,xploss) -- ply argument is the one who caused the map to fail, giving them most penalty
	self:RestartMap()

	if ply and isentity(ply) and ply:IsValid() and ply:IsPlayer() then
		local xploss = xploss or ply.MapStats.XPGained + 100
		ply.XP = ply.XP - xploss
		reason = reason or "Don't cause the map to fail bruh."
		if translate.GetTranslations[reason] then
			ply:PrintTranslatedMessage(3, reason)
		else
			ply:PrintMessage(3, reason)
		end
		if xploss>0 then
			ply:PrintTranslatedMessage(3,"LostXP",xploss)
		end
	elseif ply=="ALL" then
		for _,ply in ipairs(player.GetAll())do
			local xploss = xploss or ply.MapStats.XPGained + 100
			ply.XP = ply.XP - xploss
			reason = reason or "Don't cause the map to fail bruh."
			if translate.GetTranslations[reason] then
				ply:PrintTranslatedMessage(3, reason)
			else
				ply:PrintMessage(3, reason)
			end
			if xploss>0 then
				ply:PrintTranslatedMessage(3,"LostXP",xploss)
			end
		end
	end
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
		ply:PrintTranslatedMessage(HUD_PRINTTALK, "SpawnVehNotAllowed")
		return
	end

	for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 256)) do
		if IsValid(ent) and ent:IsPlayer() and ent:Alive() and ent != ply then
			ply:PrintTranslatedMessage(HUD_PRINTTALK, "SpawnVehPlayerNear")
			return
		end
	end

	-- Spawn the vehicle
	if ALLOWED_VEHICLE then
		
		if IsValid(ply.vehicle) and (CurTime()-ply.vehicle:GetCreationTime())<3 then
			ply:PrintTranslatedMessage(HUD_PRINTTALK, "NoSpam", translate.ClientGet(ply, "SpawnVehicle"))
			return
		end

		local vehicleList = list.Get("Vehicles")
		local vehicle = vehicleList[ ALLOWED_VEHICLE ]
	
		if !vehicle then
			return
		end
	
		local plyAngle = ply:EyeAngles()
		local spawnpos = ply:GetPos() + Vector(0, 0, 48) + plyAngle:Forward() * 160

		if not util.IsInWorld(spawnpos) then
			--ply:ChatPrint("Insufficient space for spawning in a vehicle!")
			ply:PrintTranslatedMessage(HUD_PRINTTALK, "NoSpaceForSpawnVeh")
			return
		end

		ply:RemoveVehicle()

		-- Create the new entity
		ply.vehicle = ents.Create(vehicle.Class)
		ply.vehicle:SetModel(vehicle.Model)
	
		-- Set keyvalues
		local nogun=ply:KeyDown(IN_WALK)
		for a, b in pairs(vehicle.KeyValues) do
			if a:lower():match("gun") and nogun then continue end
			ply.vehicle:SetKeyValue(a, b)
		end
		
		-- Enable gun on jeep
		if ALLOWED_VEHICLE == "Jeep" and not JEEP_NO_GUN and not nogun then
			ply.vehicle:Fire("EnableGun", "1")
		end
	
		-- Set pos/angle and spawn
		ply.vehicle:SetPos(spawnpos)
		ply.vehicle:SetAngles(Angle(0, plyAngle.y - 90, 0))
		ply.vehicle:Spawn()
		ply.vehicle:Activate()
		local params = ply.vehicle:GetVehicleParams()
		params.engine.horsepower = params.engine.horsepower + (self.EndlessMode and 8 or 4)*ply:GetSkillAmount("BetterEngine")
		if self.EndlessMode then
			params.engine.boostDelay = params.engine.boostDelay*(1-ply:GetSkillAmount("BetterEngine")*0.04)
			params.engine.maxSpeed=(params.engine.maxSpeed)*(1+ply:GetSkillAmount("BetterEngine")*0.05)
			if ply:GetSkillAmount("BetterEngine")>=3 then
				params.steering.degreesSlow=params.steering.degreesSlow*1.25
				params.steering.degreesFast=params.steering.degreesFast*1.25
			end
		end
		ply.vehicle:SetVehicleParams(params)
		if ALLOWED_VEHICLE == "Jeep" and not nogun then ply.vehicle:SetBodygroup(1, 1) end
		ply.vehicle.allowWeapons=nogun
		ply.vehicle.creator = ply
	end
end


-- Called when player wants to remove their vehicle
function GM:ShowSpare2(ply)
	if (ply:Team() != TEAM_ALIVE) || ply:InVehicle() then
		return
	end

	if !ALLOWED_VEHICLE then
		ply:PrintTranslatedMessage(HUD_PRINTTALK, "RemoveVehNotAllowed")
		return
	end

	ply:RemoveVehicle()
end

local checkAFK=0
local AFKInfo={}
local AFKCounter={}

hook.Add("StartCommand","HL2 CE ANTI AFK",function(ply,cmd)
	if AFKInfo[ply] then
		AFKInfo[ply].buttons=cmd:GetButtons()
		AFKInfo[ply].mx=cmd:GetButtons()
		AFKInfo[ply].my=cmd:GetButtons()
	end
end)

-- Called every frame 
function GM:Think()
	if not nextAreaOpenTime then nextAreaOpenTime=0 end
	-- Restart the map if all players are dead
	if (((!hl2c_server_player_respawning:GetBool() && !FORCE_PLAYER_RESPAWNING) || OVERRIDE_PLAYER_RESPAWNING) && (player.GetCount() > 0) && ((team.NumPlayers(TEAM_ALIVE) + team.NumPlayers(TEAM_COMPLETED_MAP)) <= 0)) then
		if !changingLevel then
			PrintTranslatedMessage(HUD_PRINTTALK, "AllPlayersDied")

			local diff = self:GetDifficulty(true)
			self:SetDifficulty(math.max(1, diff * (diff >= 10 and 0.9 or diff >= 4 and 0.91 or 0.93)))

			hook.Call("RestartMap", GAMEMODE)
		end
	end

	-- Change the difficulty according to number of players
	if player.GetCount() > 0 then
		if self.EndlessMode then
			game.SetSkillLevel(math.Clamp(math.floor(self:GetDifficulty()), 1, 3))
		elseif hl2c_server_dynamic_skill_level:GetBool() then
			self:SetDifficulty(math.Clamp((0.55 + (player.GetCount() / 4.7)), DIFFICULTY_RANGE[1], DIFFICULTY_RANGE[2]))
			game.SetSkillLevel(math.Clamp(math.floor(self:GetDifficulty()), 1, 3))
		end
	end
	
	-- Open area portals
	if nextAreaOpenTime <= CurTime() then
		for _, fap in pairs(ents.FindByClass("func_areaportal")) do
			fap:Fire("Open")
		end
		nextAreaOpenTime = CurTime() + 2
	end
	if checkAFK<CurTime() then
		for i,v in ipairs(player.GetAll())do
			if not v:Alive() then continue end
			local last=AFKInfo[v]
			AFKInfo[v]={pos=v:GetPos(),ang=v:EyeAngles()}
			if last then
				local movedmouse=(AFKInfo[v].mx or 0)~=0 and (AFKInfo[v].my or 0)~=0
				local macromovemouse=(last.mx==AFKInfo[v].mx) or (last.my==AFKInfo[v].my)
				if last.mx==nil or last.my==nil then
					macromovemouse=false
				end
				local samekey=AFKInfo[v].buttons==last.buttons
				if last.buttons==nil then
					samekey=false
				end
				local counter=1
				if samekey then counter=counter+1 end
				if not movedmouse then counter=counter+1 end
				if macromovemouse then counter=counter+2 end
				if (AFKInfo[v].pos:Distance(last.pos)<=25) or (AFKInfo[v].ang==last.ang) then
					AFKCounter[v]=(AFKCounter[v] or 0)+counter
				else
					AFKCounter[v]=0
				end
			end
			if (AFKCounter[v] or 0)>=60 and not IsValid(POINT_VIEWCONTROL) then
				v:Kill()
				AFKCounter[v]=0
				v:PrintTranslatedMessage(3,"AFK")
			end
		end
		checkAFK=CurTime()+10
	end
end


-- Player just picked up or was given a weapon
function GM:WeaponEquip(wep)

	if (IsValid(wep) && !table.HasValue(startingWeapons, wep:GetClass())) then
	
		table.insert(startingWeapons, wep:GetClass())
	
	end

end


-- Tell the game to update the player's playermodel
local function UpdatePlayerModel(len, ply)
	if IsValid(ply) && ply:Team() == TEAM_ALIVE then
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
		game.SetSkillLevel(math.Clamp(math.floor(GAMEMODE:GetDifficulty()), 1, 3))
	elseif (!hl2c_server_dynamic_skill_level:GetBool()) then
		GAMEMODE:SetDifficulty(DIFFICULTY_RANGE[1])
		game.SetSkillLevel(math.Clamp(math.floor(GAMEMODE:GetDifficulty()), 1, 3))
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
	local class = ent:GetClass()
	local blacklist = {
		"prop_combine_ball",
		"path_track",
		"func_areaportal",
		"func_tracktrain"
	}
	if string.lower(input) == "sethealth" and value == "0" and ent:IsPlayer() then
		ent:SetHealth(0)
		ent:TakeDamage(0)
	end
	-- if table.HasValue(blacklist, class) then return end

	-- local col = string.sub(class, 1, 6) == "logic_" and Color(255,255,128) or class == "func_tracktrain" and Color(128,128,255) or string.sub(class, 1, 4) == "env_" and Color(128,255,128) or Color(255,128,128)
	-- MsgC(col, ent, "    ", input, "    ", activator, "    ", caller, "    ", value, "    ", ent:GetName(), "\n")
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

function GM:CanProperty(ply,property)
	if !ply:IsSuperAdmin() then return false end
	return true
end
