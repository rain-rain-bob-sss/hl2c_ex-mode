
net.Receive("hl2c_updatestats", function(length)
    local ply = LocalPlayer()
    
    ply.Moneys = net.ReadFloat()
    ply.XP = net.ReadFloat()
    ply.Level = net.ReadFloat()
    ply.StatPoints = net.ReadFloat()
    ply.Prestige = net.ReadFloat()
    ply.PrestigePoints = net.ReadFloat()
    ply.Eternity = net.ReadFloat()
    ply.EternityPoints = net.ReadFloat()
    ply.Celestiality = net.ReadFloat()
    ply.CelestialityPoints = net.ReadFloat()
end)

net.Receive("UpdateSkills", function(length)
    local ply = LocalPlayer()

    ply.StatDefense = net.ReadFloat()
    ply.StatGunnery = net.ReadFloat()
    ply.StatMedical = net.ReadFloat()
    ply.StatSurgeon = net.ReadFloat()
    ply.StatVitality = net.ReadFloat()
    ply.StatKnowledge = net.ReadFloat()
end)

net.Receive("hl2ce_updateperks", function(length)
    local ply = LocalPlayer()

    ply.UnlockedPerks = net.ReadTable()
end)

net.Receive("hl2ce_updateeternityupgrades", function(length)
    local ply = LocalPlayer()

    ply.EternityUpgradeValues = net.ReadTable()
end)

XPGained = 0
XPGainedTotal = 0
XPColor = 0

net.Receive("XPGain", function(length)
	local xp = net.ReadFloat()

	XPGained = xp
    XPGainedTotal = XPGainedTotal + xp
	if XPGained != 0 then XPColor = 300 end
end)

net.Receive("hl2ce_finishedmap", function(length)
	local tbl = net.ReadTable()

    -- chat.AddText("Map completed")
    -- for k,v in pairs(tbl) do
    --     chat.AddText(k, " ", v)
    -- end
end)
