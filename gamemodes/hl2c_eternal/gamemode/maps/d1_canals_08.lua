ALLOWED_VEHICLE = "Airboat"

INFO_PLAYER_SPAWN = { Vector( 7512, -11398, -438 ), 0 }

NEXT_MAP = "d1_canals_09"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn(ply)

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )

end
hook.Add("PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn)

local function CreateMetropolice(pos, ang, wep, target)
	local npc = ents.Create("npc_metropolice")
	npc:Give(wep)
	npc:SetPos(pos)
	npc:SetAngles(ang)
	npc:Spawn()
	if target and target:IsValid() then
		npc:SetEnemy(target)
		npc:UpdateEnemyMemory(target, target:GetPos())
	end
end

-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()
	if ( !game.SinglePlayer() ) then ents.FindByName( "trigger_close_gates" )[ 1 ]:Remove(); end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

hook.Add("AcceptInput", "hl2cAcceptInput", function(ent, input)
	if GAMEMODE.EXMode and ent:GetName() == "door_warehouse_basement" and string.lower(input) == "unlock" then
		PrintMessage(3, "You prefer going the hard way? Alright.")

		local ang = Angle(0, 90, 0)
		CreateMetropolice(Vector(-756, -860, -576), ang, "weapon_smg1")
		CreateMetropolice(Vector(-836, -860, -576), ang, "weapon_smg1")
	end
end)
