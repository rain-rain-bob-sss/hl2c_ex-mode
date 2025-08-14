NEXT_MAP = "d1_trainstation_01"

FORCE_PLAYER_RESPAWNING = true

FORCE_DIFFICULTY = 7.5

MAP_ENTITIES_RESPAWN = true
MAP_CAN_RESPAWN_ENTITIES = {
}

MAP_CAN_RESPAWN_WEAPONS = {
}

MAP_CAN_RESPAWN_ENTITY = function(ent)
	if string.StartsWith(ent:GetClass(),"item_") then 
		return true
	end
	if string.StartsWith(ent:GetClass(),"weapon_") then 
		return true
	end
end

MAP_ENTITIES_RESPAWNTIME = 5

if CLIENT then return end

hook.Add("PlayerSpawn", "hl2cPlayerSpawn", function(ply)
	ply:Give("weapon_crowbar")
	ply:Give("weapon_pistol")
	ply:Give("weapon_357")
	ply:Give("weapon_smg1")
	ply:Give("weapon_ar2")
	ply:Give("weapon_shotgun")
	ply:Give("weapon_crossbow")
	ply:Give("weapon_frag")
	-- if gotrpg then
		-- ply:Give("weapon_rpg")
	-- end
end)

hook.Add("OnEntityCreated", "No", function(ent)
	local class = ent:GetClass()
	timer.Simple(0, function()
		if not ent:IsValid() then return end
		if class == "npc_antlionguard" then
			ent:Input("EnableBark")
		elseif class == "npc_strider" then
			ent:Input("EnableAggressiveBehavior")
		end
	end)
end)

-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

function hl2cAcceptInput(ent, input)
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
