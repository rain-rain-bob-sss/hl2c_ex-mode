NEXT_MAP = "d1_trainstation_02"
GM.XP_REWARD_ON_MAP_COMPLETION = 0

RESET_PL_INFO = true

TRIGGER_CHECKPOINT = {
	{Vector( -9386, -2488, 24 ), Vector( -9264, -2367, 92 ), true},
	{Vector( -5396, -1984, 16 ), Vector( -5310, -1932, 113 )},
	{Vector( -3609, -338, -24 ), Vector( -3268, -141, 54 )}
}

TRAINSTATION_LEAVEBARNEYDOOROPEN = false

if CLIENT then return end

-- Player initial spawn
function hl2cPlayerInitialSpawn( ply )

	ply:SendLua("table.RemoveByValue(GODLIKE_NPCS, \"npc_barney\")")
	ply:SendLua("table.RemoveByValue(FRIENDLY_NPCS, \"npc_citizen\")")
end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:RemoveSuit()
	timer.Simple( 0.01, function() if ( IsValid( ply ) ) then GAMEMODE:SetPlayerSpeed( ply, 150, 150 ) end end )

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

	if GAMEMODE.EXMode and ent:GetName() == "scene2_flash_mode_2" and string.lower(input) == "enablerefire" then
		timer.Simple(0.08, function()
			if !ent:IsValid() then return end
			ent:Fire("trigger")
		end)
	end

	if GAMEMODE.EXMode and ent:GetName() == "scene4_start" and string.lower(input) == "enablerefire" then
		timer.Simple(3, function() PrintMessage(3, "Chapter 1") end)
		timer.Simple(math.Rand(6.5,7.5), function() PrintMessage(3, "The new beginnings") end)
		ents.FindByName("scene2_flash_mode_2")[1]:Fire("kill")
	end

	if GAMEMODE.EXMode and ent:GetName() == "storage_room_door" then
		local entity = ents.FindByClass("npc_barney")[1]
		if !entity or !entity:IsValid() then return end

		for i=1,30 do
			local exp = ents.Create("env_explosion")
			exp:SetPos(entity:GetPos())
			exp:SetKeyValue("iMagnitude", "250")
			exp:Spawn()
			exp:Fire("explode")
		end
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

-- Accept input
function hl2cOnNPCKilled( ent, attacker )

	if GAMEMODE.EXMode then
		if ent:GetName() == "barney" then
			PrintMessage(3, "you fucked")
		end
	end

end
hook.Add( "OnNPCKilled", "hl2cOnNPCKilled", hl2cOnNPCKilled )
