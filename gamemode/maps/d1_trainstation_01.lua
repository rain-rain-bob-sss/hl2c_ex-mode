NEXT_MAP = "d1_trainstation_02"

RESET_PL_INFO = true
RESTART_MAP_TIME = 25

TRIGGER_CHECKPOINT = {
	{Vector( -9386, -2488, 24 ), Vector( -9264, -2367, 92 ), true},
	{Vector( -5396, -1984, 16 ), Vector( -5310, -1932, 113 )},
	{Vector( -3609, -338, -24 ), Vector( -3268, -141, 54 )}
}

TRAINSTATION_LEAVEBARNEYDOOROPEN = false
function Hl2cEXSpecialAnomaly()
	local i = 0
	for k,v in pairs(ents.FindByClass("npc_*")) do
		i = i + 0.45
		timer.Simple(i, function()
			if !v:IsValid() then return end
			v:EmitSound("npc/metropolice/vo/is10-108.wav")
			v:TakeDamage(1)
		end)
	end
end
function Hl2cEXSpecialAnomalyForPlayer()
	timer.Simple(5, function()
		local i = 0
		for k,v in pairs(player.GetAll()) do
			i = i + 0.7
			timer.Simple(i, function()
				if !v:IsValid() then return end
				v:EmitSound("npc/metropolice/vo/is10-108.wav")
				v:TakeDamage(1)
				v:PrintMessage(HUD_PRINTCENTER, "Is 10-108!")
			end)
		end
	end)
end
timer.Simple(1, function()
	if GAMEMODE.EXMode then
		timer.Create("is10-108", 35, 0, Hl2cEXSpecialAnomaly)
		net.Start("ObjectiveTimer")
		net.WriteFloat(600)
		net.Broadcast()

		timer.Simple(600 - CurTime(), function()
		GAMEMODE:RestartMap()
			for k,ply in pairs(player.GetAll()) do
				ply:PrintMessage(HUD_PRINTTALK, "OBJECTIVE FAILED!!")
			end
		timer.Create("a", 0, 150, Hl2cEXSpecialAnomaly)
		timer.Create("a", 0.08, 500, Hl2cEXSpecialAnomalyForPlayer)
		game.SetGlobalState( "gordon_invulnerable", GLOBAL_OFF )
		game.SetGlobalState( "gordon_precriminal", GLOBAL_OFF )
		end)
	end
end)

-- Player initial spawn
function hl2cPlayerInitialSpawn( ply )

	ply:SendLua( "table.RemoveByValue( GODLIKE_NPCS, \"npc_barney\" )" )
	ply:SendLua( "table.RemoveByValue( FRIENDLY_NPCS, \"npc_citizen\" )" )
	if GAMEMODE.EXMode then
		ply:PrintMessage(HUD_PRINTTALK, "Objective: Complete the map within 10 minutes. Good luck!")
		net.Start("ObjectiveTimer")
		net.WriteFloat(600)
		net.Send(ply)
		ply:SendLua("RESTART_MAP_TIME = "..RESTART_MAP_TIME)
	end
end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:RemoveSuit()
	timer.Simple( 0.01, function() if ( IsValid( ply ) ) then GAMEMODE:SetPlayerSpeed( ply, 150, 150 ); end; end )

	if ( !game.SinglePlayer() && IsValid( PLAYER_VIEWCONTROL ) && ( PLAYER_VIEWCONTROL:GetClass() == "point_viewcontrol" ) ) then
	
		ply:SetViewEntity( PLAYER_VIEWCONTROL )
		ply:Freeze( true )
	
	end

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	

	game.SetGlobalState( "gordon_precriminal", GLOBAL_ON )
	game.SetGlobalState( "gordon_invulnerable", GLOBAL_ON )

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "razor_gate_retreat_block_2" )[ 1 ]:Remove()
		ents.FindByName( "cage_playerclip" )[ 1 ]:Remove()
		ents.FindByName( "barney_room_blocker_2" )[ 1 ]:Remove()
	
	end

	table.RemoveByValue( GODLIKE_NPCS, "npc_barney" )
	table.RemoveByValue( FRIENDLY_NPCS, "npc_citizen" )

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetClass() == "point_viewcontrol" ) ) then
	
		if ( string.lower( input ) == "enable" ) then
		
			PLAYER_VIEWCONTROL = ent
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ent )
				ply:Freeze( true )
			
			end
		
			if ( !ent.doubleEnabled ) then
			
				ent.doubleEnabled = true
				ent:Fire( "Enable" )
			
			end
		
		elseif ( string.lower( input ) == "disable" ) then
		
			PLAYER_VIEWCONTROL = nil
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ply )
				ply:Freeze( false )
			
			end
		
			return true
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetClass() == "env_zoom" ) && ( string.lower( input ) == "zoom" ) ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			local keyValues = ent:GetKeyValues()
			ply:SetFOV( tonumber( keyValues[ "FOV" ] ), tonumber( keyValues[ "Rate" ] ) )
		
		end
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "point_teleport_destination" ) && ( string.lower( input ) == "teleport" ) ) then
	
		for _, ply in ipairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( ent:GetPos() )
			ply:SetFOV( 0, 0 )
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "storage_room_door" ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "razor_train_gate_2" ) && ( string.lower( input ) == "close" ) ) then
	
		TRAINSTATION_LEAVEBARNEYDOOROPEN = true
	
	end

	if ( !game.SinglePlayer() && TRAINSTATION_LEAVEBARNEYDOOROPEN && ( ent:GetName() == "barney_door_1" ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
