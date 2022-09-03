NEXT_MAP = "d1_canals_01a"

CANALS_TRAIN_PREVENT_STARTFOWARD = false


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "start_item_template" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then ents.FindByName( "boxcar_door_close" )[ 1 ]:Remove(); end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "barrelpush_cop1_sched" ) && ( string.lower( input ) == "startschedule" ) ) then
	
		CANALS_TRAIN_PREVENT_STARTFOWARD = true
	
	end

	if ( !game.SinglePlayer() && CANALS_TRAIN_PREVENT_STARTFOWARD && ( ent:GetName() == "looping_traincar1" ) && ( string.lower( input ) == "startforward" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "looping_traincar2" ) && ( string.lower( input ) == "startforward" ) ) then
	
		return true
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
