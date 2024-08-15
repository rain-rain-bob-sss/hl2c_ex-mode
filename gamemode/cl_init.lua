-- Include the required lua files
include("sh_init.lua")
include("sh_translate.lua")
include("cl_calcview.lua")
include("cl_playermodels.lua")
include("cl_scoreboard.lua")
include("cl_viewmodel.lua")
include("cl_net.lua")
include("cl_options.lua")
include("cl_perksmenu.lua")

CreateClientConVar("hl2ce_cl_noearringing", 0, true, true, "Disables annoying tinnitus sound when taking damage from explosions", 0, 1)

timeleft = timeleft or 0

-- Create data folders
if !file.IsDir(GM.VaultFolder, "DATA") then file.CreateDir(GM.VaultFolder) end
if !file.IsDir(GM.VaultFolder.."/client", "DATA") then file.CreateDir(GM.VaultFolder.."/client") end


-- Called by ShowScoreboard
function GM:CreateScoreboard()
	if scoreboard then
		scoreboard:Remove()
		scoreboard = nil
	end

	scoreboard = vgui.Create( "scoreboard" )
end

function GM:HUDDrawScoreBoard()
end

net.Receive("ObjectiveTimer", function(length)
	local net1 = net.ReadFloat()

	timeleft = net1
end)

function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "DefaultFont")
	end
	dpanel:SetText(text)
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end


function GM:Think()
	local difficulty = self:GetDifficulty()

	if difficulty ~= self.PreviousDifficulty then
		self.DifficultyDifference = difficulty - (self.PreviousDifficulty or 0)
		self.DifficultyDifferenceTotal = (self.DifficultyDifferenceTotal or 0) + self.DifficultyDifference
		self.DifficultyDifferenceTimeChange = CurTime()
	end

	if self.DifficultyDifferenceTimeChange + 3 < CurTime() then
		self.DifficultyDifference = 0
		self.DifficultyDifferenceTotal = 0
	end

	self.PreviousDifficulty = difficulty
end

