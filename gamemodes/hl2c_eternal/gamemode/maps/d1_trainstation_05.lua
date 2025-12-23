NEXT_MAP = "d1_trainstation_06"

TRIGGER_CHECKPOINT = {
	{ Vector( -6509, -1105, 0 ), Vector( -6459, -1099, 92 ) },
	{ Vector( -10461, -4749, 319 ), Vector( -10271, -4689, 341 ) }
}

TRAINSTATION_REMOVESUIT = true
MAP_FORCE_CHANGELEVEL_ON_MAPRESTART = false

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)

	if ( TRAINSTATION_REMOVESUIT ) then
	
		ply:RemoveSuit()
		timer.Simple(0.01, function() if ( IsValid( ply ) ) then GAMEMODE:SetPlayerSpeed( ply, 150, 150 ); end; end)
	
	end

	if ( !game.SinglePlayer() && IsValid(PLAYER_VIEWCONTROL) && PLAYER_VIEWCONTROL:GetClass() == "point_viewcontrol" ) then
	
		ply:SetViewEntity(PLAYER_VIEWCONTROL)
		ply:Freeze(true)
	
	end

	timer.Simple(0, function()
		ply:SetHealth(ply:GetMaxHealth())
	end)

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)


-- Entity removed
function hl2cEntityRemoved( ent )
	if ( ent:GetClass() == "item_suit" ) then
		TRAINSTATION_REMOVESUIT = false
		for _, ply in ipairs(player.GetAll()) do
			ply:EquipSuit()
			if ( !GAMEMODE.CustomPMs ) then ply:SetModel( string.gsub( ply:GetModel(), "group01", "group03" ) ); end
			ply:SetupHands()
			GAMEMODE:SetPlayerSpeed( ply, 190, 320 )
		end
	end
end
hook.Add( "EntityRemoved", "hl2cEntityRemoved", hl2cEntityRemoved )

function hl2cMapEdit()
	TRAINSTATION_REMOVESUIT = true
end
hook.Add("MapEdit", "hl2cMapEdit", hl2cMapEdit)


-- Accept input
function hl2cAcceptInput( ent, input, activator, caller, value )

	if ( !game.SinglePlayer() && ent:GetClass() == "point_viewcontrol" ) then
	
		if string.lower(input) == "enable" then
		
			PLAYER_VIEWCONTROL = ent
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ent )
				ply:Freeze(true)
			
			end
		
			if !ent.doubleEnabled then
			
				ent.doubleEnabled = true
				ent:Fire( "Enable" )
			
			end
		
		elseif string.lower(input) == "disable" then
		
			PLAYER_VIEWCONTROL = nil
		
			for _, ply in ipairs( player.GetAll() ) do
			
				ply:SetViewEntity( ply )
				ply:Freeze( false )
			
			end
		
			return true
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ( ent:GetName() == "lab_door" ) || ( ent:GetName() == "lab_door_clip" ) ) && ( string.lower(input) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "kleiner_teleport_player_starter_1" ) && ( string.lower(input) == "trigger" ) ) then
	
		for _, ply in ipairs(player.GetAll()) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( -7186.700195, -1176.699951, 28 ) )
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetClass() == "player_speedmod" ) && ( string.lower(input) == "modifyspeed" ) ) then
	
		for _, ply in ipairs(player.GetAll()) do
		
			ply:SetLaggedMovementValue( tonumber( value ) )
		
		end
	
		return true
	
	end

	if GAMEMODE.EXMode and ent:GetName() == "lab01_lcs" and string.lower(input) == "start" then
		timer.Simple(1.5, function() PrintMessage(3, "Chapter 2") end)
		timer.Simple(3.5, function() PrintMessage(3, "The brand new Teleporter Mark VII") end)

		ents.FindByName("lcs_alyxgreet04")[1]:Fire("pause")
	end

	if GAMEMODE.EXMode and ent:GetName() == "get_suit_math_1" and string.lower(input) == "add" and activator:IsPlayer() then
		PrintMessage(3, activator:Nick().." took the HEV suit")
		for _, ply in ipairs(player.GetAll()) do
			ply:SetPos(Vector( -10366, -4719, 330 ) )
		end
	end

	if GAMEMODE.EXMode and ent:GetName() == "blamarr_break_monitor_1" and string.lower(input) == "playsound" then
		local GL_NPCS = GODLIKE_NPCS
		GODLIKE_NPCS = {}
		for i=1,30 do
			local exp = ents.Create("env_explosion")
			exp:SetPos(ent:GetPos())
			exp:SetKeyValue("iMagnitude", "3000")
			exp:Spawn()
			exp:Fire("explode")
		end

		GODLIKE_NPCS = GL_NPCS
		ent:Remove()
	end

	if ent:GetName() == "logic_04_nags_0" and input:lower() == "trigger" then
		ents.FindByName("soda_machine_entry_door_1")[1]:Fire("open")
	end

	if ent:GetName() == "button_keypad_1" and input:lower() == "use" then
		local e = ents.FindByName("hev_door")[1]
		if e and e:IsValid() then
			e:Fire("open")
		end
		
		ents.FindByName("prop_keypad_1")[1]:Fire("skin", "1")
		ents.FindByName("prop_keypad_1")[1]:Fire("skin", "0", 2)
		ents.FindByName("prop_keypad_1")[1]:EmitSound("buttons/button3.wav")
		return true
	end

end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
