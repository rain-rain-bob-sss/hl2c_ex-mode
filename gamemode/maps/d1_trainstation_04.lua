NEXT_MAP = "d1_trainstation_05"

TRIGGER_CHECKPOINT = {
	{ Vector( -7075, -4259, 539 ), Vector( -6873, -4241, 649 ) },
	{ Vector( -7665, -4041, -257 ), Vector( -7653, -3879, -143 ) }
}


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

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "kickdown_relay" )[ 1 ]:Remove()
	
		for _, ent in ipairs( ents.GetAll() ) do
		
			if ( ent:GetPos() == Vector( -7818, -4128, -176 ) ) then ent:Remove(); end
		
		end
	
	end

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

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_alyxgreet02" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetPos( Vector( -7740, -3960, 407 ) )
			ply:SetEyeAngles( Angle( 0, 0, 0 ) )
			ply:SetFOV( 0, 1 )
		
		end
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
