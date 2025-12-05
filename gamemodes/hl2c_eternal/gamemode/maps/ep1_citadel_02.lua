NEXT_MAP = "ep1_citadel_02b"
GM.XpGainOnNPCKillMul = 0.35
GM.DifficultyGainOnNPCKillMul = 0.5


if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )

hook.Add("Think", "hl2cThink", function()
	if game.GetGlobalState("super_phys_gun") == GLOBAL_ON then
		for _, ent in pairs( ents.FindByClass( "weapon_*" ) ) do
			if ( IsValid( ent ) && ent:IsWeapon() && ( ent:GetClass() != "weapon_physcannon" ) && ( !IsValid( ent:GetOwner() ) || ( IsValid( ent:GetOwner() ) && ent:GetOwner():IsPlayer() ) ) ) then
				if not ent.CanUseInCitadel then
					ent:Remove()
				end
			end
		end
	end
end)

-- Initialize entities
function hl2cMapEdit()

	game.SetGlobalState( "super_phys_gun", GLOBAL_ON )

	--ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	--ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )
