INFO_PLAYER_SPAWN = { Vector( -9961, -3668, 330 ), 90 }

NEXT_MAP = "d1_canals_01"

if CLIENT then return end
local disable_delayed_explode = false

-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "player_spawn_items_template" )[ 1 ]:Remove()

	if ( !game.SinglePlayer() ) then
	
		ents.FindByName( "scriptcond_seebarney" )[ 1 ]:Remove()
	
		-- Create a trigger to replace script conditions
		local condition_trigger = ents.Create( "trigger_once" )
		condition_trigger:SetPos( Vector( -9727, -3391, 390 ) )
		condition_trigger:SetAngles( Angle( 0, 0, 0 ) )
		condition_trigger:SetModel( "*71" )
		condition_trigger:SetKeyValue( "spawnflags", "1" )
		condition_trigger:SetKeyValue( "StartDisabled", "1" )
		condition_trigger:SetKeyValue( "targetname", "scriptCond_seeBarney" )
		condition_trigger:SetKeyValue( "OnTrigger", "scriptCond_seeBarney,Disable,,0.1,-1" )
		condition_trigger:SetKeyValue( "OnTrigger", "lcs_crowbar_intro,Resume,,0.5,-1" )
		condition_trigger:SetKeyValue( "OnTrigger", "lcs_ba_heyGordon,Kill,,3.5,-1" )
		condition_trigger:SetKeyValue( "OnTrigger", "timer_heyGordon,Disable,,0,-1" )
		condition_trigger:SetKeyValue( "OnTrigger", "timer_heyGordon,Kill,,0.1,-1" )
		condition_trigger:SetKeyValue( "OnTrigger", "logic_citadel_scanners_1,Trigger,,0,-1" )
		condition_trigger:SetKeyValue( "OnTrigger", "citadel,SetAnimation,open,1.7,-1" )
		condition_trigger:Spawn()
		condition_trigger:Activate()
	
	end

	disable_delayed_explode = false
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )

function hl2cAcceptInput(ent, input)
	if GAMEMODE.EXMode then
		if ent:GetName() == "spawner_crowbar" and string.lower(input) == "forcespawn" then
			ents.FindByName("spawner_crowbar")[1]:Fire("forcespawn", nil, 0.05)

			if disable_delayed_explode then return end
			disable_delayed_explode = true
			
			local entity = ents.FindByClass("npc_barney")[1]
			timer.Simple(4, function()
				if !entity or !entity:IsValid() then return end
	
				local GL_NPCS = GODLIKE_NPCS
				if table.HasValue(GODLIKE_NPCS, "npc_barney") then
					table.RemoveByValue(GODLIKE_NPCS, "npc_barney")
				end

				entity:SetHealth(0)
	
				for i=1,30 do
					local exp = ents.Create("env_explosion")
					exp:SetPos(entity:GetPos())
					exp:SetKeyValue("iMagnitude", "60")
					exp:Spawn()
					exp:Fire("explode")
				end
	
				GODLIKE_NPCS = GL_NPCS

				ents.FindByName("spawner_crowbar")[1]:Fire("kill")
			end)
		end

		if ent:GetName() == "crowbar_music" then
			-- BroadcastLua([[LocalPlayer():EmitSound("*#music/hl1_song3.mp3", 0, 100)]]) -- bruh hl1 intro song instead of hl2 intro one? yes, what did you expect
			-- return true
		end
	end
end
hook.Add("AcceptInput", "hl2cAcceptInput", hl2cAcceptInput)
