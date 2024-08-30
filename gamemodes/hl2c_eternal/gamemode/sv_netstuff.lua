


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
    net.WriteFloat(ply.StatDefense or 0)
    net.WriteFloat(ply.StatGunnery or 0)
    net.WriteFloat(ply.StatMedical or 0)
    net.WriteFloat(ply.StatSurgeon or 0)
    net.WriteFloat(ply.StatVitality or 0)
    net.WriteFloat(ply.StatKnowledge or 0)
    net.WriteFloat(ply.StatBetterEngine or 0)
    net.Send(ply)
end

function GM:NetworkString_UpdatePerks(ply)
    net.Start("hl2ce_updateperks")
    net.WriteTable(ply.UnlockedPerks or {})
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

--uhh guys i forgot PrintTranslatedMessage exists
--just uhh
--UHHHHHHHHHHHHHHHH

net.Receive("UpgradePerk", function(length, ply)
	local perk = net.ReadString()
    local count = net.ReadUInt(32)
	local perk2 = "Stat"..perk
    if not GAMEMODE.SkillsInfo[perk] then return end
    local perkn=GAMEMODE.SkillsInfo[perk].Name
    local curpoints = ply.StatPoints
    local limit = ply:HasPrestigeUnlocked() and 35 or 20

    count = math.min(count,curpoints)
    count = math.min(limit - (tonumber(ply[perk2]) or 0),count) 

    if tonumber(ply.StatPoints) < 1 then
        ply:PrintMessage(HUD_PRINTTALK, translate.ClientGet(ply,"UP_NEEDSP"))
		return false
	end

    if (tonumber(ply[perk2]) or 0) >= limit then
        ply:PrintMessage(HUD_PRINTTALK, translate.ClientGet(ply,"UP_MAXED"))
		return false
	end

	ply[perk2] = (tonumber(ply[perk2]) or 0) + count
	ply.StatPoints = ply.StatPoints - count
    ply:PrintMessage(HUD_PRINTTALK, translate.ClientFormat(ply,"UP_INCREASED",perkn,count))
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
    local tprestigetype = prestigelvl == 3 and translate.Get("Celestiality") or prestigelvl == 2 and translate.Get("Eternity") or prestigelvl == 1 and translate.Get("PrestigeTxt")
    if not ply[prestigetype] then return end
    if ply[prestigetype] < perk.PrestigeReq then
        ply:PrintMessage(3, translate.ClientFormat(ply,"UP_NOTENOUGH",tprestigetype))
        return
    end

    if ply[prestigetype.."Points"] < cost then
        ply:PrintMessage(3, translate.ClientFormat(ply,"UP_NOTENOUGHPOINTS",tprestigetype))
        return
    end
    ply[prestigetype.."Points"] = ply[prestigetype.."Points"] - cost

    ply:PrintMessage(3, translate.ClientFormat(ply,"UP_UNLOCKPERK",perk.Name))
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
