
difficulty = 0

myxp = 0
mylvl = 0
myskillpts = 0

Perks = {}

Perks.Defense = 0
Perks.Gunnery = 0
Perks.Medical = 0
Perks.Vitality = 0

net.Receive("UpdateStats", function(length)
    local s1 = net.ReadFloat()
    local s2 = net.ReadFloat()
    local s3 = net.ReadFloat()
    
    myxp = s1
    mylvl = s2
    myskillpts = s3
end)

net.Receive("UpdateSkills", function(length)
    local s1 = net.ReadFloat()
    local s2 = net.ReadFloat()
    local s3 = net.ReadFloat()
    local s4 = net.ReadFloat()
    
    Perks.Defense = s1
    Perks.Gunnery = s2
    Perks.Medical = s3
    Perks.Vitality = s4
end)

net.Receive("updateDifficulty", function(length)
    local s1 = net.ReadFloat()
    
    difficulty = s1
end)

XPGained = 0
XPColor = 0

net.Receive("XPGain", function(length)
	local xp = net.ReadFloat()

	XPGained = xp
	if XPGained != 0 then XPColor = 255 end
end)
