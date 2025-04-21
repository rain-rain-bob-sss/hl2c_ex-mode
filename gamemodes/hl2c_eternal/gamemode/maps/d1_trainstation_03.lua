NEXT_MAP = "d1_trainstation_04"
GM.XP_REWARD_ON_MAP_COMPLETION = 1

TRIGGER_CHECKPOINT = {
	{ Vector( -4998, -4918, 512 ), Vector( -4978, -4699, 619 ) }
}

OVERRIDE_PLAYER_RESPAWNING = true
MAP_FORCE_CHANGELEVEL_ON_MAPRESTART = true

if CLIENT then return end


hook.Add( "PlayerReady", "hl2cPlayerReady", function(ply)
	if !GAMEMODE.EXMode then return end
	timer.Simple(1, function()
		ply:PrintMessage(3, "Fuck this map.")
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
	else
		game.SetGlobalState( "gordon_precriminal", GLOBAL_ON )
		game.SetGlobalState( "gordon_invulnerable", GLOBAL_ON )
	end

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "npc_breakincop3" )[ 1 ]:Remove()
		ents.FindByName( "ai_breakin_cop3goal3_blockplayer" )[ 1 ]:Remove()
		ents.FindByName( "ai_breakin_cop3goal3_blockplayer2" )[ 1 ]:Remove()
		ents.FindByName( "ai_breakin_cop3goal4_blockplayer" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_RaidRunner_1" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetPos( Vector( -3900, -4507, 385 ) )
			ply:SetEyeAngles( Angle( 0, -260, 0 ) )
		
		end
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_cit_blocker_holdem" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetPos( Vector( -5000, -4840, 513 ) )
			-- ply:SetPos( Vector( -4956, -4752, 513 ) )
			ply:SetEyeAngles( Angle( 0, -150, 0 ) )
		
		end
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

function hl2cEntityTakeDamage(ent, dmginfo)
	if !GAMEMODE.EXMode then return end
	local attacker = dmginfo:GetAttacker()
	local activewep = attacker:IsValid() and attacker:IsNPC() and attacker:GetActiveWeapon() or NULL
	if attacker:IsValid() and attacker:IsNPC() and activewep:IsValid() and activewep:GetClass() == "weapon_stunstick" then
		ent:SetHealth(0)
		dmginfo:SetDamage(9e9)

		local explosion = EffectData()
		explosion:SetOrigin(ent:GetPos())
		for i=1,3 do
			util.Effect("Explosion", explosion)
		end
	end
end
hook.Add("EntityTakeDamage", "hl2cEntityTakeDamage", hl2cEntityTakeDamage)
