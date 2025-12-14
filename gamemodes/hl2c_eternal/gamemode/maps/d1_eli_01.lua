NEXT_MAP = "d1_eli_02"
GM.XP_REWARD_ON_MAP_COMPLETION = 0
GM.XpGainOnNPCKillMul = 0.25
GM.DifficultyGainOnNPCKillMul = 0.3

TRIGGER_CHECKPOINT = {
	{ Vector( 364, 1764, -2730 ), Vector( 549, 1787, -2575 ) }
}

TRIGGER_DELAYMAPLOAD = { Vector( -703, 989, -2688 ), Vector( -501, 1029, -2527 ) }

if CLIENT then
	hook.Add("OnMapCompleted", "MapCompletion", function(ply)
		chat.AddText(Color(255,255,100), "How did you survive this?! ", Color(255,0,0), "You lunatic...")
		chat.AddText(Color(192,0,0), "You don't know what's coming next! And you won't survive it...")
	end)

	return
end

local chaos_begun = false

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	local function Increase(cvar, count)
		RunConsoleCommand(cvar, GetConVar(cvar):GetInt()*count)
	end

	timer.Simple(0, function()
		Increase("sk_max_smg1", 4)
		Increase("sk_max_357", 5)
		Increase("sk_max_pistol", 3)
		Increase("sk_max_grenade", 2)
	end)
end)

