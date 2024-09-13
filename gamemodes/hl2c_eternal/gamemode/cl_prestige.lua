local function FirstPrestige()
	local pl = LocalPlayer()
	local snd = CreateSound(pl, "music/hl2_song10.mp3")
	snd:PlayEx(1, 65)

	local textsize_x,textsize_y
	local ui = vgui.Create("DPanel")
	ui:SetPos(0,0)
	ui:SetSize(ScrW(),ScrH())
	ui:SetMouseInputEnabled(false)
	ui.Paint = function() end


	local text1 = vgui.Create("DLabel", ui)
	text1:SetFont("TargetIDSmall")
	text1:SetText("Ah a fellow player.")
	text1:SetAlpha(0)
	text1:AlphaTo(255, 3, 1.5)
	text1:SizeToContents()
	textsize_x,textsize_y = text1:GetSize()
	text1:SetPos(ScrW()/2 - textsize_x/2, 110)

	local text2 = vgui.Create("DLabel", ui)
	text2:SetFont("TargetIDSmall")
	text2:SetText("Congratulations on Prestiging.")
	text2:SetAlpha(0)
	text2:AlphaTo(255, 3, 2.5)
	text2:SizeToContents()
	textsize_x,textsize_y = text2:GetSize()
	text2:SetPos(ScrW()/2 - textsize_x/2, 190)

	local text3 = vgui.Create("DLabel", ui)
	text3:SetFont("TargetIDSmall")
	text3:SetText("You seem to start understanding the mechanics of this gamemode.")
	text3:SetAlpha(0)
	text3:AlphaTo(255, 3, 5)
	text3:SizeToContents()
	textsize_x,textsize_y = text3:GetSize()
	text3:SetPos(ScrW()/2 - textsize_x/2, 270)

	local text4 = vgui.Create("DLabel", ui)
	text4:SetFont("TargetIDSmall")
	text4:SetText(pl:Nick().."? That's a nice name.")
	text4:SetAlpha(0)
	text4:AlphaTo(255, 3, 8.5)
	text4:SizeToContents()
	textsize_x,textsize_y = text4:GetSize()
	text4:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 1.5)

	local text5 = vgui.Create("DLabel", ui)
	text5:SetFont("TargetIDSmall")
	text5:SetText("Our name is...")
	text5:SetAlpha(0)
	text5:AlphaTo(255, 5, 12.5)
	text5:SizeToContents()
	textsize_x,textsize_y = text5:GetSize()
	text5:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 1.5 + 60)

	local ct = CurTime()
	hook.Add("PreDrawHUD", "hl2ce_firstprestige", function()
		cam.Start2D()
		surface.SetDrawColor(255, 255, 255, 255-(CurTime() - ct)*10)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()
	end)
	timer.Simple(16, function()
		ui:Remove()
		hook.Remove("PreDrawHUD", "hl2ce_firstprestige")
		snd:Stop()

		chat.AddText("Gordon! We got no time to lose! We must keep on going!")
		chat.AddText(Color(0,255,0), "Perks unlocked.")
		chat.AddText(Color(0,255,0), "Each level up awards you with 2 skill points and skills max level increased to 35.")
		chat.AddText(Color(0,255,0), "")
	end)
end


