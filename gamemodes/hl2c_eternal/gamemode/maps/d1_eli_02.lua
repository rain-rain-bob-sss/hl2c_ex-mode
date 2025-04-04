NEXT_MAP = "d1_town_01"

TRIGGER_CHECKPOINT = {
	{ Vector( -1939, 1833, -2736 ), Vector( -1897, 2001, -2629 ) }
}

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )
	ply:Give( "weapon_frag" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "brush_doorAirlock_PClip_2" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ( ent:GetName() == "airlock_south_door_exit" ) || ( ent:GetName() == "airlock_south_door_exitb" ) ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "command_physcannon" ) && ( string.lower( input ) == "command" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:Give( "weapon_physcannon" )
		
		end
	
	end

	if GAMEMODE.EXMode then
		if ent:GetName() == "logic_disable_airlockB_1" and string.lower(input) == "enablerefire" then
			ents.FindByName("alyx")[1]:Ignite(5)
		end

		if ent:GetName() == "monitor_airlock_south" and string.lower(input) == "disable" then
			local e = EffectData()
			e:SetOrigin(ent:GetPos())
			for i=1,10 do
				util.Effect("Explosion", e)
			end

			timer.Simple(0, function()
				ent:Remove()
			end)
		end
	end

end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)

function HL2cEXPreventRollermineDamage(target, dmginfo)
	if dmginfo:GetAttacker():GetClass() == "npc_rollermine" and target:IsPlayer() then
		dmginfo:SetDamage(0)
	end
end
hook.Add("EntityTakeDamage", "HL2cEX_d1_eli_02_rollerminedoesnodamage", HL2cEXPreventRollermineDamage)


