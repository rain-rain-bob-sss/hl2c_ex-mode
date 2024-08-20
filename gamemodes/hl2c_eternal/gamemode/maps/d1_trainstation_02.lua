INFO_PLAYER_SPAWN = { Vector( -4257, -179, -61 ), -95 }
GM.XP_REWARD_ON_MAP_COMPLETION = 0

NEXT_MAP = "d1_trainstation_03"

if CLIENT then return end

local activated

-- Player spawns
hook.Add( "PlayerReady", "hl2cPlayerReady", function(ply)
	if !GAMEMODE.EXMode then return end
	timer.Simple(1, function()
		-- ply:SendLua([[chat.AddText("Combine in this map are hostile and will always oneshot on hit.") chat.AddText("Run for your life.")]])
		ply:PrintMessage(3, "Combine in this map are hostile and will always oneshot on hit.")
		ply:PrintMessage(3, "Run for your life.")
	end)
end)

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:RemoveSuit()
	timer.Simple( 0.01, function() if ( IsValid( ply ) ) then GAMEMODE:SetPlayerSpeed( ply, 150, 150 ); end; end )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()
	if GAMEMODE.EXMode then
		game.SetGlobalState( "gordon_precriminal", GLOBAL_OFF )
		game.SetGlobalState( "gordon_invulnerable", GLOBAL_OFF )
		activated = nil
	else
		game.SetGlobalState( "gordon_precriminal", GLOBAL_ON )
		game.SetGlobalState( "gordon_invulnerable", GLOBAL_ON )
	end
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

function hl2cEntityTakeDamage(ent, dmginfo)
	if !GAMEMODE.EXMode then return end
	local attacker = dmginfo:GetAttacker()
	local activewep = attacker:IsValid() and attacker.GetActiveWeapon and attacker:GetActiveWeapon() or NULL
	if attacker:IsValid() and attacker:IsNPC() and activewep:IsValid() and activewep:GetClass() == "weapon_stunstick" then
		ent:SetHealth(0)
		dmginfo:SetDamage(9e9)
	end
end
hook.Add("EntityTakeDamage", "hl2cEntityTakeDamage", hl2cEntityTakeDamage)


local function CreateMetropolice(pos, ang, target)
	local npc = ents.Create("npc_metropolice")
	npc:Give("weapon_stunstick")
	npc:SetPos(pos)
	npc:SetAngles(ang)
	npc:Spawn()
	npc:SetEnemy(target)
	npc:UpdateEnemyMemory(target, target:GetPos())
end

hook.Add("AcceptInput", "hl2cAcceptInput", function(ent, input, activator)
	local names = {"lcs_CupCop_Pass", "lcs_CupCop_Fail"}
	if GAMEMODE.EXMode and table.HasValue(names, ent:GetName()) and string.lower(input) == "start" and not activated then
		local ang = Angle(0,0,0)
		local pl = player.GetAll()[1]
		CreateMetropolice(Vector(-4388, -720, 64), ang, pl)
		CreateMetropolice(Vector(-4388, -800, 64), ang, pl)
		CreateMetropolice(Vector(-4388, -880, 64), ang, pl)

		ang = Angle(0, 90, 0)
		CreateMetropolice(Vector(-3728, -1640, 64), ang, pl)
		CreateMetropolice(Vector(-3824, -1640, 64), ang, pl)
		
		ang = Angle(0, -90, 0)
		CreateMetropolice(Vector(-3420, -1760, 64), ang, pl)
		CreateMetropolice(Vector(-3328, -1760, 64), ang, pl)
		CreateMetropolice(Vector(-3236, -1760, 64), ang, pl)
		activated = true
	end
end)
