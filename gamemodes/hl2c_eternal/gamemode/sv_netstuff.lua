


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
    net.WriteFloat(ply.StatSurgeon)
    net.WriteFloat(ply.StatVitality)
    net.WriteFloat(ply.StatKnowledge)
    net.Send(ply)
end

function GM:NetworkString_UpdatePerks(ply)
    net.Start("hl2ce_updateperks")
    net.WriteTable(ply.UnlockedPerks)
    net.Send(ply)
end

net.Receive("hl2c_updatestats", function(length, ply)
    local s1 = net.ReadString()
    if s1 == "reloadstats" then
        GAMEMODE:NetworkString_UpdateStats(ply)
        GAMEMODE:NetworkString_UpdateSkills(ply)
    	GAMEMODE:NetworkString_UpdatePerks(ply)
    end 
end)

net.Receive("UpgradePerk", function(length, ply)
	local perk = net.ReadString()
    local count = net.ReadUInt(32)
	local perk2 = "Stat"..perk

    local curpoints = ply.StatPoints
    local limit = ply:HasPrestigeUnlocked() and 35 or 20

    count = math.min(limit - ply[perk2], curpoints)

    if tonumber(ply.StatPoints) < 1 then
        ply:PrintMessage(HUD_PRINTTALK, "You need Skill Points to upgrade this skill!")
		return false
	end

    if tonumber(ply[perk2]) >= limit then
        ply:PrintMessage(HUD_PRINTTALK, "You have reached the max amount of points for this skill!")
		return false
	end

	ply[perk2] = ply[perk2] + count
	ply.StatPoints = ply.StatPoints - count
    ply:PrintMessage(HUD_PRINTTALK, "Increased "..perk.." by "..count.." point!")
    GAMEMODE:NetworkString_UpdateStats(ply)
    GAMEMODE:NetworkString_UpdateSkills(ply)
end)

net.Receive("hl2ce_unlockperk", function(len, ply)
    local name = net.ReadString()
    local perk = GAMEMODE.PerksData[name]
    if !perk then return end

    local cost = perk.Cost
    local prestigelvl = perk.PrestigeLevel
    local prestigetype = prestigelvl == 3 and "Celestiality" or prestigelvl == 2 and "Eternity" or prestigelvl == 1 and "Prestige"

    if ply[prestigetype] < perk.PrestigeReq then
        ply:PrintMessage(3, "Not enough "..prestigetype)
        return
    end

    if ply[prestigetype.."Points"] < cost then
        ply:PrintMessage(3, "Not enough "..prestigetype.." Points!")
        return
    end
    ply[prestigetype.."Points"] = ply[prestigetype.."Points"] - cost

    ply:PrintMessage(3, "Perk Unlocked: "..perk.Name)
    ply.UnlockedPerks[name] = true
    

    GAMEMODE:NetworkString_UpdateSkills(ply)
    GAMEMODE:NetworkString_UpdateStats(ply)
	GAMEMODE:NetworkString_UpdatePerks(ply)
end)

net.Receive("hl2ce_prestige", function(len, ply)
    local prestige = net.ReadString()

    if prestige == "prestige" then
        ply:GainPrestige()
    elseif prestige == "eternity" then
        ply:GainEternity()
    end
end)
