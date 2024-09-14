GM.ConfigData = GM.ConfigData or {}

/*
function GM:PlayerConfiguration()
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
	list:AddItem(MakeText(self.PrestigePanel, "Prestige will reset all your levels, XP and skills, but you will gain +25% boost to xp gain (every prestige) and a perk point.\nPrestigin will also unlock new perks after time.", "TargetIDSmall"))
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
	list:AddItem(MakeText(self.PrestigePanel, "Eternity to reset your levels, XP, skills, prestiges and prestige perks, but you gain a +175% boost to xp gain (every eternity) and\nEternity point. Eternity perks are more powerful than regular perks.", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Must reach max xp needed for next level, level "..MAX_LEVEL.." at "..MAX_PRESTIGE.." prestiges in order to Eternity", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Upon eternity you are given lots of buffs. (TO BE IMPLEMENTED)", "TargetIDSmall"))
	list:AddItem(MakeText(self.PrestigePanel, "Fyi perks do not work yet ffs I STILL NEED WORK TO GET THEM IMPLEMENTED", "TargetIDSmall"))

end
*/
