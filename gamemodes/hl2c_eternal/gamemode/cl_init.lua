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
include("cl_prestige.lua")
include("cl_config.lua")
include("cl_upgradesmenu.lua")

local hl2ce_cl_noearringing = CreateClientConVar("hl2ce_cl_noearringing", 0, true, true, "Disables annoying tinnitus sound when taking damage from explosions", 0, 1)
local hl2ce_cl_nohuddifficulty = CreateClientConVar("hl2ce_cl_nohuddifficulty", 0, true, true, "Disables Difficulty text from HUD if not having CMenu Open", 0, 1)
local hl2ce_cl_nodifficultytext = CreateClientConVar("hl2ce_cl_nodifficultytext", 0, true, true, "Displays only the % on difficulty", 0, 1)
local hl2ce_cl_nocustomhud = CreateClientConVar("hl2ce_cl_nocustomhud", 0, true, true, "Disables the HL2 Health and Armor Bars", 0, 1)

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

	if not self.PreviousDifficulty then
		self.PreviousDifficulty = difficulty
	end

	if not self.DifficultyDifferenceTimeChange or self.DifficultyDifferenceTimeChange + 3 < CurTime() then
		self.DifficultyDifference = 0
		self.DifficultyDifferenceTotal = 0
		self.DifficultyDifferenceTimeChange = 0
	end

	if difficulty ~= self.PreviousDifficulty then
		self.DifficultyDifference = difficulty - self.PreviousDifficulty
		if infmath.ConvertInfNumberToNormalNumber(self.DifficultyDifference) ~= 0 then
			self.DifficultyDifferenceTotal = self.DifficultyDifferenceTotal + self.DifficultyDifference
			self.DifficultyDifferenceTimeChange = CurTime()
		end
		self.PreviousDifficulty = difficulty
	end

end

