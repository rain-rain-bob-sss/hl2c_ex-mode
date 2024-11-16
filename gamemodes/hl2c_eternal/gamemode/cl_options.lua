
function GM.MakeOptions()
	
	local Window = vgui.Create("DFrame")
	local wide,tall = math.min(ScrW(), 400), math.min(ScrH(), 440)
	Window:SetSize(wide, tall)
	Window:Center()
	Window:SetTitle("Options")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:SetDeleteOnClose(false)
	Window:MakePopup()

	local list = vgui.Create("DPanelList", Window)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSize(wide - 24, tall - 20)
	list:SetPos(12, 24)
	list:SetPadding(8)
	list:SetSpacing(4)


	local function CreateCheck(name, cvar)
		local convar = GetConVar(cvar)
		local check = vgui.Create("DCheckBoxLabel", Window)
		check:SetText(name)
		check:SetConVar(cvar)
		check:SetToolTip(convar and convar:GetHelpText() or "")
		check:SizeToContents()
		list:AddItem(check)

		return check
	end

	CreateCheck("Disable Tinnitus/Earringing", "hl2ce_cl_noearringing")
	CreateCheck("Don't show Difficulty on HUD", "hl2ce_cl_nohuddifficulty")
	CreateCheck("Disable Custom HUD", "hl2ce_cl_nocustomhud")
end
