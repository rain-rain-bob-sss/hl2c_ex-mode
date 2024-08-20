


function GM:NetworkString_UpdateStats(ply)
    net.Start("hl2c_updatestats")
    net.WriteFloat(ply.XP)
    net.WriteFloat(ply.Level)
    net.WriteFloat(ply.StatPoints)
    net.WriteFloat(ply.Prestige)
    net.WriteFloat(ply.PrestigePoints)
    net.WriteFloat(ply.Eternity)
    net.WriteFloat(ply.EternityPoints)
    net.Send(ply)
end

function GM:NetworkString_UpdateSkills(ply)
    net.Start("UpdateSkills")
    net.WriteFloat(ply.StatDefense)
    net.WriteFloat(ply.StatGunnery)
    net.WriteFloat(ply.StatMedical)
    net.WriteFloat(ply.StatVitality)
    net.Send(ply)
end

net.Receive("hl2c_updatestats", function(length, client)
    local s1 = net.ReadString()
    if s1 == "reloadstats" then
        GAMEMODE:NetworkString_UpdateStats(client)
        GAMEMODE:NetworkString_UpdateSkills(client)
    end 
end)

net.Receive("UpgradePerk", function(length, client)
    local ply = client
	local perk = net.ReadString()
	local perk2 = "Stat"..perk
	if tonumber(ply.StatPoints) < 1 then
        ply:PrintMessage(HUD_PRINTTALK, "You need Skill Points to upgrade this skill!")
		return false
	end
	if tonumber(ply[perk2]) >= 10 then
        ply:PrintMessage(HUD_PRINTTALK, "You have reached the max amount of points for this skill!")
		return false
	end

	ply[perk2] = ply[perk2] + 1
	ply.StatPoints = ply.StatPoints - 1
    ply:PrintMessage(HUD_PRINTTALK, "Increased "..perk.." by 1 point!")
    GAMEMODE:NetworkString_UpdateStats(ply)
    GAMEMODE:NetworkString_UpdateSkills(ply)
end)
