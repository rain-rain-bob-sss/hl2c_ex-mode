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

local gman_killed, respawning_crate, respawning_crate_kill

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

	gman_killed = nil
	respawning_crate = nil
	respawning_crate_kill = nil
	

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
function hl2cAcceptInput( ent, input, activator )

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

	if GAMEMODE.EXMode then
		if GAMEMODE:GetDifficulty() > 15 and ent:GetName() == "scene2_flash_mode_2" and string.lower(input) == "enablerefire" then
			if gman_killed then return true end

			if math.random(10) == 1 then
				local gman = ents.FindByName("gman")[1]

				if gman and gman:IsValid() then
					gman:SetHealth(0)

					for i=1,math.random(15,35) do
						local explosion = ents.Create("env_explosion")
						explosion:SetPos(gman:GetPos() + gman:OBBCenter())
						explosion:SetKeyValue("iMagnitude", "10000")
						explosion:SetKeyValue("iRadiusOverride", "250")
						explosion:Spawn()
						explosion:Input("explode")
					end
--[[
					local e = EffectData()
					e:SetOrigin(gman:GetPos() + gman:OBBCenter())
					for i=1,math.random(15,35) do
						util.Effect("Explosion", e)
					end
]]
				end
			end

			timer.Simple(0.08, function()
				if !ent:IsValid() then return end
				ent:Fire("trigger")
			end)
		end

		if ent:GetName() == "scene4_start" and string.lower(input) == "enablerefire" then
			timer.Simple(3, function() PrintMessage(3, "Chapter 1") end)
			timer.Simple(math.Rand(6.5,7.5), function() PrintMessage(3, "The new beginnings") end)
			ents.FindByName("scene2_flash_mode_2")[1]:Fire("kill")
		end


		if ent:GetName() == "ss_luggagedrop_1" and string.lower(input) == "beginsequence" then
			for a=1,4 do
				for b=1,4 do
					for c=1,4 do
						local prop = ents.Create("prop_physics")
						prop:SetPos(activator:GetPos() + Vector(-25+10*a,-25+10*b,80+(-25+10*c)))
						prop:SetModel("models/props_c17/SuitCase001a.mdl")
						prop:Spawn()
						local phys = prop:GetPhysicsObject()
						if phys and phys:IsValid() then
							phys:Wake()
						end
					end
				end
			end
		end

		if ent:GetName() == "barneyroom_camera_2" and string.lower(input) == "toggle" then
			ent:Input("SetAngry")
			return true
		end

		if GAMEMODE:GetDifficulty() > 69.6969696969 and ent:GetName() == "ss_luggagedrop_2" and string.lower(input) == "beginsequence" then
			local randommodels = {
				"models/props_junk/watermelon01.mdl",
				"models/props_junk/GlassBottle01a.mdl",
				"models/props_junk/gascan001a.mdl",
				"models/props_junk/garbage_glassbottle001a.mdl",
				"models/props_lab/citizenradio.mdl",
				"models/props_c17/oildrum001_explosive.mdl",
				"models/props_c17/doll01.mdl",
				"models/props_interiors/pot01a.mdl",
				"models/weapons/w_alyx_gun.mdl",
				"models/weapons/w_annabelle.mdl",
				"models/weapons/w_crowbar.mdl",
				"models/props_junk/sawblade001a.mdl"
			}

			for a=1,5 do
				for b=1,5 do
					for c=1,4 do
						local prop = ents.Create("prop_physics")
						prop:SetPos(activator:GetPos() + Vector(-45+15*a,-45+15*b,100+(-35+15*c)))
						prop:SetModel(table.Random(randommodels))
						prop:Spawn()
						local phys = prop:GetPhysicsObject()
						if phys and phys:IsValid() then
							local vel = 450
							phys:Wake()
							phys:SetVelocityInstantaneous(Vector(math.Rand(-vel,vel), math.Rand(-vel,vel), math.Rand(-vel,vel)))
						end
					end
				end
			end

			local ent2 = ents.FindByName("turnstyle_1")[1]
			if ent2 and ent2:IsValid() then
   			 	local time = math.Rand(5,10)
				local ctime = CurTime()

				timer.Create("Hl2ce.SPINNNNN", 0, math.ceil(time/engine.TickInterval()), function()
					if not ent2:IsValid() then return end

				    ent2:SetAngles(ent2:GetAngles() + Angle(0,-360*(CurTime()-ctime)*FrameTime(),0))
					local phys = ent2:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetAngleVelocity(Vector(0, 0, -100))
					end
				end)

				local e = EffectData()
				e:SetOrigin(ent2:GetPos())
				ent2:Fire("Kill", nil, time)
				timer.Simple(time, function()
					for i=1,15 do
						util.Effect("Explosion", e)
					end
				end)
			end
		end

		if ent:GetName() == "luggage_push_explosion1" and string.lower(input) == "explode" then
			activator:SetHealth(0)
			activator:TakeDamage(1) -- kill it
		end

		if GAMEMODE:GetDifficulty() > 10 and ent:GetName() == "storage_room_door" then
			local entity = ents.FindByClass("npc_barney")[1]
			if !entity or !entity:IsValid() then return end

			barney_killed_themselves = true

			entity:SetHealth(1)

			for i=1,30 do
				local exp = ents.Create("env_explosion")
				exp:SetPos(entity:GetPos())
				exp:SetKeyValue("iMagnitude", "250")
				exp:Spawn()
				exp:Fire("explode")
			end
		end

		if ent:GetName() == "intro_music" and string.lower(input) == "playsound" then
			BroadcastLua([[LocalPlayer():EmitSound("*#music/hl1_song3.mp3", 0, 100)]]) -- bruh hl1 intro song instead of hl2 intro one? yes, what did you expect
			return true
		end

		if ent:GetName() == "respawning_crate" and string.lower(input) == "use" then
			respawning_crate = activator
		end

		if ent:GetName() == "respawning_crate" and string.lower(input) == "kill" then
			respawning_crate_kill = true
			return true
		end

		if ent:GetName() == "crate_template" and string.lower(input) == "forcespawn" then
			if respawning_crate and respawning_crate:IsValid() then
				respawning_crate:Kill()
			end

			return true
		end
	end
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

-- Accept input
function hl2cOnNPCKilled( ent, attacker )

	if GAMEMODE.EXMode then
		if ent:GetName() == "barney" then
			if barney_killed_themselves or ent == attacker then
				PrintMessage(3, table.Random({
					"wow barney killed themselves",
					"Hold ze fuck up how is this possible?!",
					"Fuck you gman you set this up!!!",
					"Barney died... the world is in danger.",
					"ARE YOU FUCKIN--",
				}))
			else
				PrintMessage(3, table.Random({
					"...yeah let's just skip this part",
					"Did you softlocked? Congrats.",
					"You just killed barney on your own.",
				}))
			end
		end

		if ent:GetName() == "gman" then
			gman_killed = true
		end
	end

end
hook.Add( "OnNPCKilled", "hl2cOnNPCKilled", hl2cOnNPCKilled )