-- NOT. EVEN. FINISHED.
NEXT_MAP = "d1_trainstation_01"

FORCE_RESTART_COUNT = 2

-- MAP_FORCE_CHANGELEVEL_ON_MAPRESTART = true

if CLIENT then return end

-- Player spawns
function hl2cPlayerSpawn( ply )
	ply:Give("weapon_physcannon")
	ply:Give("weapon_pistol")
	ply:Give("weapon_shotgun")
	ply:Give("weapon_smg1")
	ply:Give("weapon_ar2")
end
hook.Add( "PlayerSpawn", "hl2cPlayerSpawn", hl2cPlayerSpawn )

function hl2cPlayerInitialSpawn(ply)
end
hook.Add( "PlayerInitialSpawn", "hl2cPlayerInitialSpawn", hl2cPlayerInitialSpawn )


-- Initialize entities
function hl2cMapEdit()
end
hook.Add( "MapEdit", "hl2cMapEdit", hl2cMapEdit )


-- Accept input
function hl2cAcceptInput( ent, input )
    if ent:GetName() == "lcs_al_leavingOnTrain" and string.lower(input) == "start" then
        BroadcastLua([[surface.PlaySound("music/vlvx_song3.mp3")]]) -- Hl2 overcharged moment?
    end

    if ent:GetName() == "credits" and string.lower(input) == "rolloutrocredits" then
        -- gamemode.Call()
        hook.Call( "NextMap", GAMEMODE )
		for _,ply in pairs(player.GetAll()) do
			gamemode.Call("PlayerCompletedCampaign", ply)
		end
    end
end
hook.Add( "AcceptInput", "hl2cAcceptInput", hl2cAcceptInput )

hook.Add("OnMapCompleted", "hl2ceOnMapCompleted", function()
end)


