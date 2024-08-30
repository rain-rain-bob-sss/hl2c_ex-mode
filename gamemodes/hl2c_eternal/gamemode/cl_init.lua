-- Include the required lua files
include("sh_translate.lua")
include("sh_init.lua")
include("cl_calcview.lua")
include("cl_playermodels.lua")
include("cl_scoreboard.lua")
include("cl_viewmodel.lua")
include("cl_net.lua")
include("cl_options.lua")
include("cl_perksmenu.lua")
include("cl_prestige.lua")

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

local navmatmarker=CreateMaterial("NAV_MARKER","UnlitGeneric",{
	["$basetexture"]="decals/lambdaspray_2a",
	["$translucent"]=1,
})
local navmatpoint=navmatmarker
local astart=CurTime()
local adur=0.1
local last="onscreen"
-- Called every frame to draw the hud
function GM:HUDPaint()
	if !GetConVar("cl_drawhud"):GetBool() || (self.ShowScoreboard && IsValid(LocalPlayer()) && (LocalPlayer():Team() != TEAM_DEAD)) then return end
	local timeleftmin = math.floor(timeleft / 60)
	local timeleftsec = timeleft - (timeleftmin * 60)
	local pl = LocalPlayer()

	if timeleft != nil and timeleft > 0 then
		draw.SimpleText(translate.Function("ObjectiveTimeLeft",timeleftsec,timeleftmin,timeleft), "TargetIDSmall", 5, 22, Color(255,255,192,255))
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
		local r = math.Round( centerX / 2 )
		local checkpointPositionRad = math.atan2( checkpointPositionScreen.y - centerY, checkpointPositionScreen.x - centerX )
		local checkpointPositionDeg = 0 - math.Round( math.deg( checkpointPositionRad ) )
		local pointerx,pointery=math.cos( checkpointPositionRad ) * r + centerX, math.sin( checkpointPositionRad ) * r + centerY
		local markerx,markery=checkpointPositionScreen.x, checkpointPositionScreen.y
		if ( ( checkpointPositionScreen.x > 32 ) && ( checkpointPositionScreen.x < ( w - 43 ) ) && ( checkpointPositionScreen.y > 32 ) && ( checkpointPositionScreen.y < ( h - 38 ) ) ) then
			if last~="onscreen" then
				astart=CurTime()
			end
			surface.SetMaterial( navmatmarker )
			surface.DrawTexturedRect( Lerp((CurTime()-astart)/adur,pointerx,markerx) - 24, Lerp((CurTime()-astart)/adur,pointery,markery) - 24, 48, 48 )
			draw.DrawText( tostring( checkpointDistance ).." m", "Roboto16",checkpointPositionScreen.x, checkpointPositionScreen.y+15, Color( 255, 220, 0, 255 ), 1 )
			last="onscreen"
		else
			if last~="offscreen" then
				astart=CurTime()
			end
			surface.SetMaterial( navmatpoint )
			surface.DrawTexturedRectRotated( Lerp((CurTime()-astart)/adur,markerx,pointerx),Lerp((CurTime()-astart)/adur,markery,pointery), 48, 48, checkpointPositionDeg + 90 )
			last="offscreen"
		end
	end

	if self.DifficultyDifferenceTimeChange==nil then self.DifficultyDifferenceTimeChange=0 end
	local colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (self.DifficultyDifference < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0, 155) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0, 155)) or Color(255, 220, 0, 155)
	draw.DrawText(translate.Format("Difficulty",FormatNumber(math.Round(self:GetDifficulty() * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6, colordifference, TEXT_ALIGN_CENTER )
	if self.DifficultyDifferenceTimeChange + 3 >= CurTime() then
		colordifference.a = (self.DifficultyDifferenceTimeChange+3-CurTime())*155/3
		draw.DrawText(Format("%s%s%%", self.DifficultyDifference < 0 and "-" or "+", math.abs(math.Round(self.DifficultyDifference * 100, 2))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 + 15, colordifference, TEXT_ALIGN_CENTER )

		if self.DifficultyDifference ~= self.DifficultyDifferenceTotal then
			colordifference = self.DifficultyDifferenceTimeChange + 3 >= CurTime() and (self.DifficultyDifferenceTotal < 0 and Color(255, 220-((self.DifficultyDifferenceTimeChange+3-CurTime())*110), 0, colordifference.a) or Color(255-((self.DifficultyDifferenceTimeChange+3-CurTime())*255/2), 220, 0, colordifference.a)) or Color(255, 220, 0, colordifference.a)
			draw.DrawText(translate.Format("DifficultyTotal",tostring(self.DifficultyDifferenceTotal < 0 and "-" or "+"..math.abs(math.Round(self.DifficultyDifferenceTotal * 100, 2)))), "TargetIDSmall", ScrW() / 2, ScrH() / 6 + 30, colordifference, TEXT_ALIGN_CENTER )
		end
	end

	if pl:Alive() and pl:IsSuitEquipped() then
		local hp,ap = pl:Health(),pl:Armor()
		local mhp,map = pl:GetMaxHealth(), pl:GetMaxArmor()

		draw.DrawText(translate.Format("Health", pl:Health(), pl:GetMaxHealth(), hp/mhp*100), "TargetIDSmall", 16, ScrH()-100, Color(255,155,155,255), TEXT_ALIGN_LEFT)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(15, ScrH() - 80, 200, 10)
		surface.SetDrawColor(205, 25, 25, 255)
		surface.DrawRect(16, ScrH() - 79, 198*math.Clamp(hp/mhp,0,1), 10)

		draw.DrawText(translate.Format("Armor", pl:Armor(), pl:GetMaxArmor(), ap/map*100), "TargetIDSmall", 16, ScrH()-60, Color(155,155,255,255), TEXT_ALIGN_LEFT)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(15, ScrH() - 40, 200, 10)
		surface.SetDrawColor(25, 25, 205, 255)
		surface.DrawRect(16, ScrH() - 39, 198*math.Clamp(ap/map,0,1), 10)
	end

	
	-- Are we going to the next map?
	if nextMapCountdownStart then
		local nextMapCountdownLeft = math.Round( nextMapCountdownStart + NEXT_MAP_TIME - CurTime() )
		local nextmapin=translate.Format("NextMapIn",nextMapCountdownLeft)
		local switching=translate.Get("SwitchingMap")
		draw.SimpleTextOutlined(nextMapCountdownLeft > 0 and nextmapin or switching, "roboto32BlackItalic", centerX, h - h * 0.075, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ) )
	end

	-- Are we restarting the map?
	if restartMapCountdownStart then
		local restartMapCountdownLeft = math.ceil( restartMapCountdownStart + RESTART_MAP_TIME - CurTime() )
		local restartmapin=translate.Format("RestartMapIn",restartMapCountdownLeft)
		draw.SimpleTextOutlined(restartMapCountdownLeft > 0 and restartmapin or translate.Get("Restarting"), "roboto32BlackItalic", centerX, h - h * 0.075, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ) )
	end

	-- On top of it all
	hook.Run("DrawDeathNotice", 0.85, 0.04)
end


function GM:PostDrawHUD()
	cam.Start2D()
	-- draw.SimpleText(self.Name.." "..self.Version, "TargetIDSmall", 5, 5, Color(255,255,192,25))
	surface.SetDrawColor(0, 0, 0, 0)

	if XPColor > 0 then
		draw.SimpleText(translate.Format("XPGained",tostring(math.Round(XPGained, 2))), "TargetID", ScrW() / 2 + 15, (ScrH() / 2) + 15, Color(255,255,255,XPColor), 0, 1 )
		if XPGainedTotal ~= XPGained then
			draw.SimpleText(translate.Format("TotalXPGained",tostring(math.Round(XPGainedTotal, 2))), "TargetIDSmall", ScrW() / 2 + 15, (ScrH() / 2) + 30, Color(255,255,205,XPColor), 0, 1 )
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


	ply.UnlockedPerks = {}
	ply.DisabledPerks = {}
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
		table.insert(tab, translate.Get("Dead_Chat"))
	end

	if ( team ) then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, translate.Get("TEAM_Chat"))
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
		table.insert( tab, translate.Get("Console") )
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
	local helpText = translate.Get("HelpText")
	
	local helpEXMode = GAMEMODE.EXMode and translate.Get("HelpEXModeOn") or translate.Get("HelpEXModeOff")
	local helpEndlessMode = GAMEMODE.EndlessMode and translate.Get("HelpEndlessOn") or translate.Get("HelpEndlessOff")

	local helpMenu = vgui.Create("DFrame")
	local helpPanel = vgui.Create("DPanel", helpMenu)
	local helpLabel = vgui.Create("DLabel", helpPanel)
	local helpLabel2 = vgui.Create("DLabel", helpPanel)
	local adminbutton
	local pl = LocalPlayer()

	if pl:IsAdmin() then
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
		adminbutton:SetText(translate.Get("AMode"))
		adminbutton:SetTextColor(Color(0,0,255))
		adminbutton.DoClick = function()
			GAMEMODE.AdminMode = !GAMEMODE.AdminMode

			chat.AddText(GAMEMODE.AdminMode and translate.Get("AModeOn") or translate.Get("AModeOff"))

			helpMenu:Remove()
		end
		adminbutton.Paint = function(self, width, height)
			surface.SetDrawColor(Color(0,0,155,100))
			surface.DrawRect(0, 0, width, height)
		end
	end
	
	helpMenu:SetTitle( translate.Get("Help") )
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

	local GetUnspentText=function()
		return translate.Format("UnspentSP",tostring(math.floor(pl.StatPoints)))
	end

	skillsText:SetText(GetUnspentText())
	skillsText:SetTextColor(color_black)
	skillsText:SetPos(5, 5)
	skillsText:SizeToContents()
	skillsText.Think = function(this)
		local txt = GetUnspentText()
		if txt == this:GetText() then return end
		this:SetText(txt)
		this:SizeToContents()
	end

	skillsText2:SetText(translate.Get("SpendDesiredSP"))
	skillsText2:SetTextColor(color_black)
	skillsText2:SetPos(5, 20)
	skillsText2:SizeToContents()

	skillsText3:SetText(translate.Get("SpendAllSP"))
	skillsText3:SetTextColor(color_black)
	skillsText3:SetPos(5, 35)
	skillsText3:SizeToContents()

	skillsMenu:SetSize(293, 263)

	skillsPanel:StretchToParent( 5, 28, 5, 5 )

	skillsMenu:SetTitle(translate.Get("YourSkills"))
	skillsMenu:Center()
	skillsMenu:MakePopup()

	skillsForm:SetSize(278, 175)
	skillsForm:SetPos(5, 50)
	skillsForm:EnableVerticalScrollbar(true)
	skillsForm:SetSpacing(8) 
	skillsForm:SetName("")
	skillsForm.Paint = function() end

	local function DoStatsList()
		for k, v in SortedPairs(self.SkillsInfo) do

			--TODO:Translate these

			local LabelDefense = vgui.Create("DLabel")
			LabelDefense:SetPos(50, 50)
			LabelDefense:SetText(v.Name..": "..tostring(pl["Stat"..k] or 0))
			LabelDefense:SetTextColor(color_black)
			LabelDefense:SetToolTip(v.Name..translate.Get("NonEndlessDesc")..v.Description..(v.DescriptionEndless and translate.Get("EndlessDesc")..v.DescriptionEndless or ""))
			LabelDefense:SizeToContents()
			LabelDefense.Think = function(this)
				local txt = v.Name..": "..tostring(pl["Stat"..k] or 0)
				if txt == this:GetText() then return end
				this:SetText(txt)
				this:SizeToContents()
			end
			skillsForm:AddItem(LabelDefense)

			local Button = vgui.Create("DButton")
			Button:SetPos(50, 100)
			Button:SetSize(15, 20)
			Button:SetTextColor(color_black)
			Button:SetText(translate.Format("SkillIncrease",v.Name))
			Button:SetToolTip(v.Name..translate.Get("NonEndlessDesc")..v.Description..(v.DescriptionEndless and translate.Get("EndlessDesc")..v.DescriptionEndless or ""))
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
					net.WriteUInt(tonumber(str) or 1, 32)
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

function GM:DiedBy(class)
	local clr=table.HasValue(FRIENDLY_NPCS,class) and Color(0,255,0) or Color(255,0,0)
	chat.AddText(clr,translate.Format("DiedBy",language.GetPhrase(class)))
end
