INFO_PLAYER_SPAWN = { Vector( -4257, -179, -61 ), -95 }
GM.XP_REWARD_ON_MAP_COMPLETION = 0

NEXT_MAP = "d1_trainstation_03"


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:RemoveSuit()
	timer.Simple( 0.01, function() if ( IsValid( ply ) ) then GAMEMODE:SetPlayerSpeed( ply, 150, 150 ); end; end )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()
	if GAMEMODE.EXMode then
		game.SetGlobalState( "gordon_precriminal", GLOBAL_OFF )
		game.SetGlobalState( "gordon_invulnerable", GLOBAL_OFF )
	else
		game.SetGlobalState( "gordon_precriminal", GLOBAL_ON )
		game.SetGlobalState( "gordon_invulnerable", GLOBAL_ON )
	end
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )
