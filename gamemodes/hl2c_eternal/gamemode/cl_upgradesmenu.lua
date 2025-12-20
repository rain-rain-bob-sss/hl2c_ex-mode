
function GM:UpgradesMenu()
	-- Yes.
	local ply = LocalPlayer()

	local w,h = 700,400
	if IsValid(upgradesvgui) then upgradesvgui:Remove() end
	upgradesvgui = vgui.Create("DFrame")
	upgradesvgui:SetSize(700, 400)
	upgradesvgui:Center()
	upgradesvgui:SetTitle("Progressive Eternity Upgrades - You will lose all of the eternity upgrades if you die or leave midgame.")
	upgradesvgui:SetDraggable(false)
	upgradesvgui:SetVisible(true)
	upgradesvgui:SetAlpha(0)
	upgradesvgui:AlphaTo(255, 1, 0)
	upgradesvgui:ShowCloseButton(true)
	upgradesvgui:MakePopup()
	upgradesvgui.Paint = function(this)
		draw.RoundedBox(2, 0, 0, this:GetWide(), this:GetTall(), Color(0, 0, 0, 200))
		surface.SetDrawColor(150, 150, 150,255)
		surface.DrawOutlinedRect(0, 0, this:GetWide(), this:GetTall())
	end
	upgradesvgui.Think = function(this)
		if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
			timer.Simple(0, function()
				this:Remove()
			end)
			gui.HideGameUI()
		end
	end


	local upgradeslist = vgui.Create("DPanelList", upgradesvgui)
	upgradeslist:SetSize(w - 50, h - 25)
	upgradeslist:SetPos(5, 25)
	upgradeslist:SetSpacing(10)
	upgradeslist:EnableVerticalScrollbar(true)
	upgradeslist:EnableHorizontal(true)

	local function MakeUpgrades()
		for k, v in pairs(self.UpgradesEternity) do

			local perkpanel = vgui.Create("DPanel")
			perkpanel:SetPos(5, 5)
	        local size_x,size_y = w-50, 150
			perkpanel:SetSize(size_x, size_y)
			perkpanel.Paint = function(panel) -- Paint function
				draw.RoundedBoxEx(8,1,1,panel:GetWide()-2,panel:GetTall()-2, Color(40, 40, 40, 25),
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
			local desc = string.format(isfunction(v.Description) and v.Description(LocalPlayer()) or v.Description,
			infmath.Round((LocalPlayer():GetEternityUpgradeEffectValue(k, 1) - 1) * 100))
			perkdesc:SetText(desc)

			perkdesc:SetToolTip(desc)
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
			perkcost:SetText(Format("Cost: %s", infmath.Round(LocalPlayer():GetEternityUpgradeCost(k), 2)))
	        perkcost:SetPos(10, 72)
			perkcost:SetSize(size_x - 20, 15)
			perkcost:SetWrap(true)
			perkcost:SetColor(Color(155,155,255,255))
			perkcost.Think = function(panel)
				local txt = Format("Cost: %s", infmath.Round(LocalPlayer():GetEternityUpgradeCost(k), 2))
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end

			local perkeffect = vgui.Create("DLabel", perkpanel)
			perkeffect:SetFont("TargetIDSmall")
			perkeffect:SetText(Format("Current effect: %s%%", infmath.Round(LocalPlayer():GetEternityUpgradeEffectValue(k)*100)))
	        perkeffect:SetPos(10, 90)
			perkeffect:SetSize(size_x - 20, 15)
			perkeffect:SetWrap(true)
			perkeffect:SetColor(Color(155,255,255,255))
			perkeffect.Think = function(panel)
				local txt = Format("Current effect: %s%%", infmath.Round(LocalPlayer():GetEternityUpgradeEffectValue(k)*100))
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end


			local buyupg_once = vgui.Create("DButton", perkpanel)
			buyupg_once:SetSize((size_x - 20) / 3, 30)
			buyupg_once:SetPos(10, size_y - 35)
			buyupg_once:SetText("Buy Once")
			buyupg_once.Think = function(panel)
				local txt = "Buy Once"
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end
			buyupg_once:SetTextColor(Color(255, 255, 255, 255))
			buyupg_once.Paint = function(panel)
				surface.SetDrawColor(0, 150, 0, 255)
				surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
				draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 50, 0, 130))
			end
			buyupg_once.DoClick = function(panel)
				net.Start("hl2ce_buyupgrade")
				net.WriteString(k)
				net.WriteString("once")
				net.SendToServer()
			end
			buyupg_once.DoDoubleClick = buyupg_once.DoClick

			local buyupg_max = vgui.Create("DButton", perkpanel)
			buyupg_max:SetSize(size_x/3 - 20, 30)
			buyupg_max:SetPos(10 + size_x/3, size_y - 35)
			buyupg_max:SetText("Buy Max")
			buyupg_max.Think = function(panel)
				local txt = "Buy Max"
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end
			buyupg_max:SetTextColor(Color(255, 255, 255, 255))
			buyupg_max.Paint = function(panel)
				surface.SetDrawColor(0, 150, 0, 255)
				surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
				draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 50, 0, 130))
			end
			buyupg_max.DoClick = function(panel)
				net.Start("hl2ce_buyupgrade")
				net.WriteString(k)
				net.WriteString("max")
				net.SendToServer()
			end

			local timesbought = vgui.Create("DLabel", perkpanel)
			timesbought:SetFont("TargetIDSmall")
			timesbought:SetText("Bought: "..LocalPlayer().EternityUpgradeValues[k])
			timesbought:SetSize(size_x/3 - 20, 30)
			timesbought:SetPos(10 + size_x*2/3, size_y - 35)
			timesbought:SetWrap(true)
			timesbought:SetColor(Color(255,155,255,255))
			timesbought.Think = function(panel)
				local txt = "Bought: "..LocalPlayer().EternityUpgradeValues[k]
				if panel:GetText() == txt then return end
				panel:SetText(txt)	
			end
			upgradeslist:AddItem(perkpanel)
		end
	end

	MakeUpgrades()


end
