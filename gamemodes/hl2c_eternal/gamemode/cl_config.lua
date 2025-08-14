GM.ConfigData = GM.ConfigData or {}
function GM:PlayerConfiguration()
	--[[
	if IsValid(self.ConfigPanel) then self.ConfigPanel:Remove() end

	local pl = LocalPlayer()
	local wide,tall = 520,660
	self.ConfigPanel = vgui.Create("DFrame")
	self.ConfigPanel:SetSize(wide, tall)
	self.ConfigPanel:Center()
	self.ConfigPanel:SetTitle("PlayerConfiguration")
	self.ConfigPanel:SetDraggable(false)
	self.ConfigPanel:SetVisible(true)
	self.ConfigPanel:SetAlpha(0)
	self.ConfigPanel:AlphaTo(255, 0.45, 0)
	self.ConfigPanel:ShowCloseButton(true)
	self.ConfigPanel:MakePopup()
	self.ConfigPanel.Paint = function(this, w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0, 200))
		surface.SetDrawColor(150, 50, 0, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local list = vgui.Create("DPanelList", self.ConfigPanel)
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

	list:AddItem(MakeText(self.ConfigPanel, "Fyi perks do not work yet ffs I STILL NEED WORK TO GET THEM IMPLEMENTED", "TargetIDSmall"))
	]]
end