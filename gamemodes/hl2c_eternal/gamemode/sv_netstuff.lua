


function GM:NetworkString_UpdateStats(ply)
    net.Start("hl2c_updatestats")
    net.WriteFloat(ply.Moneys)
    net.WriteFloat(ply.XP)
    net.WriteFloat(ply.Level)
    net.WriteFloat(ply.StatPoints)
    net.WriteFloat(ply.Prestige)
    net.WriteFloat(ply.PrestigePoints)
    net.WriteFloat(ply.Eternity)
    net.WriteFloat(ply.EternityPoints)
    net.WriteFloat(ply.Celestiality)
    net.WriteFloat(ply.CelestialityPoints)
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
    net.WriteFloat(ply.StatHeadShotMul or 0)
    net.Send(ply)
end

function GM:NetworkString_UpdatePerks(ply)
    net.Start("hl2ce_updateperks")
    net.WriteTable(ply.UnlockedPerks)
    net.Send(ply)
end

function GM:NetworkString_UpdateEternityUpgrades(ply)
    net.Start("hl2ce_updateeternityupgrades")
    net.WriteTable(ply.EternityUpgradeValues)
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
    local limit = ply:GetMaxSkillLevel(perk)

    count = math.min(count,curpoints)
    count = math.min(limit - (tonumber(ply[perk2]) or 0),count) 

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
    if ply.UnlockedPerks[name] then return end

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
    elseif prestige == "celestiality" then
        if not HL2CE_CELESTIALITY then
            ply:PrintMessage(3, "There is no such thing as Celestiality.")
            ply:PrintMessage(3, "Not. Yet. Implemented.")
        else
            ply:PrintMessage(3,"Celestiality is W.I.P\nYou will encounter issues.")
            ply:GainCelestiality()
        end
    end
end)

net.Receive("hl2ce_buyupgrade", function(len, ply)
    if not ply:HasEternityUnlocked() then return end
	local upg = net.ReadString()
	local buy = net.ReadString()

	local upgrade = GAMEMODE.UpgradesEternity[upg]
	if not upgrade then return end

    local old = ply.EternityUpgradeValues[upg]
    local function BuyUpgrade(ply, upg)
        local cost = ply:GetEternityUpgradeCost(upg)

		if ply.Moneys >= cost then
			ply.EternityUpgradeValues[upg] = ply.EternityUpgradeValues[upg] + 1
			ply.Moneys = ply.Moneys - cost
            return true
		end
        return false
    end

    if buy == "once" then
        local success = BuyUpgrade(ply, upg)
    elseif buy == "max" then
        for i=1,1000 do
            local success = BuyUpgrade(ply, upg)
            if not success then
                break
            end
        end
    end

    if old != ply.EternityUpgradeValues[upg] then
        PrintMessage(3, "Increased "..old.." -> "..ply.EternityUpgradeValues[upg])
    end

    GAMEMODE:NetworkString_UpdateEternityUpgrades(ply)
	
end)
