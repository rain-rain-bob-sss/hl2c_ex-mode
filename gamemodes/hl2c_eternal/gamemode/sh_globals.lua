-- Used to reset all the global states to dead state
-- Also used to set globals

GM.VaultFolder = "hl2c_eternal"


-- Max Leveling values

MAX_LEVEL = 100
MAX_PRESTIGE = 20
MAX_ETERNITIES = 15

--[[Hl2c Endless Mode:
Significantly increases skills power.
In Non-Endless Mode, perks have limited functionality, Eternity perks and further do not work.
Difficulty is gained by killing NPC's. Gaining +0.05% difficulty for each XP gained from NPC.
Difficulty can be far harder than you'd expect. Limit: 1e100x difficulty.
XP gain is also reduced to 65%. (in progress)

Turns Hl2c into extremely unbalanced and one of the most unfair gamemodes of all time, what did you expect?

--- # If you disallow grinding on your server with Endless Mode on, then fuck you. # ---
--- # Recommended to increase ammo limit because Endless Mode is a hell. # ---
]]
GM.EndlessMode = true


--[[No Progression Advantage:
- All skills and perks effects are disabled.

Only if you want to play the game normally or with no progression advantages
]]
GM.NoProgressionAdvantage = false

-- Difficulty Level
-- Difficulty that increases specific stats after certain amount of difficulty
--[[
	-- Easy: <110%
	-- Normal: 110%-200%
	-- Intermediate: 200-370%
	-- Hard: 370-650%
	-- Very Hard: 650%-1000%
	-- Veteran: 1000%-1900%
	-- Expert: 1900%-3800%
	-- Insane: 3800%-1e4%
	-- Master: 1e4%-3.5e4%
	-- Infernal: 3.5e4%-1.5e5%
	-- Hellish: 1.5e5%-1e6%
]]

GM.ConfigList = {
	["auto_prestige_enabled"] = "number",
}

HL2CE_CELESTIALITY = false

-- DT FLOAT
DT_FLOAT_ENT_HEALTH = 1
DT_FLOAT_ENT_MAXHEALTH = 2


TEAM_ALIVE = 1
TEAM_COMPLETED_MAP = 2
TEAM_DEAD = 3

if SERVER then
-- Function to make all known global states dead
	function GM:KillAllGlobalStates()

	-- Gordon is a precriminal
		if game.GetGlobalState("gordon_precriminal") != GLOBAL_DEAD then
			game.SetGlobalState("gordon_precriminal", GLOBAL_DEAD)
		end

	-- Antlions are allied
		if game.GetGlobalState("antlion_allied") != GLOBAL_DEAD then
			game.SetGlobalState("antlion_allied", GLOBAL_DEAD)
		end

	-- No sprinting
		if ( game.GetGlobalState( "suit_no_sprint" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "suit_no_sprint", GLOBAL_DEAD )
		end

	-- Super Gravity Gun
		if ( game.GetGlobalState( "super_phys_gun" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "super_phys_gun", GLOBAL_DEAD )
		end

	-- Friendly encounter
		if ( game.GetGlobalState( "friendly_encounter" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "friendly_encounter", GLOBAL_DEAD )
		end

	-- Gordon is invulnerable
		if ( game.GetGlobalState( "gordon_invulnerable" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "gordon_invulnerable", GLOBAL_DEAD )
		end

	-- Prevent seagulls spawning on the jeep
		if ( game.GetGlobalState( "no_seagulls_on_jeep" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "no_seagulls_on_jeep", GLOBAL_DEAD )
		end

	-- Alyx is injured (EP2)
		if ( game.GetGlobalState( "ep2_alyx_injured" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "ep2_alyx_injured", GLOBAL_DEAD )
		end

	-- Alyx is blind in the darkness
		if ( game.GetGlobalState( "ep_alyx_darknessmode" ) != GLOBAL_DEAD ) then
			game.SetGlobalState( "ep_alyx_darknessmode", GLOBAL_DEAD )
		end

	-- Hunters run over before they dodge
		if game.GetGlobalState("hunters_to_run_over") != GLOBAL_DEAD then
			game.SetGlobalState("hunters_to_run_over", GLOBAL_DEAD)
		end

	-- Unused passive citizens
		if game.GetGlobalState("citizens_passive") != GLOBAL_DEAD then
			game.SetGlobalState("citizens_passive", GLOBAL_DEAD)
		end

	end
end

DMG_TYPE_BLEED = 1
DMG_TYPE_DELAY = 2
DMG_TYPE_PHYSCANNON = 69
