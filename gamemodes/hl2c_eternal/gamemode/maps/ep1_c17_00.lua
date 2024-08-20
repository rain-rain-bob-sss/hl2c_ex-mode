NEXT_MAP = "ep1_c17_00a"

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


hook.Add("EntityTakeDamage", "hl2cEntityTakeDamage", function(ent, dmginfo)
	local atk = dmginfo:GetAttacker()

	if ent:GetName() == "train_2_ambush_zombine" and ent == atk then
		print("kill")
		dmginfo:SetDamage(math.huge) -- let the zombine die. no matter what
	end
end)

-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

local hastriggered

-- Accept input
function hl2cAcceptInput( ent, input )
	if ent:GetName() == "train_2_ambush_zombine" and string.lower(input) == "pullgrenade" then
		print("sethealth")
		-- ent:SetHealth(1)
	end
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
