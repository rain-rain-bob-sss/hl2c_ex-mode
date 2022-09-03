NEXT_MAP = "d1_canals_06"


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "relay_rockfall_start" )[ 1 ]:Remove()
		ents.FindByName( "relay_rockfall_docollapse" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "relay_airboat_gateopen" ) && ( string.lower( input ) == "trigger" ) ) then
	
		ALLOWED_VEHICLE = "Airboat"
		PrintMessage( HUD_PRINTTALK, "You're now allowed to spawn the Airboat (F3)." )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "scriptcond_pincher_cops" ) && ( string.lower( input ) == "enable" ) ) then
	
		ents.FindByName( "relay_pincher_startcops" )[ 1 ]:Fire( "Trigger" )
		ents.FindByName( "relay_pincher_startmanhacks" )[ 1 ]:Fire( "Trigger" )
		ents.FindByName( "trigger_pincher_failsafe_left" )[ 1 ]:Fire( "Kill" )
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "door_boatdock_entrance" ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
