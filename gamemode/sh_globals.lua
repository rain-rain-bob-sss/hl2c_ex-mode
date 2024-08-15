-- Used to reset all the global states to dead state
-- Also used to set globals

GM.VaultFolder = "hl2c_eternal"


-- Max Leveling values

MAX_LEVEL = 1000000

--[[Hl2c Endless Mode:
Significantly increases skills pwoer.
In Non-Endless Mode, perks have limited functionality, Eternity perks and further do not work.
Difficulty is gained by killing NPC's. Gaining +0.25% difficulty for each XP gained from NPC.
Difficulty can be far harder than you'd expect. Limit: 1e100x difficulty.
XP gain is also reduced to 40%.

Turns Hl2c into extremely unbalanced and one of the most unfair gamemodes of all time, what did you expect?
]]
GM.EndlessMode = true

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
