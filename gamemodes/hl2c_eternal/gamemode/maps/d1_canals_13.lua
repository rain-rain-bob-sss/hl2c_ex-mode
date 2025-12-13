ALLOWED_VEHICLE = "Airboat Gun"

NEXT_MAP = "d1_eli_01"

TRIGGER_DELAYMAPLOAD = { Vector( -762, -3866, -392 ), Vector( -518, -3845, -231 ) }

local bossfight

if CLIENT then
	net.Receive("d1_canals_13.playmusic", function()
		local bool = net.ReadBool()
		local sound = "#*hl2c_eternal/music/chopper_fight.wav"
		local ply = LocalPlayer()

		if bool then
			ply:EmitSound(sound, 0, 100, 1, CHAN_STATIC, SND_DELAY, 0)
		else
			ply:EmitSound(sound, 0, 100, 1, CHAN_STATIC, SND_DELAY + SND_STOP, 0)
		end
	end)

	return
end

util.AddNetworkString("d1_canals_13.playmusic")

local activated = true
local sk_helicopter_health = GetConVar("sk_helicopter_health")

-- Player spawns
function hl2cPlayerSpawn( ply )

	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_357" )

end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )


-- Initialize entities
function hl2cMapEdit()

	ents.FindByName( "global_newgame_template" )[ 1 ]:Remove()
	bossfight = false

end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


hook.Add("PlayerReady", "d1_canals_13.playmusic", function(pl)
	if bossfight then
		net.Start("d1_canals_13.playmusic")
		net.WriteBool(true)
		net.Broadcast()
	end
end)

hook.Add("AcceptInput", "hl2cAcceptInput", function(ent, input)
	if !GAMEMODE.EXMode then return end
	if ent:GetName() == "canals_npc_reservoircopter01" and string.lower(input) == "activate" then
		PrintMessage(3, ">>> OH SHIT HELICOPTER HAS BEEN ACTIVATED SHOOT IT DOWN <<<")

		local hpmul = 0.6 + #player.GetAll()*0.4
		if hpmul == 1 then
			ent:SetHealth(ent:Health() * hpmul)
			ent:SetMaxHealth(ent:Health() * hpmul)
		end

		bossfight = true
		net.Start("d1_canals_13.playmusic")
		net.WriteBool(true)
		net.Broadcast()
	end

	if ent:GetName() == "relay_achievement_heli_1" and string.lower(input) == "trigger" then
		net.Start("d1_canals_13.playmusic")
		net.WriteBool(false)
		net.Broadcast()
		bossfight = false

		for _,ply in pairs(player.GetAll()) do
			ply:GiveXP(369)
		end

		print("heli died yipee")
	end

	if !bossfight then
		if ent:GetName() == "gate3_wheel" and input:lower() == "use" then
			ents.FindByName("door_lock2_2")[1]:Fire("setposition", 1)
			return true
		end
	end
end)