-- Called every frame to draw the hud
function GM:HUDPaint()
	if !GetConVar("cl_drawhud"):GetBool() || (self.ShowScoreboard && IsValid(LocalPlayer()) && (LocalPlayer():Team() != TEAM_DEAD)) then return end
	local timeleftmin = math.floor(timeleft / 60)
	local timeleftsec = timeleft - (timeleftmin * 60)
	local pl = LocalPlayer()

	if timeleft != nil and timeleft > 0 then
		draw.SimpleText(timeleftsec <= 0 and "Objective: Complete the map within "..timeleftmin.." minutes! (Time left: "..math.floor(timeleft - CurTime()).."s)" or "Objective: Complete the map within "..timeleftmin.." minutes and "..timeleftsec.." seconds! (Time left: "..math.floor(timeleft - CurTime()).."s)", "TargetIDSmall", 5, 22, Color(255,255,192,255))
	end

	if !showNav then hook.Run("HUDDrawTargetID") end
	hook.Run("HUDDrawPickupHistory")

	local w = ScrW()
	local h = ScrH()
	centerX = w / 2
	centerY = h / 2

	-- Draw nav marker/point
	if showNav && checkpointPosition && (LocalPlayer():Team() == TEAM_ALIVE) then
		local checkpointDistance = math.Round(LocalPlayer():GetPos():Distance(checkpointPosition) / 39)
		local checkpointPositionScreen = checkpointPosition:ToScreen()
		surface.SetDrawColor(255, 255, 255, 255)
	
		if ( ( checkpointPositionScreen.x > 32 ) && ( checkpointPositionScreen.x < ( w - 43 ) ) && ( checkpointPositionScreen.y > 32 ) && ( checkpointPositionScreen.y < ( h - 38 ) ) ) then
			surface.SetTexture(surface.GetTextureID( "hl2c_nav_marker" ))
			surface.DrawTexturedRect( checkpointPositionScreen.x - 14, checkpointPositionScreen.y - 14, 28, 28 )
			draw.DrawText( tostring( checkpointDistance ).." m", "Roboto16", checkpointPositionScreen.x, checkpointPositionScreen.y + 15, Color( 255, 220, 0, 255 ), 1 )
		else
			local r = math.Round( centerX / 2 )
			local checkpointPositionRad = math.atan2( checkpointPositionScreen.y - centerY, checkpointPositionScreen.x - centerX )
			local checkpointPositionDeg = 0 - math.Round( math.deg( checkpointPositionRad ) )
			surface.SetTexture( surface.GetTextureID( "hl2c_nav_pointer" ) )
			surface.DrawTexturedRectRotated( math.cos( checkpointPositionRad ) * r + centerX, math.sin( checkpointPositionRad ) * r + centerY, 32, 32, checkpointPositionDeg + 90 )
		end
	end

	local colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (self.DifficultyDifference < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0, 155) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0, 155)) or Color(255, 220, 0, 155)
	draw.DrawText(Format("Difficulty: %s%%", FormatNumber(math.Round(self:GetDifficulty() * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6, colordifference, TEXT_ALIGN_CENTER )
	if self.DifficultyDifferenceTimeChange + 3 >= CurTime() then
		colordifference.a = (self.DifficultyDifferenceTimeChange+3-CurTime())*155/3
		draw.DrawText(Format("%s%s%%", self.DifficultyDifference < 0 and "-" or "+", math.abs(math.Round(self.DifficultyDifference * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 + 15, colordifference, TEXT_ALIGN_CENTER )

		if self.DifficultyDifference ~= self.DifficultyDifferenceTotal then
			colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (self.DifficultyDifferenceTotal < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0, colordifference.a) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0, colordifference.a)) or Color(255, 220, 0, colordifference.a)
			draw.DrawText(Format("%s%s%% total", self.DifficultyDifferenceTotal < 0 and "-" or "+", math.abs(math.Round(self.DifficultyDifferenceTotal * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 + 30, colordifference, TEXT_ALIGN_CENTER )
		end
	end

	if pl:Alive() then
		local hp,ap = pl:Health(),pl:Armor()
		local mhp,map = pl:GetMaxHealth(), pl:GetMaxArmor()

		draw.DrawText(Format("Health: %s/%s (%d%%)", pl:Health(), pl:GetMaxHealth(), hp/mhp*100), "TargetIDSmall", 16, ScrH()-100, Color(255,155,155,255), TEXT_ALIGN_LEFT)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(15, ScrH() - 80, 200, 10)
		surface.SetDrawColor(205, 25, 25, 255)
		surface.DrawRect(16, ScrH() - 79, 198*math.Clamp(hp/mhp,0,1), 10)

		draw.DrawText(Format("Armor: %s/%s (%d%%)", pl:Armor(), pl:GetMaxArmor(), ap/map*100), "TargetIDSmall", 16, ScrH()-60, Color(155,155,255,255), TEXT_ALIGN_LEFT)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(15, ScrH() - 40, 200, 10)
		surface.SetDrawColor(25, 25, 205, 255)
		surface.DrawRect(16, ScrH() - 39, 198*math.Clamp(ap/map,0,1), 10)
	end

	
	-- Are we going to the next map?
	if nextMapCountdownStart then
		local nextMapCountdownLeft = math.Round( nextMapCountdownStart + NEXT_MAP_TIME - CurTime() )
		draw.SimpleTextOutlined(nextMapCountdownLeft > 0 and "Next Map in "..tostring(nextMapCountdownLeft) or "Switching Maps!", "roboto32BlackItalic", centerX, h - h * 0.075, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ) )
	end

	-- Are we restarting the map?
	if restartMapCountdownStart then
		local restartMapCountdownLeft = math.ceil( restartMapCountdownStart + RESTART_MAP_TIME - CurTime() )
		draw.SimpleTextOutlined(restartMapCountdownLeft > 0 and "Restarting Map in "..tostring(restartMapCountdownLeft) or "Restarting Map!", "roboto32BlackItalic", centerX, h - h * 0.075, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ) )
	end

	-- On top of it all
	hook.Run("DrawDeathNotice", 0.85, 0.04)
end


function GM:PostDrawHUD()
	cam.Start2D()
	-- draw.SimpleText(self.Name.." "..self.Version, "TargetIDSmall", 5, 5, Color(255,255,192,25))
	surface.SetDrawColor(0, 0, 0, 0)

	if XPColor > 0 then
		draw.SimpleText(math.Round(XPGained, 2).." XP gained", "TargetID", ScrW() / 2 + 15, (ScrH() / 2) + 15, Color(255,255,255,XPColor), 0, 1 )
		if XPGainedTotal ~= XPGained then
			draw.SimpleText("("..math.Round(XPGainedTotal, 2).." XP gained total)", "TargetIDSmall", ScrW() / 2 + 15, (ScrH() / 2) + 30, Color(255,255,205,XPColor), 0, 1 )
		end
	else
		XPGained = 0
		XPGainedTotal = 0
	end

	XPColor = math.max(0, XPColor - 90*FrameTime())
	cam.End2D()
end


-- Called every frame
function GM:HUDShouldDraw( name )

	if IsValid(LocalPlayer()) then
		if self.ShowScoreboard && (LocalPlayer():Team() != TEAM_DEAD) then
			return false
		end
	
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) && (wep.HUDShouldDraw != nil) then
			return wep.HUDShouldDraw( wep, name )
		end

		if name == "CHudHealth" or name == "CHudBattery" then
			return false
		end
	end
	return true
end


-- Called when we initialize
function GM:Initialize()

	-- Initial variables for client
	self.ShowScoreboard = false
	showNav = false
	scoreboard = nil

	-- Fonts we will need later
	-- surface.CreateFont( "Roboto16", { size = 16, weight = 400, antialias = true, additive = false, font = "Roboto" } )
	surface.CreateFont( "Roboto16", { size = 16, weight = 700, antialias = true, additive = false, font = "Roboto-Bold" } )
	surface.CreateFont( "roboto32BlackItalic", { size = 32, weight = 900, antialias = true, additive = false, font = "Roboto Black Italic" } )

	-- Language
	language.Add( "worldspawn", "World" )
	language.Add( "func_door_rotating", "Door" )
	language.Add( "func_door", "Door" )
	language.Add( "phys_magnet", "Magnet" )
	language.Add( "trigger_hurt", "Trigger Hurt" )
	language.Add( "entityflame", "Fire" )
	language.Add( "env_explosion", "Explosion" )
	language.Add( "env_fire", "Fire" )
	language.Add( "func_tracktrain", "Train" )
	language.Add( "npc_launcher", "Headcrab Pod" )
	language.Add( "func_tank", "Mounted Turret" )
	language.Add( "npc_helicopter", "Helicopter" )
	language.Add( "npc_bullseye", "Turret" )
	language.Add( "prop_vehicle_apc", "APC" )
	language.Add( "item_healthkit", "Health Kit" )
	language.Add( "item_healthvial", "Health Vial" )
	language.Add( "combine_mine", "Mine" )
	language.Add( "npc_grenade_frag", "Grenade" )
	language.Add( "npc_metropolice", "Civil Protection" )
	language.Add( "npc_combine_s", "Combine Soldier" )
	language.Add( "npc_strider", "Strider" )

	-- Run this command for a more HL2 style radiosity
	RunConsoleCommand( "r_radiosity", "4" )

end

function GM:InitPostEntity()
	local ply = LocalPlayer()


	self:PlayerReady()
	net.Start("hl2c_playerready")
	net.SendToServer()
end

function GM:PlayerReady()
	local ply = LocalPlayer()

	ply.XP = 0
	ply.Level = 0
	ply.StatPoints = 0
	ply.Prestige = 0
	ply.PrestigePoints = 0
	ply.Eternity = 0
	ply.EternityPoints = 0

	-- Endless
	ply.Celestiality = 0
	ply.CelestialityPoints = 0
	ply.Rebirths = 0
	ply.RebirthPoints = 0
	ply.Ascensions = 0
	ply.AscensionPoints = 0
end

function GM:SpawnMenuEnabled()
	return true
end

function GM:SpawnMenuOpen()
	return true
end

function GM:ContextMenuOpen()
	return true
end

-- Called when a bind is pressed
function GM:PlayerBindPress( ply, bind, down )
	-- if bind == "+menu" && down then
		-- RunConsoleCommand( "lastinv" )
		-- return true
	-- end

	return false
end


-- Called when a player sends a chat message
function GM:OnPlayerChat( ply, text, team, dead )
	local tab = {}
	if ( dead || ( IsValid( ply ) && ( ply:Team() == TEAM_DEAD ) ) ) then
		table.insert(tab, Color(191, 30, 40))
		table.insert(tab, "*Dead* ")
	end

	if ( team ) then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, "(TEAM) ")
	end

	if ply:SteamID64() == "76561198274314803" then
		table.insert(tab, Color(160,160,160))
		table.insert(tab, "[")
		table.insert(tab, Color(224,224,160))
		table.insert(tab, "Hl2c EX coder")
		table.insert(tab, Color(160,160,160))
		table.insert(tab, "] ")
	end

	if ( IsValid( ply ) ) then
		table.insert( tab, ply )
	else
		table.insert( tab, "Console" )
	end

	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..text )

	chat.AddText( unpack( tab ) )
	return true
end


-- Called when going to the next map
function NextMap( len )

	nextMapCountdownStart = net.ReadFloat()

end
net.Receive( "NextMap", NextMap )


-- Called when player spawns for the first time
function PlayerInitialSpawn( len )

	-- Shows the help menu
	if !file.Exists( GAMEMODE.VaultFolder.."/client/shown_help.txt", "DATA") then
		ShowHelp(0)
		file.Write(GAMEMODE.VaultFolder.."/client/shown_help.txt", "You've viewed the help menu in Half-Life 2 Campaign.")
	end

	-- Enable or disable the custom playermodel menu
	CUSTOM_PLAYERMODEL_MENU_ENABLED = net.ReadBool()

end
net.Receive("PlayerInitialSpawn", PlayerInitialSpawn)


-- Called when restarting maps
function RestartMap(len)
	restartMapCountdownStart = net.ReadFloat()
	if restartMapCountdownStart == -1 then
		restartMapCountdownStart = nil
	end

	if GetGlobalString("losemusic") then
		local sound = CreateSound(LocalPlayer(), GetGlobalString("losemusic", ""))
		sound:Play()
	end
end
net.Receive("RestartMap", RestartMap)

if file.Exists(GM.VaultFolder.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

-- Called by show help
function ShowHelp(len)
	local helpText = "-= ABOUT THIS GAMEMODE =-\nWelcome to Half-Life 2 Campaign EX!\nThis gamemode is based on Half-Life 2 Campaign made by Jai 'Choccy' Fox,\nwith new stuff like Leveling, Skills and more!\n\n-= KEYBOARD SHORTCUTS =-\n[F1] (Show Help) - Opens this menu.\n[F2] (Show Team) - Toggles the navigation marker on your HUD.\n[F3] (Spare 1) - Spawns a vehicle if allowed.\n[F4] (Spare 2) - Removes a vehicle if you have one.\n\n-= OTHER NOTES =-\nOnce you're dead you cannot respawn until the next map.\nNot only Difficulty increases, but also XP gaining multiplier."
	
	local helpEXMode = GAMEMODE.EXMode and "EX Mode is enabled! Expect Map objectives, NPC variants and chaos here!" or "EX Mode is disabled!"

	local helpMenu = vgui.Create("DFrame")
	local helpPanel = vgui.Create("DPanel", helpMenu)
	local helpLabel = vgui.Create("DLabel", helpPanel)

	helpLabel:SetText(helpText.."\n"..helpEXMode)
	helpLabel:SetTextColor(GAMEMODE.EXMode and Color(224,48,48,255) or Color(0,64,0,255))
	helpLabel:SetPos(7, 5)
	helpLabel:SizeToContents()
	
	local w, h = helpLabel:GetSize()
	helpMenu:SetSize(math.max(380, w + 13), math.max(259, h + 73))
	helpPanel:StretchToParent( 5, 28, 5, 5 )

	
	
	helpMenu:SetTitle( "Help" )
	helpMenu:Center()
	helpMenu:MakePopup()
end
net.Receive("ShowHelp", ShowHelp)

function GM:ShowSkills()
	local pl = LocalPlayer()
	local skillsMenu = vgui.Create("DFrame")
	local skillsPanel = vgui.Create("DPanel", skillsMenu)
	local skillsText = vgui.Create("DLabel", skillsPanel)
	local skillsForm = vgui.Create("DPanelList", skillsPanel)

	skillsText:SetText("Unspent skill points: "..math.floor(pl.StatPoints))
	skillsText:SetTextColor(color_black)
	skillsText:SetPos(5, 5)
	skillsText:SizeToContents()

	skillsMenu:SetSize(233, 188)

	skillsPanel:StretchToParent( 5, 28, 5, 5 )

	skillsMenu:SetTitle("Your skills")
	skillsMenu:Center()
	skillsMenu:MakePopup()

	skillsForm:SetSize(218, 125)
	skillsForm:SetPos(5, 25)
	skillsForm:EnableVerticalScrollbar(true)
	skillsForm:SetSpacing(8) 
	skillsForm:SetName("")
	skillsForm.Paint = function() end

	local function DoStatsList()
		for k, v in SortedPairs(self.SkillsInfo) do
			local LabelDefense = vgui.Create("DLabel")
			LabelDefense:SetPos(50, 50)
			LabelDefense:SetText(translate.Get(k)..": "..tostring(pl["Stat"..k]))
			LabelDefense:SetTextColor(color_black)
			LabelDefense:SetToolTip(translate.Get(k.."_d"))
			LabelDefense:SizeToContents()
			skillsForm:AddItem(LabelDefense)

			local Button = vgui.Create("DButton")
			Button:SetPos(50, 100)
			Button:SetSize(15, 20)
			Button:SetTextColor(color_black)
			Button:SetText("Increase "..translate.Get(k).." by 1 point")
			Button:SetToolTip(translate.Get(k.."_d"))
			Button.DoClick = function(Button)
				net.Start("UpgradePerk")
				net.WriteString(k)
				net.SendToServer()
				timer.Simple(0.3, function() 
					if skillsForm:IsValid() then
						skillsForm:Clear()
						DoStatsList()
						skillsText:SetText("Unspent skill points: "..pl.StatPoints)
					end
				end)
				Button.DoDoubleClick = Button.DoClick
			end
			skillsForm:AddItem(Button)
		end
	end
	DoStatsList()
end


-- Called by client pressing -score
function GM:ScoreboardHide()
	self.ShowScoreboard = false

	if scoreboard then	
		scoreboard:SetVisible(false)
	end

	gui.EnableScreenClicker(false)
end


-- Called by client pressing +score
function GM:ScoreboardShow()
	if game.SinglePlayer() then return end

	self.ShowScoreboard = true

	if !scoreboard then
		self:CreateScoreboard()
	end

	scoreboard:SetVisible(true)
	scoreboard:UpdateScoreboard(true)

	gui.EnableScreenClicker(true)
end

function GM:OnReloaded()
	timer.Simple(1, function()
		net.Start("hl2c_updatestats")
		net.WriteString("reloadstats")
		net.SendToServer()
	end)
end

-- Called when the player is drawn
function GM:PostPlayerDraw( ply )

	if ( showNav && IsValid( ply ) && ply:Alive() && ( ply:Team() == TEAM_ALIVE ) && ( ply != LocalPlayer() ) ) then
	
		local bonePosition = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_Head1" ) || 0 ) + Vector( 0, 0, 16 )
		cam.Start2D()
			draw.SimpleText( ply:Name().." ("..ply:Health().."%)", "TargetIDSmall", bonePosition:ToScreen().x, bonePosition:ToScreen().y, self:GetTeamColor( ply ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		cam.End2D()
	
	end

end


-- Called by ShowTeam
function ShowTeam( len )

	showNav = !showNav

end
net.Receive( "ShowTeam", ShowTeam )


-- Called by server
function SetCheckpointPosition( len )

	checkpointPosition = net.ReadVector()

end
net.Receive( "SetCheckpointPosition", SetCheckpointPosition )

local perksvgui
GM.LocalPerks = GM.LocalPerks or {}

function GM:PerksMenu()
	-- Yes.
	local me = LocalPlayer()

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
	perklist:EnableVerticalScrollbar(true)
	perklist:EnableHorizontal(true)


	local LWeight = vgui.Create("DLabel", perksvgui)
	LWeight:SetFont("TargetIDSmall")
	LWeight:SetPos(10, 3)
	LWeight:SetText("Perk points: ".. 0)
	LWeight:SizeToContents()
	local x,y = LWeight:GetSize()
	LWeight:SetSize(math.min(x, 350), 25)
	LWeight:SetColor(Color(255,255,255,255))
	LWeight:SetMouseInputEnabled(true)
	LWeight:SetToolTip("Perk points are required to unlock perk!\nThey can be gained by prestiging")
	LWeight.Think = function(panel)
		local txt = "Perk points: ".. 0
		if panel:GetText() == txt then return end
		panel:SetText(txt)
		LWeight:SizeToContents()
		local x,y = LWeight:GetSize()
		LWeight:SetSize(math.min(x, 350), 25)
	end




	--------------------------------------------supplies-------------------------------------------------------------
	

	local hoverdesc = vgui.Create("DLabel", perksvgui)
	hoverdesc:SetFont("TargetIDSmall")
	hoverdesc:SetPos(150, 0)
	hoverdesc:SetText("Note: Hover your cursor over perks' description with white color for more info")
	hoverdesc:SizeToContents()
	local x,y = hoverdesc:GetSize()
	hoverdesc:SetSize(810, 30)

	for k, v in SortedPairsByMemberValue(GAMEMODE.PerksData, "PrestigeReq") do
		local perkpanel = vgui.Create("DPanel")
		perkpanel:SetPos(5, 5)
        local size_x,size_y = 810,150
		perkpanel:SetSize(size_x, size_y)
		perkpanel.Paint = function(panel) -- Paint function
			draw.RoundedBoxEx(8,1,1,panel:GetWide()-2,panel:GetTall()-2,
			self.LocalPerks[k] and Color(40, 200, 40, 25) or v.PrestigeReq > me.Prestige and Color(75, 75, 75, 50) or Color(200, 40, 40, 25),
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
		perkdesc:SetText(self.EndlessMode and v.EndlessDescription or v.Description)
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
		perkprestige:SetText("Prestige need: "..v.PrestigeReq)
		perkprestige:SetWrap(true)
		perkprestige:SetColor(Color(255,155,155,255))


		local perkapply = vgui.Create("DButton", perkpanel)
		perkapply:SetSize(size_x - 20, 30)
		perkapply:SetPos(10, size_y - 35)
		perkapply:SetText(self.LocalPerks[k] and "Unlocked" or v.PrestigeReq > (me.Prestige) and "Not enough prestige" or "Unlock")
		perkapply.Think = function(panel)
			local txt = self.LocalPerks[k] and "Unlocked" or v.PrestigeReq > me.Prestige and "Not enough prestige" or "Unlock"
			if panel:GetText() == txt then return end
			panel:SetText(txt)	
		end
		perkapply:SetTextColor(Color(255, 255, 255, 255))
		perkapply.Paint = function(panel)
			surface.SetDrawColor(0, 150, 0, 255)
			surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
			draw.RoundedBox(2, 0, 0, panel:GetWide(), panel:GetTall(), v.PrestigeReq > me.Prestige and Color(75, 75, 75, 130) or Color(0, 50, 0, 130))
		end
		perkapply.DoClick = function(panel)
			net.Start("tea_perksunlock")
			net.WriteString(k)
			net.SendToServer()
		end
		perklist:AddItem(perkpanel)
	end



	sheet:AddSheet("Perks", perklist, "icon16/star.png", false, false, "Perks are additional buffs provided in survival\nChoose which perk you should unlock first!\n\nNote: Perk choices are permanent and can't be reset!")
end


local function SpawnMenuOpen(self)
	if ( !hook.Call( "SpawnMenuOpen", self ) ) then return end

	if ( IsValid( g_SpawnMenu ) ) then
		g_SpawnMenu:Open()
		menubar.ParentTo( g_SpawnMenu )
	end

	hook.Call( "SpawnMenuOpened", self )

end

local function SpawnMenuClose(self)
	if ( IsValid( g_SpawnMenu ) ) then g_SpawnMenu:Close() end
	hook.Call( "SpawnMenuClosed", self )
end

local function ContextMenuOpen(self)
	if ( !hook.Call( "ContextMenuOpen", self ) ) then return end

	if ( IsValid( g_ContextMenu ) && !g_ContextMenu:IsVisible() ) then
		g_ContextMenu:Open()
		menubar.ParentTo( g_ContextMenu )
	end
	
	hook.Call( "ContextMenuOpened", self )
end

local function ContextMenuClose(self)
	if ( IsValid( g_ContextMenu ) ) then g_ContextMenu:Close() end
	hook.Call( "ContextMenuClosed", self )
end

function GM:OnSpawnMenuOpen()
	-- SpawnMenuOpen(self)
end

function GM:OnSpawnMenuClose()
	-- SpawnMenuClose(self)
end



function GM:OnContextMenuOpen()
	-- ContextMenuOpen(self)

	self:CMenu()
end

function GM:OnContextMenuClose()
	-- ContextMenuClose(self)

	if ContextMenu and ContextMenu:IsValid() then
		ContextMenu:Close()
	end
end


