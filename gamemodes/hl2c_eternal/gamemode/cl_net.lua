
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
    ply.Celestiality = net.ReadInfNumber()
    ply.CelestialityPoints = net.ReadInfNumber()
end)

net.Receive("UpdateSkills", function(length)
    local ply = LocalPlayer()
    if !ply:IsValid() then return end

    ply.StatDefense = net.ReadFloat()
    ply.StatGunnery = net.ReadFloat()
    ply.StatMedical = net.ReadFloat()
    ply.StatSurgeon = net.ReadFloat()
    ply.StatVitality = net.ReadFloat()
    ply.StatKnowledge = net.ReadFloat()
    ply.StatHeadShotMul = net.ReadFloat()
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

net.Receive("hl2ce_fail", function(len)
    local time = math.min(10, RESTART_MAP_TIME)

    local s1 = "You lost!"
    local font = "hl2ce_font_big"
    local createtime = CurTime()

    surface.SetFont(font)
    local x,y = surface.GetTextSize(s1)

    local failtext = vgui.Create("DLabel")
    failtext:SetFont("hl2ce_font_big")
    failtext:SetTextColor(Color(255,0,0))
    failtext:SetSize(x, y)
    failtext:Center()
    failtext.Think = function(self)
        local str = string.sub(s1, 1, math.min(#s1, math.ceil((#s1*(CurTime()-createtime)/1.5))))
        if str == self:GetText() then return end
        self:SetText(str)
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    failtext:AlphaTo(0, 1, time, function(_, self)
        self:Remove()
    end)

    local s2 = net.ReadString()
    local font = "hl2ce_font"
    local createtime = CurTime()

    surface.SetFont(font)
    local x,y = surface.GetTextSize(s2)

    local failtext = vgui.Create("DLabel")
    failtext:SetFont("hl2ce_font")
    failtext:SetTextColor(Color(220,100,100))
    failtext:SetSize(x, y)
    failtext:Center()
    failtext:CenterVertical(0.65)

    failtext.Think = function(self)
        local str = string.sub(s2, 1, math.min(#s2, math.ceil((#s2*(CurTime()-createtime)/math.min(#s2/12, 4.5)))))
        if str == self:GetText() then return end
        self:SetText(str)
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    failtext:AlphaTo(0, 1, time, function(_, self)
        self:Remove()
    end)

    chat.AddText(Color(255,0,0), s1, " - ", Color(200,50,50), s2)
end)

net.Receive("hl2ce_playerkilled", function(len)
    chat.AddText("Killed by ", Color(255,0,0), language.GetPhrase(net.ReadString()))
end)

net.Receive("hl2ce_broadcastcslua", function(len)
    local csLua = net.ReadString()
    RunString(csLua)
end)