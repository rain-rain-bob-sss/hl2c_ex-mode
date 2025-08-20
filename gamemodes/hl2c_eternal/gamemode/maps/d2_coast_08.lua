INFO_PLAYER_SPAWN = { Vector( 3328, 1505, 1537 ) + Vector(0,3450,0), -90 }

NEXT_MAP = "d2_coast_07"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_shotgun" )
	ply:Give( "weapon_ar2" )
	ply:Give( "weapon_rpg" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "jeep_filter" )[ 1 ]:Fire( "AddOutput", "filterclass prop_vehicle_jeep_old" )

	local propblock = ents.Create( "prop_physics" )
	propblock:SetName( "prop_block" )
	propblock:SetPos( Vector( 3328, 1575, 1600 ) + Vector(0,3450,0) )
	propblock:SetModel( "models/props_wasteland/rockcliff01b.mdl" )
	propblock:DrawShadow( false )
	propblock:Spawn()
	propblock:Activate()
	propblock:GetPhysicsObject():EnableMotion( false )

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "button_press" ) && ( string.lower( input ) == "trigger" ) ) then
	
		ents.FindByName( "prop_block" )[ 1 ]:Remove()
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( 2991, -6946, 1932 ) + Vector(0,3450,0) )
			ply:SetEyeAngles( Angle( 0, 0, 0 ) )
		
		end
		GAMEMODE:CreateSpawnPoint( Vector( 2991, -6946, 1932 ) + Vector(0,3450,0), 0 )
	
		if ( !file.Exists( "hl2c_eternal/d2_coast_08.txt", "DATA" ) ) then
		
			file.Write( "hl2c_eternal/d2_coast_08.txt", "We have been to d2_coast_08 and pressed the button." )
		
		end
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
