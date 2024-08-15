

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
		draw.DrawText("XP: "..math.floor(pl.XP).." / "..self:GetReqXP(pl), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add
		draw.DrawText("Level: "..math.floor(pl.Level), "TargetIDSmall", x, y, Color(255,255,255,alpha), TEXT_ALIGN_LEFT)
		y = y + y_add

		if pl:HasPrestigeUnlocked() then
			draw.DrawText("Prestige: "..math.floor(pl.Prestige), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			draw.DrawText("Prestige Points: "..math.floor(pl.PrestigePoints), "TargetIDSmall", x, y, Color(255,255,155,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
		end

		if pl:HasEternityUnlocked() then
			draw.DrawText("Eternities: "..math.floor(pl.Eternity), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
			y = y + y_add
			draw.DrawText("Eternity Points: "..math.floor(pl.EternityPoints), "TargetIDSmall", x, y, Color(155,155,255,alpha), TEXT_ALIGN_LEFT)
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
	local skills = vgui.Create("DButton", ContextMenu)
	skills:SetSize(buttonsize_x, buttonsize_y)
	skills:Center()
	local x,y = skills:GetPos()
	skills:SetPos(x, y + 220)
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

	local options = vgui.Create("DButton", ContextMenu)
	options:SetSize(buttonsize_x, buttonsize_y)
	options:Center()
	x,y = options:GetPos()
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


end

