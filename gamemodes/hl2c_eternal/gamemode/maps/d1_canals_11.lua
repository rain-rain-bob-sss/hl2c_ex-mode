ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_12"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()
	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "brush_maproom_pclip" )[ 1 ]:Remove()
		ents.FindByName( "gate1" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput(ent, input, activator, caller)

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_guncave_briefing1" ) && string.lower(input) == "start" ) then
	
		ALLOWED_VEHICLE = nil
	
		for _, ply in pairs(player.GetLiving()) do
			if IsValid(ply.vehicle) then
				if ply:InVehicle() then ply:ExitVehicle() end
				ply:RemoveVehicle()
			end

			ply:SetVelocity(Vector(0,0,0))
			ply:SetPos(Vector(6367, 5408, -895))
			ply:SetEyeAngles(Angle(0, -45, 0))
		end
		GAMEMODE:CreateSpawnPoint(Vector(6367, 5408, -895), -45)

	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "relay_guncave_startgunmount" ) && ( string.lower(input) == "enablerefire" ) ) then
	
		ALLOWED_VEHICLE = "Airboat Gun"
		PrintMessage( HUD_PRINTTALK, "You're now allowed to spawn the Airboat & Gun (F3)." )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "door_guncave_entrance" ) && ( string.lower(input) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "door_guncave_exit" ) && ( string.lower(input) == "close" ) ) then
	
		return true
	
	end

end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
