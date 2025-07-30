NEXT_MAP = "ep1_citadel_02"

TRIGGER_CHECKPOINT = {
	{ Vector( -5216, 1536, 2592 ), Vector( -5030, 1428, 2768 ) },
}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


hook.Add("EntityTakeDamage", "hl2cEntityTakeDamage", function(ent, dmginfo)
	local atk = dmginfo:GetAttacker()
	if (ent:GetClass() == "npc_combine_s" or atk:GetClass() == "npc_rollermine" or atk:GetClass() == "npc_cscanner") and not atk:IsPlayer() then
		dmginfo:SetDamage(math.huge)
	end
end)

-- Initialize entities
function hl2cMapEdit()

	-- ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	-- ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	-- ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()
	
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input, activator, caller, value )
    if not game.SinglePlayer() and string.lower(input) == "scriptplayerdeath" then -- Might potentially break sequences
        return true
    end

	if not game.SinglePlayer() and ent:GetName() == "door_rollertraining" and string.lower(input) == "setanimation" and (value == "close" or value == "idle_close") then
		print("no")
		return true
	end

	if not game.SinglePlayer() and ent:GetName() == "brush_combineshieldwall4" and string.lower(input) == "enable" then
	end

	if (ent:GetName() == "cs_training" or ent:GetName() == "cs_training_2") and string.lower(input) == "sethealth" then 
		ent:SetHealth(value)
		return true
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

