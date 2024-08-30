

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
	local t=SysTime()
	ContextMenu.Paint = function(panel,w,h)
		Derma_DrawBackgroundBlur(panel,t)
		draw.RoundedBox(3,0,0,w,h,Color(0,0,0,125))
		local alpha = 125
		local x,y,y_add = 220,140,18
		local xp,reqxp = math.floor(pl.XP), self:GetReqXP(pl)
		--draw.DrawText("XP: "..FormatNumber(xp).." / "..FormatNumber(reqxp).." ("..math.Round(xp/reqxp * 100,2).."%)", "TargetIDSmall", x, y, xp>=reqxp and Color(105,255,105,alpha) or Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		draw.DrawText(translate.Format("XP",tostring(FormatNumber(xp)),tostring(FormatNumber(reqxp)),tostring(math.Round(xp/reqxp * 100,2))), "TargetIDSmall", x, y, xp>=reqxp and Color(105,255,105,alpha) or Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		--draw.DrawText("Level: "..math.floor(pl.Level), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		draw.DrawText(translate.Format("Level",tostring(math.floor(pl.Level))), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		--draw.DrawText("Skill Points: "..math.floor(pl.StatPoints), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		draw.DrawText(translate.Format("SPs",tostring(math.floor(pl.StatPoints))), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add

		if pl:HasPrestigeUnlocked() then
			--draw.DrawText("Prestige: "..FormatNumber(math.floor(pl.Prestige)), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			draw.DrawText(translate.Format("Prestige",tostring(FormatNumber(math.floor(pl.Prestige)))), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			--draw.DrawText("Prestige Points: "..FormatNumber(math.floor(pl.PrestigePoints)), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			draw.DrawText(translate.Format("PrestigePoints",tostring(FormatNumber(math.floor(pl.PrestigePoints)))), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
		end

		if pl:HasEternityUnlocked() then
			--draw.DrawText("Eternities: "..FormatNumber(math.floor(pl.Eternity)), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			draw.DrawText(translate.Format("Eternities",tostring(FormatNumber(math.floor(pl.Eternity)))), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			--draw.DrawText("Eternity Points: "..FormatNumber(math.floor(pl.EternityPoints)), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			draw.DrawText(translate.Format("EternityPoints",tostring(FormatNumber(math.floor(pl.EternityPoints)))), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
		end
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
	local DoHover=function(pnl)
		local lasthover=false
		function pnl:Think()
			if self:IsHovered() then
				if lasthover~=true then
					LocalPlayer():EmitSound("npc/headcrab_poison/ph_step1.wav",100,75,1,CHAN_STATIC)
					--surface.PlaySound("npc/headcrab_poison/ph_step1.wav")
					lasthover=true
				end
			else
				if lasthover==true then
					LocalPlayer():EmitSound("weapons/iceaxe/iceaxe_swing1.wav",100,145,1,CHAN_STATIC)
					lasthover=false
				end
			end
		end
	end
	local options = vgui.Create("DButton", ContextMenu)
	options:SetSize(buttonsize_x, buttonsize_y)
	options:Center()
	local x,y = options:GetPos()
	options:SetPos(x - 280, y - 220)
	options:SetText(translate.Get("Options"))
	options:SetTextColor(Color(255,255,255))
	DoHover(options)
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
	playermodel:SetText(translate.Get("Playermodels"))
	playermodel:SetTextColor(Color(255,255,255))
	DoHover(playermodel)
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
	refreshstats:SetText(translate.Get("Refreshstats"))
	refreshstats:SetTextColor(Color(255,255,255))
	DoHover(refreshstats)
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

	local skills = vgui.Create("DButton", ContextMenu)
	skills:SetSize(buttonsize_x, buttonsize_y)
	skills:Center()
	x,y = skills:GetPos()
	skills:SetPos(x + (prestigeunlocked and -220 or -110), y + 220)
	skills:SetText(translate.Get("Skills"))
	skills:SetTextColor(Color(255,255,255))
	DoHover(skills)
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
	prestige:SetText(translate.Get("PrestigeTxt"))
	prestige:SetTextColor(Color(255,255,255))
	DoHover(prestige)
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
		perks:SetText(translate.Get("Perks"))
		perks:SetTextColor(Color(255,255,255))
		DoHover(perks)
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



end



local perksvgui

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

	local perklist = vgui.Create("DPanelList")
	perklist:SetSize(850, perksvgui:GetTall() - 25)
	perklist:SetPos(5, 25)
	perklist:SetSpacing(10)
	perklist:EnableVerticalScrollbar(true)
	perklist:EnableHorizontal(true)

	local perklist2
	if ply:HasEternityUnlocked() then
		perklist2 = vgui.Create("DPanelList")
		perklist2:SetSize(850, perksvgui:GetTall() - 25)
		perklist2:SetPos(5, 25)
		perklist2:SetSpacing(10)
		perklist2:EnableVerticalScrollbar(true)
		perklist2:EnableHorizontal(true)
	end

	local perklist3
	if ply:HasCelestialityUnlocked() then
		perklist3 = vgui.Create("DPanelList")
		perklist3:SetSize(850, perksvgui:GetTall() - 25)
		perklist3:SetPos(5, 25)
		perklist3:SetSpacing(10)
		perklist3:EnableVerticalScrollbar(true)
		perklist3:EnableHorizontal(true)
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
	perkpoints:SetText(translate.Format("PrestigePoints",tostring(FormatNumber(math.floor(ply.PrestigePoints)))))
	perkpoints:SizeToContents()
	local x,y = perkpoints:GetSize()
	perkpoints:SetSize(math.min(x, 350), 25)
	perkpoints:SetColor(Color(255,255,255,255))
	-- perkpoints:SetMouseInputEnabled(true)
	-- perkpoints:SetToolTip("")
	perkpoints.Think = function(panel)
		local txt = translate.Format("PrestigePoints",tostring(FormatNumber(math.floor(ply.PrestigePoints))))
		if panel:GetText() == txt then return end
		panel:SetText(txt)
		perkpoints:SizeToContents()
		local x,y = perkpoints:GetSize()
		perkpoints:SetSize(math.min(x, 350), 25)
	end




	--------------------------------------------supplies-------------------------------------------------------------
	
/*
	local hoverdesc = vgui.Create("DLabel", perksvgui)
	hoverdesc:SetFont("TargetIDSmall")
	hoverdesc:SetPos(150, 0)
	hoverdesc:SetText("")
	hoverdesc:SizeToContents()
	local x,y = hoverdesc:GetSize()
	hoverdesc:SetSize(810, 30)
*/

	local function MakePerks(panel, prestige)
		for k, v in SortedPairsByMemberValue(GAMEMODE.PerksData, "PrestigeReq") do
			if prestige ~= v.PrestigeLevel then continue end

			local function GetPrestige(ply)
				return prestige == 3 and ply.Celestiality or prestige == 2 and ply.Eternity or ply.Prestige
			end

			local perkpanel = vgui.Create("DPanel")
			perkpanel:SetPos(5, 5)
	        local size_x,size_y = 810,150
			perkpanel:SetSize(size_x, size_y)
			perkpanel.Paint = function(panel) -- Paint function
				draw.RoundedBoxEx(8,1,1,panel:GetWide()-2,panel:GetTall()-2,
				ply:HasPerkUnlocked(k) and Color(40, 200, 40, 25) or v.PrestigeReq > GetPrestige(ply) and Color(75, 75, 75, 50) or Color(200, 40, 40, 25),
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
			--perkdesc:SetToolTip(v.Name.."\n\nIn Non-Endless Mode:\n"..v.Description..(v.DescriptionEndless and "\n\nIn Endless Mode:\n"..v.DescriptionEndless or ""))
			perkdesc:SetToolTip(v.Name..translate.Get("NonEndlessDesc")..v.Description..(v.DescriptionEndless and translate.Get("EndlessDesc")..v.DescriptionEndless or ""))
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
			--perkcost:SetText("Points cost: "..v.Cost)
			perkcost:SetText(translate.Format("PointsCost",tostring(v.Cost)))
	        perkcost:SetPos(10, 72)
			perkcost:SetSize(size_x - 20, 15)
			perkcost:SetWrap(true)
			perkcost:SetColor(Color(155,155,255,255))

			local perkprestige = vgui.Create("DLabel", perkpanel)
			perkprestige:SetFont("TargetIDSmall")
			perkprestige:SetPos(10, 89)
			perkprestige:SetSize(size_x - 20, 15)
			--perkprestige:SetText("Prestige need: "..v.PrestigeReq)
			perkprestige:SetText(translate.Format("PrestigeCost",tostring(v.PrestigeReq)))
			perkprestige:SetWrap(true)
			perkprestige:SetColor(Color(255,155,155,255))


			local perkapply = vgui.Create("DButton", perkpanel)
			perkapply:SetSize(size_x - 20, 30)
			perkapply:SetPos(10, size_y - 35)
			perkapply:SetText(ply:HasPerkUnlocked(k) and translate.Get("Unlock") or v.PrestigeReq > GetPrestige(ply) and translate.Get("PrestigeNotEnough") or translate.Get("Unlock"))
			perkapply.Think = function(panel)
				local txt = ply:HasPerkUnlocked(k) and translate.Get("Unlock") or v.PrestigeReq > GetPrestige(ply) and translate.Get("PrestigeNotEnough") or translate.Get("Unlock")
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end
			perkapply:SetTextColor(Color(255, 255, 255, 255))
			perkapply.Paint = function(panel)
				surface.SetDrawColor(0, 150, 0, 255)
				surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
				draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), v.PrestigeReq > GetPrestige(ply) and Color(75, 75, 75, 130) or Color(0, 50, 0, 130))
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



	sheet:AddSheet(translate.Get("PrestigeTxt"), perklist, "icon16/star.png", false, false, translate.Get("PrestigePerkDesc"))
	if ply:HasEternityUnlocked() then
		sheet:AddSheet(translate.Get("Eternity"), perklist2, "icon16/star.png", false, false, translate.Get("EternityPerkDesc"))
	end
	if ply:HasCelestialityUnlocked() then
		sheet:AddSheet(translate.Get("Celestiality"), perklist3, "icon16/star.png", false, false, translate.Get("CelestialityPerkDesc"))
	end
	-- if ply:HasEternityUnlocked() then
		-- sheet:AddSheet("Rebirth", perklist4, "icon16/star.png", false, false, "")
	-- end
end

function GM:MakePrestigePanel()
	if IsValid(self.PrestigePanel) then self.PrestigePanel:Remove() end

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

	local function MakeButton(text, xpadding, ypadding, func)
		local button = EasyButton(nil, text, xpadding, ypadding)
		button:SetFont("TargetID")
		button:SetTextColor(Color(205,205,205))
		button:SetSize(0,30)
		button.Paint = function(this,w,h)
			surface.SetDrawColor(150, 50, 0, 200)
			surface.DrawRect(0, 0, w, h)
		end
		button.DoClick = func
		return button
	end

	list:AddItem(MakeButton("Prestige", 0, 0, function()
		net.Start("hl2ce_prestige")
		net.WriteString("prestige")
		net.SendToServer()
	end))
	list:AddItem(MakeText(self.PrestigePanel, translate.Get("prestige_text1"), "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, translate.Format("prestige_text2",tostring(MAX_LEVEL)), "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, translate.Get("prestige_text3"), "TargetIDSmall"))

	list:AddItem(MakeButton("Eternity", 0, 0, function()
		net.Start("hl2ce_prestige")
		net.WriteString("eternity")
		net.SendToServer()
	end))
	list:AddItem(MakeText(self.PrestigePanel, translate.Get("eternity_text1"), "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, translate.Format("eternity_text2",MAX_LEVEL,MAX_PRESTIGE), "TargetIDSmall"))

end
