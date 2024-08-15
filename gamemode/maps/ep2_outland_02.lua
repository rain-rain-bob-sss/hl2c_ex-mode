if CLIENT then return end

local previousmapcompleted = file.Exists( "hl2c_eternal/ep2_outland_04.txt", "DATA" )

if previousmapcompleted then

	INFO_PLAYER_SPAWN = { Vector( -3100, -9476, -3097 ), 0 }
	NEXT_MAP = "ep2_outland_05"
	GM.XP_REWARD_ON_MAP_COMPLETION = 0


else

	-- INFO_PLAYER_SPAWN = { Vector( -6695, 6144, 1630 ), 0 }
	NEXT_MAP = "ep2_outland_03"
	TRIGGER_CHECKPOINT = {
		{Vector(-2284, -9132, -716), Vector(-2516, -8900, -596)},
	}
	
end

-- Player spawns
function hl2cPlayerSpawn( ply )
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Player initial spawn
function hl2cPlayerInitialSpawn( ply )
	ply:SendLua( "table.insert( FRIENDLY_NPCS, \"npc_turret_floor\" )" )
end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )

-- Initialize entities
function hl2cMapEdit()
	table.insert(FRIENDLY_NPCS, "npc_turret_floor")

	ents.FindByName("spawnitems_template")[1]:Remove()

	if previousmapcompleted then
		local vort = ents.Create("npc_vortigaunt")
		vort:SetPos(Vector(-3100, -9500, -3097))
		vort:SetName("vort")
		vort:Spawn()
	end
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input, activator )
	if !game.SinglePlayer() and ent:GetName() == "turret_arena_vcd_2" and string.lower(input) == "start" then
		for _,ply in pairs(player.GetAll()) do
			if ply ~= activator then
				ply:SetPos(Vector(-3024, -9304, -894))
			end
		end
		
		GAMEMODE:CreateSpawnPoint( Vector(-3024, -9304, -894), -90 )
	end
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
