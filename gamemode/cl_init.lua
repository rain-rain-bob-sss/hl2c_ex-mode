-- Include the required lua files
include("sh_init.lua")
include("sh_translate.lua")
include("cl_calcview.lua")
include("cl_playermodels.lua")
include("cl_scoreboard.lua")
include("cl_viewmodel.lua")
include("cl_net.lua")
include("cl_options.lua")

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


-- Called every frame to draw the hud
function GM:HUDPaint()
	if !GetConVar("cl_drawhud"):GetBool() || (self.ShowScoreboard && IsValid(LocalPlayer()) && (LocalPlayer():Team() != TEAM_DEAD)) then return end
	local timeleftmin = math.floor(timeleft / 60)
	local timeleftsec = timeleft - (timeleftmin * 60)

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
			draw.DrawText( tostring( checkpointDistance ).." m", "roboto16", checkpointPositionScreen.x, checkpointPositionScreen.y + 15, Color( 255, 220, 0, 255 ), 1 )
		else
			local r = math.Round( centerX / 2 )
			local checkpointPositionRad = math.atan2( checkpointPositionScreen.y - centerY, checkpointPositionScreen.x - centerX )
			local checkpointPositionDeg = 0 - math.Round( math.deg( checkpointPositionRad ) )
			surface.SetTexture( surface.GetTextureID( "hl2c_nav_pointer" ) )
			surface.DrawTexturedRectRotated( math.cos( checkpointPositionRad ) * r + centerX, math.sin( checkpointPositionRad ) * r + centerY, 32, 32, checkpointPositionDeg + 90 )
		end
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
	draw.SimpleText("Half-Life 2 Campaign: EX Mode "..GAMEMODE.Version, "TargetIDSmall", 5, 5, Color(255,255,192,255))
	surface.SetDrawColor(0, 0, 0, 0)
	draw.SimpleText(math.floor(XPGained * 100) / 100 .." XP gained", "TargetID", ScrW() / 2 + 15, (ScrH() / 2) + 15, Color(255,255,255,XPColor), 0, 1 )
	XPColor = XPColor - 3
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
	surface.CreateFont( "roboto16", { size = 16, weight = 400, antialias = true, additive = false, font = "Roboto" } )
	surface.CreateFont( "roboto16Bold", { size = 16, weight = 700, antialias = true, additive = false, font = "Roboto Bold" } )
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


-- Called when a bind is pressed
function GM:PlayerBindPress( ply, bind, down )
	if bind == "+menu" && down then
		RunConsoleCommand( "lastinv" )
		return true
	end

	if bind == "+menu_context" && down then
		hook.Call( "OpenPlayerModelMenu", GAMEMODE )
		return true
	end

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
end
net.Receive("RestartMap", RestartMap)


-- Called by show help
function ShowHelp(len)
	local helpText = "-= ABOUT THIS GAMEMODE =-\nWelcome to Half-Life 2 Campaign EX!\nThis gamemode is based on Half-Life 2 Campaign made by Jai 'Choccy' Fox,\nwith new stuff like Leveling, Skills and more!\n\n-= KEYBOARD SHORTCUTS =-\n[F1] (Show Help) - Opens this menu.\n[F2] (Show Team) - Toggles the navigation marker on your HUD.\n[F3] (Spare 1) - Spawns a vehicle if allowed.\n[F4] (Spare 2) - Removes a vehicle if you have one.\n\n-= OTHER NOTES =-\nOnce you're dead you cannot respawn until the next map.\nNot only Difficulty increases alongside with the player count, but also XP gaining multiplier.\nCurrent diffiulty: "..math.Round(difficulty * 100).."% of normal level"
	
	local helpEXMode = GAMEMODE.EXMode and "EX Mode is enabled! Expect Map objectives, NPC variants and chaos here!" or "EX Mode is disabled!"

	local helpMenu = vgui.Create("DFrame")
	local helpPanel = vgui.Create("DPanel", helpMenu)
	local helpLabel = vgui.Create("DLabel", helpPanel)
	local helpButton1 = vgui.Create("DButton", helpPanel)
	local helpButton2 = vgui.Create("DButton", helpPanel)
	local helpButton3 = vgui.Create("DButton", helpPanel)

	helpLabel:SetText(helpText.."\n"..helpEXMode)
	helpLabel:SetTextColor(GAMEMODE.EXMode and Color(224,48,48,255) or Color(0,64,0,255))
	helpLabel:SetPos(7, 5)
	helpLabel:SizeToContents()
	
	local w, h = helpLabel:GetSize()
	helpMenu:SetSize(math.max(380, w + 13), math.max(259, h + 103))
	helpPanel:StretchToParent( 5, 28, 5, 5 )

	helpButton1:SetPos(10,helpPanel:GetTall() - 35)
	helpButton1:SetText("Stats")
	helpButton1.DoClick = function()
		gamemode.Call("ShowStats")
		helpMenu:Remove()
	end
	helpButton2:SetPos(110,helpPanel:GetTall() - 35)
	helpButton2:SetText("Skills")
	helpButton2.DoClick = function()
		gamemode.Call("ShowSkills")
		helpMenu:Remove()
	end
	helpButton3:SetPos(210,helpPanel:GetTall() - 35)
	helpButton3:SetText("Options")
	helpButton3.DoClick = function()
		gamemode.Call("MakeOptions")
		helpMenu:Remove()
	end
	
	
	helpMenu:SetTitle( "Help" )
	helpMenu:Center()
	helpMenu:MakePopup()
end
net.Receive("ShowHelp", ShowHelp)

function GM:ShowStats()
	local statsMenu = vgui.Create("DFrame")
	local statsPanel = vgui.Create("DPanel", statsMenu)
	local statsText1 = vgui.Create("DLabel", statsPanel)
	local statsText2 = vgui.Create("DLabel", statsPanel)

	statsText1:SetText("Your XP: "..math.floor(myxp).." / "..self:GetReqXP())
	statsText1:SetTextColor(color_black)
	statsText1:SetPos(5, 5)
	statsText1:SizeToContents()

	statsText2:SetText("Your Level: "..math.floor(mylvl))
	statsText2:SetTextColor(color_black)
	statsText2:SetPos(5, 20)
	statsText2:SizeToContents()


	statsMenu:SetSize(233, 133)

	statsPanel:StretchToParent( 5, 28, 5, 5 )

	statsMenu:SetTitle("Your Stats")
	statsMenu:Center()
	statsMenu:MakePopup()
end

function GM:ShowSkills()
	local skillsMenu = vgui.Create("DFrame")
	local skillsPanel = vgui.Create("DPanel", skillsMenu)
	local skillsText = vgui.Create("DLabel", skillsPanel)
	local skillsForm = vgui.Create("DPanelList", skillsPanel)

	skillsText:SetText("Unspent skill points: "..math.floor(myskillpts))
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
		for k, v in SortedPairs(Perks) do
			local LabelDefense = vgui.Create("DLabel")
			LabelDefense:SetPos(50, 50)
			LabelDefense:SetText(translate.Get(k)..": "..v)
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
						skillsText:SetText("Unspent skill points: "..myskillpts)
					end
				end)
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
		net.Start("UpdateStats")
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
