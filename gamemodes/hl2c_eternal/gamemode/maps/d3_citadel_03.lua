NEXT_MAP = "d3_citadel_04"
GM.XpGainOnNPCKillMul = 0.35
GM.DifficultyGainOnNPCKillMul = 0.5

RESET_WEAPONS = true

TRIGGER_CHECKPOINT = {
	{ Vector( 3175, 522, 2368 ), Vector( 3580, 562, 2529 ) }
}

if CLIENT then return end

-- Initialize entities
function hl2cMapEdit()

	game.ConsoleCommand( "physcannon_tracelength 850\n" )
	game.ConsoleCommand( "physcannon_maxmass 850\n" )
	game.ConsoleCommand( "physcannon_pullforce 8000\n" )

	ents.FindByName( "global_newgame_template_ammo" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_base_items" )[ 1 ]:Remove()
	ents.FindByName( "global_newgame_template_local_items" )[ 1 ]:Remove()

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )

	if ( ( ent:GetName() == "logic_weapon_strip_dissolve" ) && ( string.lower( input ) == "trigger" ) ) then
	
		if ( IsValid( ents.FindByName( "logic_weapon_strip_physcannon_start" )[ 1 ] ) ) then ents.FindByName( "logic_weapon_strip_physcannon_start" )[ 1 ]:Fire( "Trigger", "", 3 ); end
	
	end

	if ( ( ent:GetName() == "strip_stop" ) && ( string.lower( input ) == "trigger" ) ) then
	
		game.SetGlobalState("super_phys_gun", GLOBAL_ON)

		for _, ply in pairs( team.GetPlayers( TEAM_ALIVE ) ) do
		
			if ( IsValid( ply ) && ply:Alive() ) then
			
				ply:Give( "weapon_physcannon" )
			
			end
		
		end
	
	end

end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )


-- Every frame or tick
function hl2cThink()

	if game.GetGlobalState("super_phys_gun") == GLOBAL_ON then
	
		for _, ent in pairs( ents.FindByClass( "weapon_physcannon" ) ) do
		
			if ( IsValid( ent ) && ent:IsWeapon() ) then
			
				if ( ent:GetSkin() != 1 ) then ent:SetSkin( 1 ); end
			
			end
		
		end
	
		for _, ent in pairs( ents.FindByClass( "weapon_*" ) ) do
		
			if ( IsValid( ent ) && ent:IsWeapon() && ( ent:GetClass() != "weapon_physcannon" ) && ( !IsValid( ent:GetOwner() ) || ( IsValid( ent:GetOwner() ) && ent:GetOwner():IsPlayer() ) ) ) then
				if not ent.CanUseInCitadel then
					ent:Remove()
				end
			
			end
		
		end
	
	end

end
hook.Add( "Think", "hl2cThink", hl2cThink )
