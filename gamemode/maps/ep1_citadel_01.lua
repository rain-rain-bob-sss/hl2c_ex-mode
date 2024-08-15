NEXT_MAP = "ep1_citadel_02"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	-- ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	-- ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	-- ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()
	
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