-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
		ents.FindByName( "pclip_airlock_1_a" )[ 1 ]:Remove()
		ents.FindByName( "brush_exit_door_raven_PClip" )[ 1 ]:Remove()
		ents.FindByName( "pclip_exit_door_raven2" )[ 1 ]:Remove()
		ents.FindByName( "pclip_airlock_2_a" )[ 1 ]:Remove()
	end

	if GAMEMODE.EXMode then
		chaos_begun = false

		ents.FindByName("doors_Airlock_Outside")[1]:Fire("setspeed", 10000)

		local function SpawnCrate(id, pos, ang, func)
			local ent = ents.Create("item_ammo_crate")
			ent:SetKeyValue("AmmoType", id)
			ent:SetPos(pos)
			ent:SetAngles(ang)
			if func then
				func(ent)
			end
			ent:Spawn()

			return ent
		end

		SpawnCrate(0, Vector(-900, 3200, -1264), Angle(0,90,0))
		SpawnCrate(1, Vector(-800, 3200, -1264), Angle(0,90,0))
		SpawnCrate(5, Vector(160, 3200, -1264), Angle(0,180,0))
		SpawnCrate(6, Vector(160, 3280, -1264), Angle(0,180,0))
		SpawnCrate(9, Vector(-100, 2900, -1264), Angle(0,90,0))

		local prop = ents.Create("prop_physics")
		prop:SetHealth(0)
		prop:SetModel("models/props_junk/gascan001a.mdl")
		prop:SetPos(Vector(78.055008, 2884.690918, -1264.667114))
		prop:SetAngles(Angle(-0.002, 89.398, 0.001))
		prop:SetColor(Color(255,0,0))
		prop:Spawn()
		prop:SetMoveType(0)

		local propblock = {}
		
		for i=1,20 do
			propblock[i] = ents.Create("prop_physics")
			propblock[i]:SetModel("models/props_lab/blastdoor001b.mdl")
			propblock[i]:SetPos(Vector(-24, 2870, -1280))
			propblock[i]:SetAngles(Angle(0, 90, 0))
			propblock[i]:SetColor(Color(255, 255, 255))
			propblock[i]:Spawn()

			if i<5 then
				propblock[i]:SetMoveType(0)
			else
				propblock[i]:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end

		local plys = {}
		hook.Add("PlayerUse", "hl2c.d1_eli_01.Blah", function(ply, ent)
			if ent ~= prop then return end
			if table.HasValue(plys, ply) then
				if table.Count(plys) >= #player.GetHumans()*0.55 then
					prop:Remove()
					hook.Remove("PlayerUse", "hl2c.d1_eli_01.Blah")
				end

				return
			end

			for _,pl in ipairs(plys) do
				if IsValid(pl) then continue end

				table.RemoveByValue(plys, val)
			end

			table.insert(plys, ply)

			PrintMessage(3, string.format("%s wants to proceed! (%d/%d)", ply:Nick(), table.Count(plys), math.ceil(#player.GetHumans()*0.55)))

			if table.Count(plys) >= #player.GetHumans()*0.55 then
				prop:Remove()
				hook.Remove("PlayerUse", "hl2c.d1_eli_01.Blah")
			end
		end)

		hook.Add("EntityTakeDamage", "hl2c.d1_eli_01.Blah", function(ent, dmginfo)
			if ent == prop then
				local ply = dmginfo:GetAttacker()
				if !ply:IsPlayer() then return true end
				if table.HasValue(plys, ply) then
					if table.Count(plys) >= #player.GetHumans()*0.55 then
						prop:Remove()
						hook.Remove("PlayerUse", "hl2c.d1_eli_01.Blah")
					end
				
					return
				end
			
				for _,pl in ipairs(plys) do
					if IsValid(pl) then continue end
				
					table.RemoveByValue(plys, val)
				end
			
				table.insert(plys, ply)
			
				PrintMessage(3, string.format("%s wants to proceed! (%d/%d)", ply:Nick(), table.Count(plys), math.ceil(#player.GetHumans()*0.55)))
			
				if table.Count(plys) >= #player.GetHumans()*0.55 then
					prop:Remove()
					hook.Remove("PlayerUse", "hl2c.d1_eli_01.Blah")
				end	
				return true
			end
		end)

		hook.Add("EntityRemoved", "hl2c.d1_eli_01.Blah", function(ent)
			if ent == prop then
				hook.Remove("PlayerUse", "hl2c.d1_eli_01.Blah")
				hook.Remove("EntityTakeDamage", "hl2c.d1_eli_01.Blah")
				hook.Remove("EntityRemoved", "hl2c.d1_eli_01.Blah")
				timer.Remove("hl2c.d1_eli_01.reminder")

				timer.Simple(3, function()
					for i=1,#propblock do
						local prop = propblock[i]
						if !IsValid(prop) then continue end

						local e = EffectData()
						e:SetOrigin(prop:GetPos() + prop:OBBCenter())
						for i=1,3 do
							util.Effect("Explosion", e)
						end

						prop:Remove()
					end
				end)
			end
		end)

		local plys = {}
		timer.Create("hl2c.d1_eli_01.reminder", 1, 0, function()
			for _,ply in ipairs(player.GetAll()) do
				if table.HasValue(plys, ply) then continue end
				if prop:GetPos():DistToSqr(ply:GetPos()) > 90000 then continue end

				table.insert(plys, ply)
				ply:PrintMessage(3, "Press the use key on the red gas can! But only if you're ready...")
			end
		end)
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

hook.Add("OnMapFailed", "hl2cOnMapFailed", function(ply)
	timer.Remove("d1_eli_01.trap")
	if !chaos_begun then return end

	local diff = GAMEMODE:GetDifficulty(true, true)
	if diff > InfNumber(math.huge) then
		GAMEMODE:SetDifficulty(diff^0.95)
	else
		GAMEMODE:SetDifficulty(diff*0.85)

		PrintMessage(3, "You failed!")
		PrintMessage(3, "Remember to stock up on ammo before you proceed!")
	end
end)


local function SpawnNPC(class, pos, ang, func)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if func then
		func(ent)
	end
	ent:Spawn()

	return ent
end

local function SpawnItem(class, pos, ang, func)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if func then
		func(ent)
	end
	ent:Spawn()

	return ent
end

-- Accept input
function hl2cAcceptInput( ent, input, activator )
	local entname = ent:GetName()
	local lowerinput = input:lower()

	if !GAMEMODE.EXMode and !game.SinglePlayer() then
		if ( ( entname == "doors_Airlock_Outside" ) || ( entname == "inner_door" ) || ( entname == "lab_exit_door_raven" ) || ( entname == "lab_exit_door_raven2" ) || ( entname == "airlock_south_door" ) || ( entname == "airlock_south_doorb" ) ) && ( lowerinput == "close" ) then
			return true
		end
		
		if entname == "airlock_door" and lowerinput == "open" then
			local door = ents.FindByName("doors_Airlock_Outside")[1]
			door:Fire("Unlock")
			door:Fire("Open")
		end
	end

	if ( !game.SinglePlayer() && ( entname == "lcs_mosstour05" ) && ( lowerinput == "start" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
			if ply == activator then continue end
			ply:SetVelocity(-ply:GetVelocity())
			ply:SetPos(Vector(457, 1656, -1267))
			ply:SetEyeAngles( Angle( 0, 90, 0 ) )
		end

	end

	if GAMEMODE.EXMode then
		if entname == "doors_Airlock_Outside" and lowerinput == "close" then
			PrintMessage(3, ":)")

			GAMEMODE:ReplaceSpawnPoint( Vector(-64, 2732, -1272), -90 )
			for _,ply in pairs(player.GetAll()) do
				ply:SetPos(Vector(-64, 2732, -1272))
				ply:SetEyeAngles(Angle(0, -90, 0))
			end

			for i=1,50 do
				SpawnItem("item_battery", Vector(-64, 2732, -1272), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
		end

		-- if ( ( entname == "doors_Airlock_Outside" ) || ( entname == "inner_door" ) || ( entname == "lab_exit_door_raven" ) || ( entname == "lab_exit_door_raven2" ) || ( entname == "airlock_south_door" ) || ( entname == "airlock_south_doorb" ) ) && ( lowerinput == "close" ) then

		if entname == "logic_startScene" and lowerinput == "trigger" then
			timer.Simple(1.5, function()
				PrintMessage(3, "Chapter 5")
			end)
		end

		if entname == "logic_Airlock_spriteSpotlights_On" and lowerinput == "trigger" then
			chaos_begun = true

			local function func()
				if !ent:IsValid() then return end
				for i=1,2 do
					local ent = SpawnNPC("npc_zombie", Vector((-i+1)*128, 2850, -1272), Angle(0,-90,0))
					-- ent:SetHealth(ent:Health()*0.5)
					-- ent:SetMaxHealth(ent:GetMaxHealth()*0.5)
					ent:SetCollisionGroup(2)
				end
			end
			timer.Create("d1_eli_01.trap", 1, 40, func)
			func()

			timer.Simple(0.65, function()
				-- alt name: The Extreme Trial For The Worthy
				PrintMessage(3, "YOU FUCKED UP")
			end)
		end

		if entname == "lcs_mosstour01" and lowerinput == "start" then
			for i=1,5 do
				SpawnNPC("npc_zombie", Vector(-28+(i-1)*32, 2350, -1280), Angle(0,90,0))
				SpawnNPC("npc_fastzombie", Vector(-28+(i-1)*32, 2400, -1280), Angle(0,90,0))
				
				SpawnNPC("npc_zombie", Vector(-28+(i-1)*32, 2150, -1280), Angle(0,90,0))
				SpawnNPC("npc_fastzombie", Vector(-28+(i-1)*32, 2200, -1280), Angle(0,90,0))
			end

			for i=1,30 do
				SpawnItem("item_healthkit", Vector(0, 2164, -1216), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
		end

		if entname == "lcs_mosstour02" and lowerinput == "start" then
			for i=1,5 do
				SpawnNPC("npc_zombie", Vector(406+(i-1)*26, 1850, -1280), Angle(0,90,0))
				SpawnNPC("npc_fastzombie", Vector(406+(i-1)*26, 1800, -1280), Angle(0,90,0))
			end

			for i=1,12 do
				SpawnNPC("npc_fastzombie", Vector(2048, 1824+(i-1)*24, -1400), Angle(0,180,0))
			end
		end

		if entname == "lcs_mosstour03" and lowerinput == "start" then
			GAMEMODE:ReplaceSpawnPoint(Vector(294, 2068, -1272), 0)
			for _,ply in pairs(player.GetAll()) do
				if ply == activator then continue end
				ply:SetPos(Vector(294, 2068, -1272))
				ply:SetEyeAngles(Angle(0, 0, 0))
			end


			for i=1,9 do
				SpawnNPC("npc_poisonzombie", Vector(414+((1+i%3)-1)*40, 1700-(math.floor((i-1)/3))*40, -1956), Angle(0,90,0))
			end
			for i=1,3 do
				SpawnItem("item_ammo_smg1_large", Vector(454, 1740, -1894), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
			for i=1,2 do
				SpawnItem("item_ammo_smg1_grenade", Vector(454, 1740, -1894), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
			for i=1,3 do
				SpawnItem("item_ammo_357_large", Vector(454, 1740, -1894), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
			for i=1,8 do
				SpawnItem("item_battery", Vector(454, 1740, -1894), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
			for i=1,5 do
				SpawnItem("item_healthkit", Vector(454, 1740, -1894), Angle(0,0,0), function(ent)
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(VectorRand()*1000)
					end
				end)
			end
		end

		if entname == "lcs_mosstour05" and lowerinput == "start" then
			for _,zm in ipairs(ents.FindByClass("npc_*zombie")) do
				zm:Ignite(300)
			end

			for _,zm in ipairs(ents.FindByClass("npc_headcrab*")) do
				zm:Dissolve(2)
				zm:SetHealth(0)
				zm:TakeDamage(math.huge, ents.FindByClass("gmod_gamerules")[1], ent)
				zm:Fire("becomeragdoll")
			end

			timer.Simple(5, function()
				local e = ents.FindByName("vort__lounger01")[1]
				
				timer.Create("blah", 0.04, 500, function()
					if !IsValid(e) then return end
					
					if timer.RepsLeft("blah")%5 == 0 then
						local ex = ents.Create("env_explosion")
						ex:SetPos(e:GetPos())
						ex:SetKeyValue("iMagnitude", 140)
						ex:Spawn()
						ex:Fire("explode")
					else
						local eff = EffectData()
						eff:SetOrigin(e:GetPos() + e:OBBCenter())
						util.Effect("Explosion", eff)
					end
				end)
			end)

			timer.Simple(10, function()
				local e1 = ents.FindByName("sheffy_butcher")[1]
				local e2 = ents.FindByName("sheffy_soup")[1]


				e1:Dissolve(2)
				e1:Input("becomeragdoll")
				e2:Ignite(10000)
				for i=1,12 do
					SpawnNPC("npc_poisonzombie", Vector(840, 1880+(i-1)*30, -1800), Angle(0,180,0), function(ent)
						timer.Simple(2, function()
							if !IsValid(ent) then return end
							ent:Ignite(100)
						end)
					end)
				end
			end)

			timer.Simple(12, function()
				for i=1,5 do
					SpawnNPC("npc_hunter", Vector(456, 2520+(i-1)*60, -2158), Angle(0,-90,0), function(ent)
						timer.Simple(5, function()
							if !IsValid(ent) then return end

							ent:Dissolve(2)
							ent:SetHealth(0)
							ent:TakeDamage(math.huge, ents.FindByClass("gmod_gamerules")[1], ent)
							ent:Fire("becomeragdoll")
						end)
					end)
				end
			end)

		end

		if entname == "lcs_Labtalk01" and lowerinput == "start" then
			ents.FindByName("elevator_lab")[1]:Remove()
			for _,ent in pairs(ents.FindByName("prop_elevatordoor_bottom_1")) do
				ent:Fire("setanimation", "open", 5)
			end
			ents.FindByName("ele_door_B_L")[1]:Fire("open", nil, 5)
			ents.FindByName("ele_door_B_R")[1]:Fire("open", nil, 5)


			timer.Simple(10, function()
				PrintMessage(3, "Don't let the fast zombies take over this lab with 40+ fast zombies... or YOU LOSE!")

				local function func()
					if !ent:IsValid() then return end
					local ent = SpawnNPC("npc_fastzombie", Vector(456, 1664, -800) + VectorRand()*60, Angle(0,-90,0), function(ent)
						timer.Simple(120, function()
							if !IsValid(ent) then return end
							ent:Ignite(1000)
						end)
					end)

					if #ents.FindByClass("npc_fastzombie") > 40 then
						PrintMessage(3, "MAP FAILED! TOO MANY FAST ZOMBIES!")
						gamemode.Call("FailMap")

						for _,ent in pairs(ents.FindByClass("npc_*")) do
							ent:SetHealth(0)
							ent:Dissolve(2)
							ent:TakeDamage(math.huge, ents.FindByClass("gmod_gamerules")[1])
							ent:Fire("becomeragdoll")
						end
					end
				end
				timer.Create("d1_eli_01.trap2", 5, 0, func)
				func()
			end)
		end

		if entname == "lcs_Labtalk03" and lowerinput == "start" then
			for i=1,math.min(30, 3+player.GetCount()*3) do
				SpawnNPC("npc_combine_s", Vector(484+((i-1)%3)*40, 2600, -2732), Angle(0,-90,0), function(ent)
					ent:SetModel("models/combine_soldier_prisonguard.mdl")
					ent:Give("weapon_smg1")
				end)
			end
		end

		if (entname == "button_Xen_1_rot" or entname == "button_Xen_2_rot") and lowerinput == "setposition" then
			local eff = EffectData()
			eff:SetOrigin(ent:GetPos())
			util.Effect("Explosion", eff)
		end
	end


end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

hook.Add("EntityTakeDamage", "hl2cEntTakeDamage", function(ent, dmginfo)
	if string.lower(ent:GetName()) == "chester" then
		return true
	end
end)
