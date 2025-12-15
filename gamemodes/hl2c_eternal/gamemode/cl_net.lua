
net.Receive("hl2c_updatestats", function(length)
    local ply = LocalPlayer()
    
    ply.Moneys = net.ReadInfNumber()
    ply.XP = net.ReadInfNumber()
    ply.Level = net.ReadInfNumber()
    ply.StatPoints = net.ReadInfNumber()
    ply.Prestige = net.ReadInfNumber()
    ply.PrestigePoints = net.ReadInfNumber()
    ply.Eternities = net.ReadInfNumber()
    ply.EternityPoints = net.ReadInfNumber()
    -- ply.Celestiality = net.ReadInfNumber()
    -- ply.CelestialityPoints = net.ReadInfNumber()
end)

net.Receive("UpdateSkills", function(length)
    local ply = LocalPlayer()
    if !ply:IsValid() then return end

    if !ply.Skills then ply.Skills = {} end
    table.Merge(ply.Skills, net.ReadTable() or {})
end)

net.Receive("hl2ce_updateperks", function(length)
    local ply = LocalPlayer()

    ply.UnlockedPerks = net.ReadTable()
end)

net.Receive("hl2ce_updateeternityupgrades", function(length)
    local ply = LocalPlayer()

    ply.EternityUpgradeValues = net.ReadTable()
end)

XPGained = InfNumber(0)
XPGainedTotal = InfNumber(0)
XPColor = 0

net.Receive("XPGain", function(length)
	local xp = net.ReadInfNumber()

	XPGained = xp
    XPGainedTotal = XPGainedTotal + xp
	if XPGained != 0 then XPColor = 300 end
end)

net.Receive("hl2ce_finishedmap", function(length)
	local tbl = net.ReadTable()


    gamemode.Call("OnMapCompleted")
    gamemode.Call("PostOnMapCompleted")
    -- chat.AddText("Map completed")
    -- for k,v in pairs(tbl) do
    --     chat.AddText(k, " ", v)
    -- end
end)

net.Receive("hl2ce_boss", function(len)
    GAMEMODE.EnemyBoss = net.ReadEntity()
end)
