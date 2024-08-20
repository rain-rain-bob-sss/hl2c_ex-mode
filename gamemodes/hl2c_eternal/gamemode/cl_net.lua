
net.Receive("hl2c_updatestats", function(length)
    local pl = LocalPlayer()
    
    pl.XP = net.ReadFloat()
    pl.Level = net.ReadFloat()
    pl.StatPoints = net.ReadFloat()
    pl.Prestige = net.ReadFloat()
    pl.PrestigePoints = net.ReadFloat()
    pl.Eternity = net.ReadFloat()
    pl.EternityPoints = net.ReadFloat()
end)

net.Receive("UpdateSkills", function(length)
    local s1 = net.ReadFloat()
    local s2 = net.ReadFloat()
    local s3 = net.ReadFloat()
    local s4 = net.ReadFloat()

    local pl = LocalPlayer()
    pl.StatDefense = s1
    pl.StatGunnery = s2
    pl.StatMedical = s3
    pl.StatVitality = s4
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