local function FirstEternity()
	local pl = LocalPlayer()
	local snd = CreateSound(pl, "music/hl2_song10.mp3")
	snd:PlayEx(1, 55)

	local textsize_x,textsize_y
	local ui = vgui.Create("DPanel")
	ui:SetPos(0,0)
	ui:SetSize(ScrW(),ScrH())
	ui:SetMouseInputEnabled(false)
	ui.Paint = function() end


	local text1 = vgui.Create("DLabel", ui)
	text1:SetFont("TargetIDSmall")
	text1:SetText(pl:Nick()..".")
	text1:SetAlpha(0)
	text1:AlphaTo(255, 0.5, 0.5)
	text1:SizeToContents()
	textsize_x,textsize_y = text1:GetSize()
	text1:SetPos(ScrW()/2 - textsize_x/2, 110)

	local text2 = vgui.Create("DLabel", ui)
	text2:SetFont("TargetIDSmall")
	text2:SetText("So close, yet so far... You have became eternal.")
	text2:SetAlpha(0)
	text2:AlphaTo(255, 2.5, 1.5)
	text2:SizeToContents()
	textsize_x,textsize_y = text2:GetSize()
	text2:SetPos(ScrW()/2 - textsize_x/2, 150)

	local text3 = vgui.Create("DLabel", ui)
	text3:SetFont("TargetIDSmall")
	text3:SetText("As you progress through prestiges, you unlock more stuff.")
	text3:SetAlpha(0)
	text3:AlphaTo(255, 3, 4)
	text3:SizeToContents()
	textsize_x,textsize_y = text3:GetSize()
	text3:SetPos(ScrW()/2 - textsize_x/2, 190)

	local text4 = vgui.Create("DLabel", ui)
	text4:SetFont("TargetIDSmall")
	text4:SetText("Have you knew that before?")
	text4:SetAlpha(0)
	text4:AlphaTo(255, 3, 8.5)
	text4:SizeToContents()
	textsize_x,textsize_y = text4:GetSize()
	text4:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 2)

	local text5 = vgui.Create("DLabel", ui)
	text5:SetFont("TargetIDSmall")
	text5:SetText("And be careful. Each time you reach new prestige layer, things become more difficult.")
	text5:SetAlpha(0)
	text5:AlphaTo(255, 5, 15.5)
	text5:SizeToContents()
	textsize_x,textsize_y = text5:GetSize()
	text5:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 2 + 50)

	local text6 = vgui.Create("DLabel", ui)
	text6:SetFont("TargetIDSmall")
	text6:SetText("Do not go too far.")
	text6:SetTextColor(Color(255,0,0))
	text6:SetAlpha(0)
	text6:AlphaTo(255, 3, 18.5)
	text6:SizeToContents()
	textsize_x,textsize_y = text6:GetSize()
	text6:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 2 + 80)

	local text7 = vgui.Create("DLabel", ui)
	text7:SetFont("TargetIDSmall")
	text7:SetText("What the hell? You are needed?")
	text7:SetAlpha(0)
	text7:AlphaTo(255, 2.5, 22)
	text7:SizeToContents()
	textsize_x,textsize_y = text7:GetSize()
	text7:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 1.5)

	local text8 = vgui.Create("DLabel", ui)
	text8:SetFont("TargetIDSmall")
	text8:SetText("Ok. Until you reach another prestige layer, I won't disturb you.")
	text8:SetAlpha(0)
	text8:AlphaTo(255, 2.5, 25.5)
	text8:SizeToContents()
	textsize_x,textsize_y = text8:GetSize()
	text8:SetPos(ScrW()/2 - textsize_x/2, ScrH() / 1.5 + 40)

	local ct = CurTime()
	local fadetime
	hook.Add("PreDrawHUD", "hl2ce_firsteternity", function()
		local t = math.abs(math.sin(CurTime()*3))
		local col = Color(255-t*140, 255-t*140, 255, 255-(CurTime() - ct)*7)
		local f = fadetime and 1-(CurTime()-fadetime) or 1
		cam.Start2D()
		col.r,col.g,col.b,col.a = col.r*f,col.g*f,col.b*f,col.a*f
		surface.SetDrawColor(col.r, col.g, col.b, col.a)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()
	end)
	timer.Simple(20, function()
		chat.AddText(Color(255,255,0), "Gordon, what are you doing?! Stop meditating now! The combine is invading the entire planet and you are meditating now?!!")
		timer.Simple(10, function()
			fadetime = CurTime()
			ui:AlphaTo(0, 1, 0)
			timer.Simple(1, function()
				ui:Remove()
				hook.Remove("PreDrawHUD", "hl2ce_firsteternity")


				chat.AddText(Color(0,155,244), "---=== ETERNITY LOG ===---")
				chat.AddText(Color(0,155,244), "Pets unlocked.")
				chat.AddText(Color(0,155,244), "Max Level increased to 200.")
				chat.AddText(Color(0,155,244), "Prestige gain is increased for the amount of XP is used on Level up.")
				chat.AddText(Color(0,155,244), "Every time you level up, if set, 3 skills of your choice are automatically increased by 1.")
				chat.AddText(Color(0,155,244), "Auto-Prestige has also been unlocked.")
				chat.AddText(Color(0,155,244), "^ You can configure this in your Player Configuration.")
				chat.AddText(Color(0,155,244), "Max skills level has been increased to 60.")
				chat.AddText(Color(0,155,244), "---=== END OF LOG ===---")
			end)
			snd:FadeOut(1)
		end)
	end)
end


local function FirstRebirth()
	local pl = LocalPlayer()
	local snd = CreateSound(pl, "music/hl2_song10.mp3")
	snd:PlayEx(1, 215)

	local textsize_x,textsize_y
	local ui = vgui.Create("DPanel")
	ui:SetPos(0,0)
	ui:SetSize(ScrW(),ScrH())
	local ct = CurTime() + 2.25
	ui.Paint = function()
		local t = math.abs(math.sin(CurTime()*3))
		local col = Color(0, 0, 0, (CurTime() - ct)*255)
		surface.SetDrawColor(col.r, col.g, col.b, col.a)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end


	local text1 = vgui.Create("DLabel", ui)
	text1:SetFont("TargetID")
	text1:SetText("I won't let you!")
	text1:SetAlpha(0)
	text1:SizeToContents()
	textsize_x,textsize_y = text1:GetSize()
	text1:SetPos(ScrW()/2 - textsize_x/2, ScrH()/2 - 110)

	local text2 = vgui.Create("DLabel", ui)
	text2:SetFont("TargetID")
	text2:SetText("Eat this crash!")
	text2:SetAlpha(0)
	text2:SizeToContents()
	textsize_x,textsize_y = text2:GetSize()
	text2:SetPos(ScrW()/2 - textsize_x/2, ScrH()/2 - 60)

	local text3 = vgui.Create("DLabel", ui)
	text3:SetFont("Trebuchet24")
	text3:SetText("REBIRTH PROCESS COMPLETE.")
	text3:SetTextColor(Color(0,255,0))
	text3:SetAlpha(0)
	text3:SizeToContents()
	textsize_x,textsize_y = text3:GetSize()
	text3:SetPos(ScrW()/2 - textsize_x/2, ScrH()/2)


	timer.Simple(2, function()
		local eff = EffectData()
		for i=0.01,1,0.01 do
			timer.Simple(i, function()
				eff:SetOrigin(pl:GetPos())
				util.Effect("Explosion", eff)
			end)
		end
	end)
	timer.Simple(2.25, function()

		ui:MakePopup()
		text1:AlphaTo(255, 0.5, 0)
		text2:AlphaTo(255, 0.5, 0.5)
		text3:AlphaTo(255, 0, 0.75)

--		timer.Simple(0.95, function() while true do end end) -- Meant to freeze the game, but is there a way to force native crash? (On every OS as possible)

		timer.Simple(5, function()
			ui:Remove()
		end)
	end)
end



net.Receive("hl2ce_firstprestige", function(len)
	local str = net.ReadString()

	if str == "prestige" then
		FirstPrestige()
	elseif str == "eternity" then
		FirstEternity()
	end
end)

concommand.Add("test", FirstRebirth)
