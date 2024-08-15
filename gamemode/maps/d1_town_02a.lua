NEXT_MAP = "d1_town_04"

if CLIENT then return end

if ( file.Exists( "hl2c_eternal/d1_town_03.txt", "DATA" ) ) then

	file.Delete( "hl2c_eternal/d1_town_03.txt" )

end


-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_shotgun" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "startobjects_template" )[ 1 ]:Remove()

	local monk = ents.Create( "npc_monk" )
	monk:SetPos( Vector( -5221, 2034, -3240 ) )
	monk:SetAngles( Angle( 0, 90, 0 ) )
	monk:SetName( "monk" )
	monk:SetKeyValue( "additionalequipment", "weapon_annabelle" )
	monk:SetKeyValue( "spawnflags", "4" )
	monk:Spawn()
	monk:Activate()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "graveyard_exit_momentary_wheel" )[ 1 ]:Fire( "Lock" )
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "graveyard_exit_door" ) && ( string.lower( input ) == "setposition" ) ) then
	
		ent:Fire( "Open" )
		return true
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
