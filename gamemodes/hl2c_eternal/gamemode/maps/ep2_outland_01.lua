NEXT_MAP = "ep2_outland_01a"

TRIGGER_CHECKPOINT = {
	{Vector(340, -864, -4), Vector(404, -714, 96)},
	{Vector(-3560, 1657, 144), Vector(-3768, 1744, 252)}
}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input, activator, caller, value )
    if string.lower(input) == "scriptplayerdeath" then -- Can break the sequences, again
        return true
    end

	if ( !game.SinglePlayer() && ( ent:GetClass() == "player_speedmod" ) && ( string.lower( input ) == "modifyspeed" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetLaggedMovementValue( tonumber( value ) )
		
		end
	
		return true
	
	end

	if ent:GetName() == "command_physcannon" and string.lower(input) == "command" then
		for _,ply in pairs(player.GetAll()) do
			ply:Give("weapon_physcannon")
		end
	end
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