local bosshp = 0
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

	local colordifference
	if FORCE_DIFFICULTY and ContextMenu and ContextMenu:IsValid() then
		colordifference = FORCE_DIFFICULTY > 1 and Color(255, 755 - FORCE_DIFFICULTY*500, 0) or FORCE_DIFFICULTY < 1 and Color(FORCE_DIFFICULTY*1020-765, 255, 0) or Color(255, 255, 0)
		colordifference.a = 155
		draw.DrawText(Format("Map forced difficulty bonus: %s%%", FormatNumber(math.Round(FORCE_DIFFICULTY * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 - 15, colordifference, TEXT_ALIGN_CENTER)
	end

	local diff_difference = infmath.ConvertInfNumberToNormalNumber(self.DifficultyDifference)
	local diff_difference_total = infmath.ConvertInfNumberToNormalNumber(self.DifficultyDifferenceTotal)

	if (ContextMenu and ContextMenu:IsValid()) or not hl2ce_cl_nohuddifficulty:GetBool() then
		colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (diff_difference < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0)) or Color(255, 220, 0)
		colordifference.a = 155

		local d = self:GetDifficulty() * 100
		local d_normal = infmath.ConvertInfNumberToNormalNumber(d)
		local s = Format(hl2ce_cl_nodifficultytext:GetBool() and "%s%%" or "Difficulty: %s%%", FormatNumber(infmath.Round(d, 2)))
		surface.SetFont("TargetIDSmall")
		local len = surface.GetTextSize(s)
		local l = 0
		

		local c = d_normal >= 1e33 and Color(255,0,255) or
			d_normal >= 1e6 and Color(255,0,0) or
			colordifference

		c.a = colordifference.a
		if d >= InfNumber(math.huge) then
			for i=1,#s do
				local r = math.Rand(0.5, 1)
				c = HSVToColor((SysTime()*(60+math.log10(d:log10()*100)*10) + (
					d:log10() > 1000 and -math.sin(l/5)*10*(math.log10(d:log10())-2) or l/3
			))%360, 1, 1)

				draw.DrawText(s[i], "TargetIDSmall", ScrW() / 2 - len/2 + l, ScrH() / 6, c, TEXT_ALIGN_LEFT)
				l = l + surface.GetTextSize(s[i])
			end
		else
			draw.DrawText(s, "TargetIDSmall", ScrW() / 2 - len/2 + l, ScrH() / 6, c, TEXT_ALIGN_LEFT )
		end

		if self.DifficultyDifferenceTimeChange + 3 >= CurTime() and self.DifficultyDifference ~= 0 then
			colordifference.a = (self.DifficultyDifferenceTimeChange+3-CurTime())*155/3
			draw.DrawText(Format("%s%s%%", diff_difference < 0 and "-" or "+", infmath.abs(infmath.Round(self.DifficultyDifference * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 + 15, colordifference, TEXT_ALIGN_CENTER )

			if self.DifficultyDifference ~= self.DifficultyDifferenceTotal and infmath.ConvertInfNumberToNormalNumber(self.DifficultyDifferenceTotal) ~= 0 then
				colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (diff_difference_total < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0, colordifference.a) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0, colordifference.a)) or Color(255, 220, 0, colordifference.a)
				draw.DrawText(Format("%s%s%% total", diff_difference_total < 0 and "-" or "+", infmath.abs(infmath.Round(self.DifficultyDifferenceTotal * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 + 30, colordifference, TEXT_ALIGN_CENTER )
			end
		end
	end

	if pl:Alive() and pl:IsSuitEquipped() and not hl2ce_cl_nocustomhud:GetBool() then
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


	local boss = GAMEMODE.EnemyBoss
	if boss and IsValid(boss) then
		local hp,mhp = boss:Health(),boss:GetMaxHealth()

		surface.SetDrawColor(255, 0, 0, 155)
		surface.DrawRect(ScrW()/2 - ScrW()/3.5, ScrH()*0.1, ScrW()/3.5*2 * math.min(1, bosshp/mhp), ScrH()*0.05)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawOutlinedRect(ScrW()/2 - ScrW()/3.5, ScrH()*0.1, ScrW()/3.5*2, ScrH()*0.05)

		draw.SimpleText(language.GetPhrase(boss:GetClass()), "TargetID", ScrW()/2, ScrH()*0.115, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if hp > 0 then
			draw.SimpleText(string.format("%s/%s", math.ceil(hp), math.ceil(mhp)), "TargetID", ScrW()/2, ScrH()*0.135, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("DEAD!", "TargetID", ScrW()/2, ScrH()*0.14, Color(255,255,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		bosshp = math.Approach(bosshp, hp, (hp-bosshp)*math.Round(FrameTime()*2, 3))
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
		draw.SimpleText(tostring(infmath.Round(XPGained, 2)).." XP gained", "TargetID", ScrW() / 2 + 15, (ScrH() / 2) + 15, Color(255,255,255,XPColor), 0, 1 )
		if XPGainedTotal ~= XPGained then
			draw.SimpleText("("..tostring(infmath.Round(XPGainedTotal, 2)).." XP gained total)", "TargetIDSmall", ScrW() / 2 + 15, (ScrH() / 2) + 30, Color(255,255,205,XPColor), 0, 1 )
		end
	else
		XPGained = InfNumber(0)
		XPGainedTotal = InfNumber(0)
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

		if (name == "CHudHealth" or name == "CHudBattery") and not hl2ce_cl_nocustomhud:GetBool() then
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
	surface.CreateFont( "hl2ce_font", { size = 32, weight = 700, font = "Roboto Black" } )
	surface.CreateFont( "hl2ce_font_big", { size = 48, weight = 900, font = "Roboto Black" } )

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

	ply.XP = InfNumber(0)
	ply.Level = InfNumber(0)
	ply.StatPoints = InfNumber(0)
	ply.Prestige = InfNumber(0)
	ply.PrestigePoints = InfNumber(0, 0)
	ply.Eternities = InfNumber(0)
	ply.EternityPoints = InfNumber(0, 0)

	-- Endless
	ply.Celestiality = InfNumber(0)
	ply.CelestialityPoints = InfNumber(0)
	ply.Rebirths = InfNumber(0)
	ply.RebirthPoints = InfNumber(0)
	ply.Ascensions = InfNumber(0)
	ply.AscensionPoints = InfNumber(0)

	-- True Endless
	ply.MythiLegendaries = InfNumber(0)
	ply.MythiLegendaryPoints = InfNumber(0)


	ply.Moneys = InfNumber(0, 0)
	ply.Skills = {}


	ply.UnlockedPerks = {}
	ply.DisabledPerks = {}
	ply.EternityUpgradeValues = {}

	for upgrade,_ in pairs(self.UpgradesEternity) do
		ply.EternityUpgradeValues[upgrade] = 0
	end
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

/*
	if ply:SteamID64() == "76561198274314803" then
		table.insert(tab, Color(160,160,160))
		table.insert(tab, "[")
		table.insert(tab, Color(224,224,160))
		table.insert(tab, "Hl2c EX coder")
		table.insert(tab, Color(160,160,160))
		table.insert(tab, "] ")
	end
*/

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
	-- CUSTOM_PLAYERMODEL_MENU_ENABLED = net.ReadBool()

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

function GM:OnMapCompleted()
end

function GM:OnCampaignCompleted()
end

function GM:PostOnMapCompleted()
end

function GM:PostOnCampaignCompleted()
end


if file.Exists(GM.VaultFolder.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

-- Called by show help
function ShowHelp(len)
	local helpText = "-= ABOUT THIS GAMEMODE =-\nWelcome to Half-Life 2 Campaign EX!\nThis gamemode is based on Half-Life 2 Campaign made by Jai 'Choccy' Fox,\nwith new stuff like Leveling, Skills and more!\n\n-= KEYBOARD SHORTCUTS =-\n[F1] (Show Help) - Opens this menu.\n[F2] (Show Team) - Toggles the navigation marker on your HUD.\n[F3] (Spare 1) - Spawns a vehicle if allowed.\n[F4] (Spare 2) - Removes a vehicle if you have one.\n\n-= OTHER NOTES =-\nOnce you're dead you cannot respawn until the next map.\nDifficulty increases along with XP gain."
	
	local helpEXMode = GAMEMODE.EXMode and "EX Mode is enabled! Expect Map objectives, NPC variants and chaos here!" or "EX Mode is disabled!"
	local helpEndlessMode = GAMEMODE.EndlessMode and "\nEndless Mode is enabled. Difficulty cap is increased drastically. Progression eventually becomes exponential." or "\nEndless Mode is disabled. Difficulty is limited, Skills and Perks have limited functionality."

	local helpMenu = vgui.Create("DFrame")
	local helpPanel = vgui.Create("DPanel", helpMenu)
	local helpLabel = vgui.Create("DLabel", helpPanel)
	local helpLabel2 = vgui.Create("DLabel", helpPanel)
	local adminbutton
	local pl = LocalPlayer()

	if pl:IsValid() and pl:IsAdmin() then
		adminbutton = vgui.Create("DButton", helpPanel)
	end

	helpLabel:SetText(helpText)
	helpLabel:SetTextColor(Color(0,64,0,255))
	helpLabel:SetPos(7, 5)
	helpLabel:SizeToContents()

	local w, h = helpLabel:GetSize()
	helpLabel2:SetText(helpEXMode..helpEndlessMode)
	helpLabel2:SetTextColor(GAMEMODE.EXMode and Color(224,48,48,255) or Color(0,64,0,255))
	helpLabel2:SetPos(7, h + 5)
	helpLabel2:SizeToContents()

	local w2, h2 = helpLabel2:GetSize()
	helpMenu:SetSize(math.max(380, w + 13), math.max(259, h + h2 + 73))
	helpPanel:StretchToParent( 5, 28, 5, 5 )

	if adminbutton and adminbutton:IsValid() then
		adminbutton:SetPos(10, h + h2 + 10)
		adminbutton:SetSize(120, 20)
		adminbutton:SetText("Admin Mode")
		adminbutton:SetTextColor(Color(0,0,255))
		adminbutton.DoClick = function()
			GAMEMODE.AdminMode = !GAMEMODE.AdminMode

			chat.AddText(GAMEMODE.AdminMode and "enabled" or "disabled")

			helpMenu:Remove()
		end
		adminbutton.Paint = function(self, width, height)
			surface.SetDrawColor(Color(0,0,155,100))
			surface.DrawRect(0, 0, width, height)
		end
	end
	
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
	local skillsText2 = vgui.Create("DLabel", skillsPanel)
	local skillsText3 = vgui.Create("DLabel", skillsPanel)
	local skillsForm = vgui.Create("DPanelList", skillsPanel)

	skillsText:SetText("Unspent skill points: "..tostring(infmath.floor(pl.StatPoints)))
	skillsText:SetTextColor(color_black)
	skillsText:SetPos(5, 5)
	skillsText:SizeToContents()
	skillsText.Think = function(this)
		local txt = "Unspent skill points: "..tostring(infmath.floor(pl.StatPoints))
		if txt == this:GetText() then return end
		this:SetText(txt)
		this:SizeToContents()
	end

	skillsText2:SetText("Right click to spend a desired amount of SP on a skill")
	skillsText2:SetTextColor(color_black)
	skillsText2:SetPos(5, 20)
	skillsText2:SizeToContents()

	skillsText3:SetText("Click while holding SHIFT to spend all SP on desired skill")
	skillsText3:SetTextColor(color_black)
	skillsText3:SetPos(5, 35)
	skillsText3:SizeToContents()

	skillsMenu:SetSize(293, 263)

	skillsPanel:StretchToParent( 5, 28, 5, 5 )

	skillsMenu:SetTitle("Your skills")
	skillsMenu:Center()
	skillsMenu:MakePopup()
	skillsMenu.Think = function(this)
		if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
			timer.Simple(0, function()
				this:Remove()
			end)
			gui.HideGameUI()
		end
	end

	skillsForm:SetSize(278, 175)
	skillsForm:SetPos(5, 50)
	skillsForm:EnableVerticalScrollbar(true)
	skillsForm:SetSpacing(8) 
	skillsForm:SetName("")
	skillsForm.Paint = function() end

	local function DoStatsList()
		for k, v in SortedPairs(self.SkillsInfo) do
			local LabelDefense = vgui.Create("DLabel")
			LabelDefense:SetPos(50, 50)
			LabelDefense:SetText(v.Name..": "..tostring(pl.Skills[k]))
			LabelDefense:SetTextColor(color_black)
			LabelDefense:SetToolTip(v.Name..("\n\n"..v.DescriptionEndless and "(In Non-Endless Mode:\n)" or "")..v.Description..(v.DescriptionEndless and "\n\nIn Endless Mode:\n"..v.DescriptionEndless or ""))
			LabelDefense:SizeToContents()
			LabelDefense.Think = function(this)
				local txt = v.Name..": "..tostring(pl.Skills[k])
				if txt == this:GetText() then return end
				this:SetText(txt)
				this:SizeToContents()
			end
			skillsForm:AddItem(LabelDefense)

			local Button = vgui.Create("DButton")
			Button:SetPos(50, 100)
			Button:SetSize(15, 20)
			Button:SetTextColor(color_black)
			Button:SetText("Increase "..v.Name.." by 1 point")
			Button:SetToolTip(v.Name.."\n\nIn Non-Endless Mode:\n"..v.Description..(v.DescriptionEndless and "\n\nIn Endless Mode:\n"..v.DescriptionEndless or ""))
			Button.DoClick = function(Button)
				net.Start("UpgradePerk")
				net.WriteString(k)
				net.WriteUInt(input.IsShiftDown() and 1e6 or 1, 32)
				net.SendToServer()
			end
			Button.DoDoubleClick = Button.DoClick
			Button.DoRightClick = function()
				Derma_StringRequest("Enter desired SP to apply on a skill", "", 1, function(str)
					net.Start("UpgradePerk")
					net.WriteString(k)
					net.WriteUInt(input.IsShiftDown() and 1e6 or 1, 32)
					net.SendToServer()
				end, nil, "Apply", "Cancel")
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
	timer.Simple(0, function()
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
	local pl = LocalPlayer()
	if self.AdminMode then
		SpawnMenuOpen(self)
	end
end

function GM:OnSpawnMenuClose()
	local pl = LocalPlayer()
	if self.AdminMode then
		SpawnMenuClose(self)
	end
end



function GM:OnContextMenuOpen()
	if self.AdminMode then
		ContextMenuOpen(self)
	else
		self:CMenu()
	end
end

function GM:OnContextMenuClose()
	
	if self.AdminMode then
		ContextMenuClose(self)
	elseif ContextMenu and ContextMenu:IsValid() then
		ContextMenu:Close()
	end
end


