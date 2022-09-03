-- Include the required lua files
include( "sh_config.lua" )
include( "sh_player.lua" )

-- Create console variables to make these config vars easier to access
local hl2cex_admin_physgun = CreateConVar( "hl2cex_admin_physgun", ADMIN_NOCLIP, FCVAR_NOTIFY )
local hl2cex_admin_noclip = CreateConVar( "hl2cex_admin_noclip", ADMIN_PHYSGUN, FCVAR_NOTIFY )
local hl2cex_server_force_gamerules = CreateConVar( "hl2cex_server_force_gamerules", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_custom_playermodels = CreateConVar( "hl2cex_server_custom_playermodels", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_checkpoint_respawn = CreateConVar( "hl2cex_server_checkpoint_respawn", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_dynamic_skill_level = CreateConVar( "hl2cex_server_dynamic_skill_level", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_lag_compensation = CreateConVar( "hl2cex_server_lag_compensation", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_player_respawning = CreateConVar( "hl2cex_server_player_respawning", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_jeep_passenger_seat = CreateConVar( "hl2cex_server_jeep_passenger_seat", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )
local hl2cex_server_ex_mode_enabled = CreateConVar( "hl2cex_server_ex_mode_enabled", 0, { FCVAR_NOTIFY, FCVAR_ARCHIVE } )

-- General gamemode information
GM.Name = "Half-Life 2 Campaign: EX Mode"
GM.OriginalAuthor = "AMT (ported and improved by D4 the Perth Fox)"
GM.Author = "Uklejamini"
GM.Version = "0.6.1 (EARLY ACCESS)"


-- Constants
FRIENDLY_NPCS = {
	"npc_citizen"
}

GODLIKE_NPCS = {
--	"npc_alyx",
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
GAMEMODE.EXMode = GetConVar("hl2cex_server_ex_mode_enabled"):GetBool()
end)
-- Create the teams that we are going to use throughout the game
function GM:CreateTeams()

	TEAM_ALIVE = 1
	team.SetUp( TEAM_ALIVE, "ALIVE", Color( 192, 192, 192, 255 ) )
	
	TEAM_COMPLETED_MAP = 2
	team.SetUp( TEAM_COMPLETED_MAP, "COMPLETED MAP", Color( 255, 215, 0, 255 ) )
	
	TEAM_DEAD = 3
	team.SetUp( TEAM_DEAD, "DEAD", Color( 128, 128, 128, 255 ) )

end


-- Called when a gravity gun is attempting to punt something
function GM:GravGunPunt( ply, ent ) 

	if ( IsValid( ent ) && ent:IsVehicle() && ( ent != ply.vehicle ) && IsValid( ent.creator ) ) then
	
		return false
	
	end

	return true

end 


-- Called when a physgun tries to pick something up
function GM:PhysgunPickup( ply, ent )

	if ( string.find( ent:GetClass(), "trigger_" ) || ( ent:GetClass() == "player" ) ) then
	
		return false
	
	end

	return true

end


-- Player input changes
function GM:StartCommand( ply, ucmd )

	if ( ucmd:KeyDown( IN_SPEED ) && IsValid( ply ) && !ply:IsSuitEquipped() ) then
	
		ucmd:RemoveKey( IN_SPEED )
	
	end

	if ( ucmd:KeyDown( IN_WALK ) && IsValid( ply ) && !ply:IsSuitEquipped() ) then
	
		ucmd:RemoveKey( IN_WALK )
	
	end

end


-- Players should never collide with each other or NPC's
function GM:ShouldCollide( entA, entB )

	-- Player and NPCs
	if ( IsValid( entA ) && IsValid( entB ) && ( ( entA:IsPlayer() && ( entB:IsPlayer() || table.HasValue( GODLIKE_NPCS, entB:GetClass() ) || table.HasValue( FRIENDLY_NPCS, entB:GetClass() ) ) ) || ( entB:IsPlayer() && ( entA:IsPlayer() || table.HasValue( GODLIKE_NPCS, entA:GetClass() ) || table.HasValue( FRIENDLY_NPCS, entA:GetClass() ) ) ) ) ) then
	
		return false
	
	end

	-- Passenger seating
	if ( IsValid( entA ) && IsValid( entB ) && ( ( entA:IsPlayer() && entA:InVehicle() && entA:GetAllowWeaponsInVehicle() && entB:IsVehicle() ) || ( entB:IsPlayer() && entB:InVehicle() && entB:GetAllowWeaponsInVehicle() && entA:IsVehicle() ) ) ) then
	
		return false
	
	end

	return true

end


-- Called when a player is being attacked
function GM:PlayerShouldTakeDamage( ply, attacker )

	if ( ( ply:Team() != TEAM_ALIVE ) || !ply.vulnerable || ( attacker:IsPlayer() && ( attacker != ply ) ) || ( attacker:IsVehicle() && IsValid( attacker:GetDriver() ) && attacker:GetDriver():IsPlayer() ) || table.HasValue( GODLIKE_NPCS, attacker:GetClass() ) || table.HasValue( FRIENDLY_NPCS, attacker:GetClass() ) ) then
	
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
function GM:PlayerPostThink( ply )

	-- Manage server data on the player
	if ( SERVER ) then
	
		if ( IsValid( ply ) && ply:Alive() && ( ply:Team() == TEAM_ALIVE ) ) then
		
			-- Give them weapons they don't have
			for _, ply2 in ipairs( player.GetAll() ) do
			
				if ( ( ply != ply2 ) && ply2:Alive() && !ply:InVehicle() && !ply2:InVehicle() && IsValid( ply2:GetActiveWeapon() ) && !ply:HasWeapon( ply2:GetActiveWeapon():GetClass() ) && !table.HasValue( ply.givenWeapons, ply2:GetActiveWeapon():GetClass() ) && ( ply2:GetActiveWeapon():GetClass() != "weapon_physgun" ) ) then
				
					ply:Give( ply2:GetActiveWeapon():GetClass() )
					table.insert( ply.givenWeapons, ply2:GetActiveWeapon():GetClass() )
				
				end
			
			end
		
		end
	
	end

end
