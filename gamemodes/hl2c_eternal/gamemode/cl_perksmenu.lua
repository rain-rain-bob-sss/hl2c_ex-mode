

local dynprogress = 0
function GM:CMenu()
	local pl = LocalPlayer()
	local scw = ScrW()
	local sch = ScrH()

	ContextMenu = vgui.Create("DFrame")
	ContextMenu:SetSize(scw, sch)
	ContextMenu:Center()
	ContextMenu:SetTitle("")
	ContextMenu:SetDraggable(false)
	ContextMenu:SetVisible(true)
	ContextMenu:ShowCloseButton(true)
	ContextMenu.Paint = function(panel)
		local alpha = 125
		local x,y,y_add = 220,140,18
		local xp,reqxp = math.floor(pl.XP), self:GetReqXP(pl)
		draw.DrawText("Moneys: "..FormatNumber(pl.Moneys), "TargetIDSmall", x, y, Color(205,255,205,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("XP: "..FormatNumber(xp).." / "..FormatNumber(reqxp).." ("..math.Round(xp/reqxp * 100,2).."%)", "TargetIDSmall", x, y, xp>=reqxp and Color(105,255,105,alpha) or Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("Level: "..math.floor(pl.Level), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("Skill Points: "..math.floor(pl.StatPoints), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add

		if pl:HasPrestigeUnlocked() then
			draw.DrawText("Prestige: "..FormatNumber(math.floor(pl.Prestige)), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			draw.DrawText("Prestige Points: "..FormatNumber(math.floor(pl.PrestigePoints)), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
		end

		if pl:HasEternityUnlocked() then
			draw.DrawText("Eternities: "..FormatNumber(math.floor(pl.Eternity)), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			draw.DrawText("Eternity Points: "..FormatNumber(math.floor(pl.EternityPoints)), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
		end

		if pl:HasCelestialityUnlocked() then
			draw.DrawText("Celestialities: "..FormatNumber(math.floor(pl.Celestiality)), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			draw.DrawText("Celestiality Points: "..FormatNumber(math.floor(pl.CelestialityPoints)), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
		end

		y = y + y_add*2

		draw.DrawText("Min Damage Mul: "..FormatNumber(pl:GetMinDamageMul()).."x", "TargetIDSmall", x, y, Color(205,155,155,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("Max Damage Mul: "..FormatNumber(pl:GetMaxDamageMul()).."x", "TargetIDSmall", x, y, Color(155,205,155,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("Min Damage Resistance Mul: "..FormatNumber(pl:GetMinDamageResistanceMul()).."x", "TargetIDSmall", x, y, Color(205,155,155,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("Max Damage Resistance Mul: "..FormatNumber(pl:GetMaxDamageResistanceMul()).."x", "TargetIDSmall", x, y, Color(155,205,155,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
	end
	ContextMenu.Think = function()
	end
	ContextMenu:MakePopup()
	ContextMenu:SetKeyboardInputEnabled(false)

/*
	local ContextMenu2 = vgui.Create("DFrame", ContextMenu)
	ContextMenu2:SetSize(scw * 0.6, 30)
	ContextMenu2:SetPos(scw * 0.2, 70)
	ContextMenu2:SetTitle("")
	ContextMenu2:SetToolTip("Progress to Prestige")
	ContextMenu2:SetDraggable(false)
	ContextMenu2:ShowCloseButton(false)
	ContextMenu2.Paint = function(panel)
		surface.SetDrawColor(0, 0, 0, 105)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		surface.SetDrawColor(150, 150, 0, 105)
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())

		local progress = 0
		dynprogress = math.Approach(dynprogress, progress, math.Round((progress - dynprogress) * 0.04, 6))

		surface.SetDrawColor(50, 150, 150, 205)
		surface.DrawRect(0, 0, dynprogress * panel:GetWide(), panel:GetTall())

		draw.SimpleText(string.format("%s%%", math.Round(dynprogress * 100, 2)), "TargetID", dynprogress * panel:GetWide() * 0.5, panel:GetTall() * 0.5, Color(80, 255, 255, 205), dynprogress > 0.5 and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
*/


	local buttonsize_x, buttonsize_y = 120, 40
	local options = vgui.Create("DButton", ContextMenu)
	options:SetSize(buttonsize_x, buttonsize_y)
	options:Center()
	local x,y = options:GetPos()
	options:SetPos(x - 280, y - 220)
	options:SetText("Options")
	options:SetTextColor(Color(255,255,255))
	options.Paint = function(panel)
		surface.SetDrawColor(250, 150, 0, 255)
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
		draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
	end
	options.DoClick = function()
		gamemode.Call("MakeOptions")
		ContextMenu:Close()
	end

	local playermodel = vgui.Create("DButton", ContextMenu)
	playermodel:SetSize(buttonsize_x, buttonsize_y)
	playermodel:Center()
	x,y = playermodel:GetPos()
	playermodel:SetPos(x, y - 220)
	playermodel:SetText("Playermodels")
	playermodel:SetTextColor(Color(255,255,255))
	playermodel.Paint = function(panel)
		surface.SetDrawColor(250, 150, 0, 255)
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
		draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
	end
	playermodel.DoClick = function()
		hook.Call( "OpenPlayerModelMenu", GAMEMODE )
		ContextMenu:Close()
	end

	local refreshstats = vgui.Create("DButton", ContextMenu)
	refreshstats:SetSize(buttonsize_x, buttonsize_y)
	refreshstats:Center()
	x,y = refreshstats:GetPos()
	refreshstats:SetPos(x + 280, y - 220)
	refreshstats:SetText("Refresh stats")
	refreshstats:SetTextColor(Color(255,255,255))
	refreshstats.Paint = function(panel)
		surface.SetDrawColor(250, 150, 0, 255)
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
		draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
	end
	refreshstats.DoClick = function()
		net.Start("hl2c_updatestats")
		net.WriteString("reloadstats")
		net.SendToServer()

		ContextMenu:Close()
	end

	local prestigeunlocked = pl:HasPrestigeUnlocked()
	local eternityunlocked = pl:HasEternityUnlocked()

	local skills = vgui.Create("DButton", ContextMenu)
	skills:SetSize(buttonsize_x, buttonsize_y)
	skills:Center()
	x,y = skills:GetPos()
	skills:SetPos(x + (prestigeunlocked and -220 or -110), y + 220)
	skills:SetText("Skills")
	skills:SetTextColor(Color(255,255,255))
	skills.Paint = function(panel)
		surface.SetDrawColor(250, 150, 0, 255)
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
		draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
	end
	skills.DoClick = function()
		gamemode.Call("ShowSkills")
		ContextMenu:Close()
	end

	local prestige = vgui.Create("DButton", ContextMenu)
	prestige:SetSize(buttonsize_x, buttonsize_y)
	prestige:Center()
	x,y = prestige:GetPos()
	prestige:SetPos(x + (prestigeunlocked and 0 or 110), y + 220)
	prestige:SetText("Prestige")
	prestige:SetTextColor(Color(255,255,255))
	prestige.Paint = function(panel)
		surface.SetDrawColor(250, 150, 0, 255)
		surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
		draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
	end
	prestige.DoClick = function()
		gamemode.Call("MakePrestigePanel")
		ContextMenu:Close()
	end

	if prestigeunlocked then
		local perks = vgui.Create("DButton", ContextMenu)
		perks:SetSize(buttonsize_x, buttonsize_y)
		perks:Center()
		x,y = perks:GetPos()
		perks:SetPos(x + 220, y + 220)
		perks:SetText("Perks")
		perks:SetTextColor(Color(255,255,255))
		perks.Paint = function(panel)
			surface.SetDrawColor(250, 150, 0, 255)
			surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
			draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
		end
		perks.DoClick = function()
			gamemode.Call("PerksMenu")
			ContextMenu:Close()
		end
	end

	if false --[[prestigeunlocked]] then -- Not yet.
		local config = vgui.Create("DButton", ContextMenu)
		config:SetSize(buttonsize_x + 20, buttonsize_y)
		config:Center()
		x,y = config:GetPos()
		config:SetPos(x, y + 120)
		config:SetText("Player Configuration")
		config:SetTextColor(Color(255,255,255))
		config.Paint = function(panel)
			surface.SetDrawColor(50, 150, 200, 255)
			surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
			draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
		end
		config.DoClick = function()
			gamemode.Call("PlayerConfiguration")
			ContextMenu:Close()
		end
	end

	
	if eternityunlocked then
		local upgrades = vgui.Create("DButton", ContextMenu)
		upgrades:SetSize(buttonsize_x + 20, buttonsize_y)
		upgrades:Center()
		x,y = upgrades:GetPos()
		upgrades:SetPos(x, y + 300)
		upgrades:SetText("Upgrades")
		upgrades:SetToolTip("Upgrades (Unlocks permanently after reaching Eternity)\nYou lose these bought upgrades after dying or leaving midgame.")
		upgrades:SetTextColor(Color(255,255,255))
		upgrades.Paint = function(panel)
			surface.SetDrawColor(250, 50, 0, 255)
			surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
			draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 130))
		end
		upgrades.DoClick = function()
			gamemode.Call("UpgradesMenu")
			ContextMenu:Close()
		end
	end
	



end



local perksvgui
local perks_names = {
	{"Prestige", "prestige", function(ply) return ply.Prestige or 0 end, function(ply) return ply.PrestigePoints or 0 end},
	{"Eternity", "eternity", function(ply) return ply.Eternity or 0 end, function(ply) return ply.EternityPoints or 0 end},
	{"Celestiality", "celestiality", function(ply) return ply.Celestiality or 0 end, function(ply) return ply.CelestialityPoints or 0 end},
}


function GM:PerksMenu()
	-- Yes.
	local ply = LocalPlayer()

	if IsValid(perksvgui) then perksvgui:Remove() end
	perksvgui = vgui.Create("DFrame")
	perksvgui:SetSize(900, 660)
	perksvgui:Center()
	perksvgui:SetTitle("")
	perksvgui:SetDraggable(false)
	perksvgui:SetVisible(true)
	perksvgui:SetAlpha(0)
	perksvgui:AlphaTo(255, 1, 0)
	perksvgui:ShowCloseButton(true)
	perksvgui:MakePopup()
	perksvgui.Paint = function(this)
		draw.RoundedBox(2, 0, 0, this:GetWide(), this:GetTall(), Color(0, 0, 0, 200))
		surface.SetDrawColor(150, 150, 0,255)
		surface.DrawOutlinedRect(0, 0, this:GetWide(), this:GetTall())
	end
	perksvgui.Think = function(this)
		if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
			timer.Simple(0, function()
				this:Remove()
			end)
			gui.HideGameUI()
		end
	end

	local sheet = vgui.Create("DPropertySheet", perksvgui)
	sheet:SetPos(5, 25)
	sheet:SetSize(875, perksvgui:GetTall() - 35)
	sheet.Paint = function(panel)
		for k, v in pairs(panel.Items) do
			if (!v.Tab) then continue end
			v.Tab.Paint = function(this,w,h)
				draw.RoundedBox(0, 0, 0, w, h, Color(50,50,25))
			end
		end
	end
	sheet.Think = function(self)
		for k,v in pairs(self:GetItems()) do
			if v.Tab == self:GetActiveTab() then
				self.CurrentTab = v.Panel
				break
			end
		end
	end

	local perklist = vgui.Create("DPanelList")
	perklist:SetSize(850, perksvgui:GetTall() - 25)
	perklist:SetPos(5, 25)
	perklist:SetSpacing(10)
	perklist:EnableVerticalScrollbar(true)
	perklist:EnableHorizontal(true)
	perklist.Tier = 1

	local perklist2
	if ply:HasEternityUnlocked() then
		perklist2 = vgui.Create("DPanelList")
		perklist2:SetSize(850, perksvgui:GetTall() - 25)
		perklist2:SetPos(5, 25)
		perklist2:SetSpacing(10)
		perklist2:EnableVerticalScrollbar(true)
		perklist2:EnableHorizontal(true)
		perklist2.Tier = 2
	end

	local perklist3
	if ply:HasCelestialityUnlocked() then
		perklist3 = vgui.Create("DPanelList")
		perklist3:SetSize(850, perksvgui:GetTall() - 25)
		perklist3:SetPos(5, 25)
		perklist3:SetSpacing(10)
		perklist3:EnableVerticalScrollbar(true)
		perklist3:EnableHorizontal(true)
		perklist3.Tier = 3
	end

	local perklist4
	-- perklist4 = vgui.Create("DPanelList")
	-- perklist4:SetSize(850, perksvgui:GetTall() - 25)
	-- perklist4:SetPos(5, 25)
	-- perklist4:SetSpacing(10)
	-- perklist4:EnableVerticalScrollbar(true)
	-- perklist4:EnableHorizontal(true)


	local perkpoints = vgui.Create("DLabel", perksvgui)
	perkpoints:SetFont("TargetIDSmall")
	perkpoints:SetPos(10, 3)
	perkpoints:SetText("Prestige points: "..ply.PrestigePoints)
	perkpoints:SizeToContents()
	local x,y = perkpoints:GetSize()
	perkpoints:SetSize(math.min(x, 350), 25)
	perkpoints:SetColor(Color(255,255,255,255))
	-- perkpoints:SetMouseInputEnabled(true)
	-- perkpoints:SetToolTip("")
	perkpoints.Think = function(panel)
		local curtier = sheet.CurrentTab.Tier or 1
		local txt = perks_names[curtier][1].." points: "..perks_names[curtier][4](ply)
		if panel:GetText() == txt then return end
		panel:SetText(txt)
		perkpoints:SizeToContents()
		local x,y = perkpoints:GetSize()
		perkpoints:SetSize(math.min(x, 350), 25)
	end




	local function MakePerks(panel, prestige)
		for k, v in SortedPairsByMemberValue(self.PerksData, "PrestigeReq") do
			if prestige ~= v.PrestigeLevel then continue end

			local perkpanel = vgui.Create("DPanel")
			perkpanel:SetPos(5, 5)
	        local size_x,size_y = 810,150
			perkpanel:SetSize(size_x, size_y)
			perkpanel.Paint = function(panel) -- Paint function
				draw.RoundedBoxEx(8,1,1,panel:GetWide()-2,panel:GetTall()-2,
				ply:HasPerkUnlocked(k) and Color(40, 200, 40, 25) or v.PrestigeReq > perks_names[prestige][3](ply) and Color(75, 75, 75, 50) or Color(200, 40, 40, 25),
				false, false, false, false)
				surface.SetDrawColor(50, 50, 50, 255)
				surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
			end

			local perkname = vgui.Create("DLabel", perkpanel)
			perkname:SetFont("TargetID")
			perkname:SetPos(0, 10)
			perkname:SetText(v.Name)
			if v.GetTextColor then
				perkname:SetTextColor(v.GetTextColor())
			end
			perkname.Think = function(panel)
				if v.KeepUpdatingColor and v.GetTextColor then
					panel:SetTextColor(v.GetTextColor())
				end
			end
			perkname:SizeToContents()
	        local x,y = perkname:GetSize()
			perkname:SetSize(math.min(size_x - 20, x), y)
			perkname:CenterHorizontal()

			local perkdesc = vgui.Create("DLabel", perkpanel)
			perkdesc:SetFont("TargetIDSmall")
			perkdesc:SetPos(0, 35)
			perkdesc:SetText(self.EndlessMode and v.DescriptionEndless or v.Description)
			perkdesc:SetToolTip(v.Name.."\n\nIn Non-Endless Mode:\n"..v.Description..(v.DescriptionEndless and "\n\nIn Endless Mode:\n"..v.DescriptionEndless or ""))
			perkdesc:SetMouseInputEnabled(true)
			if v.AddDescription then
				perkdesc:SetTextColor(Color(255,255,255))
				perkdesc:SetToolTip(v.AddDescription)
			else
				perkdesc:SetTextColor(Color(155,155,155))
			end
			perkdesc:SizeToContents()
	        local x,y = perkdesc:GetSize()
			perkdesc:SetSize(math.min(size_x - 20, x), 35)
			perkdesc:SetWrap(true)
			perkdesc:CenterHorizontal()

			local perkcost = vgui.Create("DLabel", perkpanel)
			perkcost:SetFont("TargetIDSmall")
			perkcost:SetText("Points cost: "..v.Cost)
	        perkcost:SetPos(10, 72)
			perkcost:SetSize(size_x - 20, 15)
			perkcost:SetWrap(true)
			perkcost:SetColor(Color(155,155,255,255))

			local perkprestige = vgui.Create("DLabel", perkpanel)
			perkprestige:SetFont("TargetIDSmall")
			perkprestige:SetPos(10, 89)
			perkprestige:SetSize(size_x - 20, 15)
			perkprestige:SetText(perks_names[prestige][1].." needed: "..v.PrestigeReq)
			perkprestige:SetWrap(true)
			perkprestige:SetColor(Color(255,155,155,255))


			local perkapply = vgui.Create("DButton", perkpanel)
			perkapply:SetSize(size_x - 20, 30)
			perkapply:SetPos(10, size_y - 35)
			perkapply:SetText(ply:HasPerkUnlocked(k) and "Unlocked" or v.PrestigeReq > perks_names[prestige][3](ply) and "Not enough "..perks_names[prestige][2] or "Unlock")
			perkapply.Think = function(panel)
				local txt = ply:HasPerkUnlocked(k) and "Unlocked" or v.PrestigeReq > perks_names[prestige][3](ply) and "Not enough "..perks_names[prestige][2] or "Unlock"
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end
			perkapply:SetTextColor(Color(255, 255, 255, 255))
			perkapply.Paint = function(panel)
				surface.SetDrawColor(0, 150, 0, 255)
				surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
				draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), v.PrestigeReq > perks_names[prestige][3](ply) and Color(75, 75, 75, 130) or Color(0, 50, 0, 130))
			end
			perkapply.DoClick = function(panel)
				net.Start("hl2ce_unlockperk")
				net.WriteString(k)
				net.SendToServer()
			end
			panel:AddItem(perkpanel)
		end
	end

	MakePerks(perklist, 1)
	if ply:HasEternityUnlocked() then
		MakePerks(perklist2, 2)
	end
	if ply:HasCelestialityUnlocked() then
		MakePerks(perklist3, 3)
	end
	-- if ply:HasEternityUnlocked() then
		-- MakePerks(perklist4, 4)
	-- end



	sheet:AddSheet("Prestige", perklist, "icon16/star.png", false, false, "Prestige Perks to give you more advantage")
	if ply:HasEternityUnlocked() then
		sheet:AddSheet("Eternity", perklist2, "icon16/star.png", false, false, "Eternity Perks. They are far more powerful.")
	end
	if ply:HasCelestialityUnlocked() then
		sheet:AddSheet("Celestiality", perklist3, "icon16/star.png", false, false, "Celestiality Perks")
	end
	-- if ply:HasEternityUnlocked() then
		-- sheet:AddSheet("Rebirth", perklist4, "icon16/star.png", false, false, "")
	-- end
end

function GM:MakePrestigePanel()
	if IsValid(self.PrestigePanel) then self.PrestigePanel:Remove() end

	local pl = LocalPlayer()
	local wide,tall = 920,660
	self.PrestigePanel = vgui.Create( "DFrame" )
	self.PrestigePanel:SetSize(wide, tall)
	self.PrestigePanel:Center()
	self.PrestigePanel:SetTitle("")
	self.PrestigePanel:SetDraggable(false)
	self.PrestigePanel:SetVisible(true)
	self.PrestigePanel:SetAlpha(0)
	self.PrestigePanel:AlphaTo(255, 0.45, 0)
	self.PrestigePanel:ShowCloseButton(true)
	self.PrestigePanel:MakePopup()
	self.PrestigePanel.Paint = function(this, w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0, 200))
		surface.SetDrawColor(150, 50, 0, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local list = vgui.Create("DPanelList", self.PrestigePanel)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSize(wide - 20, tall - 40)
	list:SetPos(12, 32)
	list:SetPadding(8)
	list:SetSpacing(4)

	local function MakeText(panel, text, font, color)
		local txt = EasyLabel(panel, text, font, color or Color(205,205,205))
		return txt
	end

	local function MakeButton(text, xpadding, ypadding, func, color)
		local button = EasyButton(nil, text, xpadding, ypadding)
		button:SetFont("TargetID")
		button:SetTextColor(Color(205,205,205))
		button:SetSize(0,30)
		button.Paint = function(this,w,h)
			surface.SetDrawColor(color)
			surface.DrawRect(0, 0, w, h)
		end
		button.DoClick = func
		return button
	end

	list:AddItem(MakeButton("Prestige", 0, 0, function()
		if !pl:HasPrestigeUnlocked() then
			self.PrestigePanel:Remove()
		end

		net.Start("hl2ce_prestige")
		net.WriteString("prestige")
		net.SendToServer()
	end, Color(150, 50, 0, 200)))
	list:AddItem(MakeText(self.PrestigePanel, "Prestige will reset all your levels, XP and skills, but you will gain +20% boost to xp gain (every prestige) and a perk point.\nPrestigin will also unlock new perks after time.", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "You must reach Level "..MAX_LEVEL.." and reach max XP for the next level in order to prestige.", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Prestiging for the first time will permanently increase skill points gain to 2 per level and will increase skills max level to 35.", "TargetIDSmall"))

	if !pl:HasPrestigeUnlocked() then return end
	list:AddItem(MakeButton("Eternity", 0, 0, function()
		if !pl:HasEternityUnlocked() then
			self.PrestigePanel:Remove()
		end

		net.Start("hl2ce_prestige")
		net.WriteString("eternity")
		net.SendToServer()
	end, Color(50, 150, 200, 200)))
	list:AddItem(MakeText(self.PrestigePanel, "Eternity to reset your levels, XP, skills, prestiges and prestige perks, but you gain a +120% boost to xp gain (every eternity) and\nEternity point. Eternity perks are more powerful than regular perks.", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Must be able prestige with the exception of prestige limit or be above "..MAX_PRESTIGE.." prestiges in order to Eternity", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Upon eternity you are given lots of buffs. (TO BE IMPLEMENTED)", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "", "TargetIDSmall"))

	list:AddItem(MakeButton("Celestiality", 0, 0, function()
		if !pl:HasEternityUnlocked() then
			self.PrestigePanel:Remove()
		end

		net.Start("hl2ce_prestige")
		net.WriteString("celestiality")
		net.SendToServer()
	end, Color(50, 150, 200, 200)))
	list:AddItem(MakeText(self.PrestigePanel, "Celestiality will reset pre-Celestiality progress.", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Must be able to prestige (Exception: Prestige limit) and reach "..MAX_ETERNITIES.." Eternities", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "", "TargetIDSmall"))

end
