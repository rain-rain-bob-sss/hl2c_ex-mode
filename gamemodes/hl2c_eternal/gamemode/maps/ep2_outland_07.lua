NEXT_MAP = "ep2_outland_08"

INFO_PLAYER_SPAWN = {Vector(-3054, -12266, 538), 180}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	-- ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()

	-- if ( !game.SinglePlayer() ) then ents.FindByName( "boxcar_door_close" )[ 1 ]:Remove(); end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
