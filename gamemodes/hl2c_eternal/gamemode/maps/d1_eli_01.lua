NEXT_MAP = "d1_eli_02"
GM.XP_REWARD_ON_MAP_COMPLETION = 0

TRIGGER_CHECKPOINT = {
	{ Vector( 364, 1764, -2730 ), Vector( 549, 1787, -2575 ) }
}

TRIGGER_DELAYMAPLOAD = { Vector( -703, 989, -2688 ), Vector( -501, 1029, -2527 ) }

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
	
		ents.FindByName( "pclip_airlock_1_a" )[ 1 ]:Remove()
		ents.FindByName( "brush_exit_door_raven_PClip" )[ 1 ]:Remove()
		ents.FindByName( "pclip_exit_door_raven2" )[ 1 ]:Remove()
		ents.FindByName( "pclip_airlock_2_a" )[ 1 ]:Remove()
	
	end

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


local function SpawnNPC(class, pos, ang, func)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if func then
		func(ent)
	end
	ent:Spawn()

	return ent
end

-- Accept input
function hl2cAcceptInput( ent, input )

	if ( !game.SinglePlayer() && ( ( ent:GetName() == "doors_Airlock_Outside" ) || ( ent:GetName() == "inner_door" ) || ( ent:GetName() == "lab_exit_door_raven" ) || ( ent:GetName() == "lab_exit_door_raven2" ) || ( ent:GetName() == "airlock_south_door" ) || ( ent:GetName() == "airlock_south_doorb" ) ) && ( string.lower( input ) == "close" ) ) then
	
		return true
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "airlock_door" ) && ( string.lower( input ) == "open" ) ) then
	
		ents.FindByName( "doors_Airlock_Outside" )[ 1 ]:Fire( "Unlock" )
		ents.FindByName( "doors_Airlock_Outside" )[ 1 ]:Fire( "Open" )
	
	end

	if ( !game.SinglePlayer() && ( ent:GetName() == "lcs_mosstour05" ) && ( string.lower( input ) == "start" ) ) then
	
		for _, ply in pairs( player.GetAll() ) do
		
			ply:SetVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( 457, 1656, -1267 ) )
			ply:SetEyeAngles( Angle( 0, 90, 0 ) )
		
		end
	
	end

	if GAMEMODE.EXMode then
		if ent:GetName() == "logic_startScene" and string.lower(input) == "trigger" then
			timer.Simple(1.5, function()
				PrintMessage(3, "Chapter 5")
			end)
		end

		if ent:GetName() == "logic_Airlock_spriteSpotlights_On" and string.lower(input) == "trigger" then
			timer.Simple(1.15, function()
				PrintMessage(3, "We'll be under attack soon aren't we")
			end)
		end

		if ent:GetName() == "lcs_mosstour01" and string.lower(input) == "start" then
			for i=1,5 do
				SpawnNPC("npc_zombie", Vector(-28+(i-1)*32, 2350, -1280), Angle(0,90,0))
				SpawnNPC("npc_fastzombie", Vector(-28+(i-1)*32, 2400, -1280), Angle(0,90,0))
			end
		end
	end
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

hook.Add("EntityTakeDamage", "hl2cEntTakeDamage", function(ent, dmginfo)
	if string.lower(ent:GetName()) == "chester" then
		return true
	end
end)
