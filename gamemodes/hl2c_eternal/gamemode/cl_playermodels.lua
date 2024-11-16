-- The playermodel menu from Sandbox!

-- Create some client console variables
local cl_playercolor = CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
local cl_playerskin = CreateConVar( "cl_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any" )
local cl_playerbodygroups = CreateConVar( "cl_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any" )

-- Default animations
local default_animations = { "idle_all_01", "menu_walk" }

-- Global variable that defines whether the custom playermodel menu is available or not
CUSTOM_PLAYERMODEL_MENU_ENABLED = false
local hl2c_server_custom_playermodels = CreateConVar("hl2c_server_custom_playermodels", 0, FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

-- Opens the menu
function GM:OpenPlayerModelMenu()

	-- Prevent opening the menu
	if ( !hl2c_server_custom_playermodels:GetBool() || OVERRIDE_PLAYERMODEL_MENU ) then
		chat.AddText( Color( 255, 0, 0 ), "Player Model menu is disabled!" )
		return
	end

	-- Window frame
	local window = vgui.Create( "DFrame" )
	window:SetTitle( "Player Model" )
	window:SetSize( math.min( ScrW() - 16, 960 ), math.min( ScrH() - 16, 700 ) )
	window:Center()
	window:MakePopup()

	-- Window frame closed
	function window:OnClose()
	
		net.Start( "UpdatePlayerModel" )
		net.SendToServer()
	
	end

	-- Model panel
	local mdl = window:Add( "DModelPanel" )
	mdl:Dock( FILL )
	mdl:SetFOV( 36 )
	mdl:SetCamPos( Vector( 0, 0, 0 ) )
	mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	mdl:SetAnimated( true )
	mdl.Angles = Angle( 0, 0, 0 )
	mdl:SetLookAt( Vector( -100, 0, -22 ) )

	-- Property sheet
	local sheet = window:Add( "DPropertySheet" )
	sheet:Dock( RIGHT )
	sheet:SetSize( 430, 0 )

	-- Panel select
	local PanelSelect = sheet:Add( "DPanelSelect" )

	-- Fill the panel select
	for name, model in SortedPairs( player_manager.AllValidModels() ) do
	
		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( name )
		icon.playermodel = name
	
		PanelSelect:AddPanel( icon, { cl_playermodel = name } )
	
	end

	-- Add Model to the property sheet
	sheet:AddSheet( "Model", PanelSelect, "icon16/user.png" )

	-- Controls panel
	local controls = window:Add( "DPanel" )
	controls:DockPadding( 8, 8, 8, 8 )

	-- Player color label
	local lbl = controls:Add( "DLabel" )
	lbl:SetText( "Player color" )
	lbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	lbl:Dock( TOP )

	-- Player color mixer
	local plycol = controls:Add( "DColorMixer" )
	plycol:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )
	plycol:SetAlphaBar( false )
	plycol:SetPalette( false )
	plycol:Dock( TOP )
	plycol:SetSize( 200, math.min( window:GetTall() / 3, 260 ) )

	-- Add Colors to the property sheet
	sheet:AddSheet( "Colors", controls, "icon16/color_wheel.png" )

	-- Body group controls
	local bdcontrols = window:Add( "DPanel" )
	bdcontrols:DockPadding( 8, 8, 8, 8 )

	-- Body group panel list
	local bdcontrolspanel = bdcontrols:Add( "DPanelList" )
	bdcontrolspanel:EnableVerticalScrollbar( true )
	bdcontrolspanel:Dock( FILL )

	-- Add Bodygroups to the property sheet
	local bgtab = sheet:AddSheet( "Bodygroups", bdcontrols, "icon16/cog.png" )


	--[[
		Helper Functions
	]]--

	-- Make names nicer, the ugly way
	local function MakeNiceName( str )
	
		local newname = {}
	
		for _, s in pairs( string.Explode( "_", str ) ) do
		
			if ( string.len( s ) == 1 ) then table.insert( newname, string.upper( s ) ); continue; end
			table.insert( newname, string.upper( string.Left( s, 1 ) ) .. string.Right( s, string.len( s ) - 1 ) )
		
		end

		return string.Implode( " ", newname )
	
	end

	-- Plays the preview animation
	local function PlayPreviewAnimation( panel, playermodel )
	
		if ( !panel || !IsValid( panel.Entity ) ) then return; end
	
		local anims = list.Get( "PlayerOptionsAnimations" )
	
		local anim = default_animations[ math.random( 1, #default_animations ) ]
		if ( anims[ playermodel ] ) then
		
			anims = anims[ playermodel ]
			anim = anims[ math.random( 1, #anims ) ]
		
		end
	
		local iSeq = panel.Entity:LookupSequence( anim )
		if ( iSeq > 0 ) then panel.Entity:ResetSequence( iSeq ); end
	
	end

	-- Update body groups
	local function UpdateBodyGroups( pnl, val )
	
		if ( pnl.type == "bgroup" ) then
		
			mdl.Entity:SetBodygroup( pnl.typenum, math.Round( val ) )
		
			local str = string.Explode( " ", GetConVarString( "cl_playerbodygroups" ) )
			if ( #str < pnl.typenum + 1 ) then for i = 1, ( pnl.typenum + 1 ) do str[ i ] = str[ i ] || 0; end; end
			str[ pnl.typenum + 1 ] = math.Round( val )
			RunConsoleCommand( "cl_playerbodygroups", table.concat( str, " " ) )
		
		elseif ( pnl.type == "skin" ) then
		
			mdl.Entity:SetSkin( math.Round( val ) )
			RunConsoleCommand( "cl_playerskin", math.Round( val ) )
		
		end
	
	end

	-- Rebuilds the body group tab
	local function RebuildBodygroupTab()
	
		bdcontrolspanel:Clear()
	
		bgtab.Tab:SetVisible( false )
	
		local nskins = mdl.Entity:SkinCount() - 1
		if ( nskins > 0 ) then
		
			local skins = vgui.Create( "DNumSlider" )
			skins:Dock( TOP )
			skins:SetText( "Skin" )
			skins:SetDark( true )
			skins:SetTall( 50 )
			skins:SetDecimals( 0 )
			skins:SetMax( nskins )
			skins:SetValue( GetConVarNumber( "cl_playerskin" ) )
			skins.type = "skin"
			skins.OnValueChanged = UpdateBodyGroups
		
			bdcontrolspanel:AddItem( skins )
		
			mdl.Entity:SetSkin( GetConVarNumber( "cl_playerskin" ) )
		
			bgtab.Tab:SetVisible( true )
		
		end
	
		local groups = string.Explode( " ", GetConVarString( "cl_playerbodygroups" ) )
		for k = 0, ( mdl.Entity:GetNumBodyGroups() - 1 ) do
		
			if ( mdl.Entity:GetBodygroupCount( k ) <= 1 ) then continue; end
		
			local bgroup = vgui.Create( "DNumSlider" )
			bgroup:Dock( TOP )
			bgroup:SetText( MakeNiceName( mdl.Entity:GetBodygroupName( k ) ) )
			bgroup:SetDark( true )
			bgroup:SetTall( 50 )
			bgroup:SetDecimals( 0 )
			bgroup.type = "bgroup"
			bgroup.typenum = k
			bgroup:SetMax( mdl.Entity:GetBodygroupCount( k ) - 1 )
			bgroup:SetValue( groups[ k + 1 ] or 0 )
			bgroup.OnValueChanged = UpdateBodyGroups
		
			bdcontrolspanel:AddItem( bgroup )
		
			mdl.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
		
			bgtab.Tab:SetVisible( true )
		
		end
	
	end

	-- Update from Console Variables
	local function UpdateFromConvars()
	
		local model = LocalPlayer():GetInfo( "cl_playermodel" )
		local modelname = player_manager.TranslatePlayerModel( model )
		util.PrecacheModel( modelname )
		mdl:SetModel( modelname )
		mdl.Entity.GetPlayerColor = function() return Vector( GetConVarString( "cl_playercolor" ) ); end
		mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
	
		plycol:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )
	
		PlayPreviewAnimation( mdl, model )
		RebuildBodygroupTab()
	
	end

	-- Update from Controls
	local function UpdateFromControls()
	
		RunConsoleCommand( "cl_playercolor", tostring( plycol:GetVector() ) )
	
	end

	-- Value Changed
	plycol.ValueChanged = UpdateFromControls

	-- Call UpdateFromConvars
	UpdateFromConvars()

	-- The active panel was changed
	function PanelSelect:OnActivePanelChanged( old, new )
	
		if ( old != new ) then
		
			RunConsoleCommand( "cl_playerbodygroups", "0" )
			RunConsoleCommand( "cl_playerskin", "0" )
		
		end
	
		timer.Simple( 0.1, function() UpdateFromConvars(); end )
	
	end

	-- Mouse is pressed
	function mdl:DragMousePress()
	
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	
	end

	-- Mouse was released
	function mdl:DragMouseRelease() self.Pressed = false; end

	-- Update the model layout
	function mdl:LayoutEntity( ent )
	
		if ( self.bAnimated ) then self:RunAnimation(); end
	
		if ( self.Pressed ) then
		
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
		
			self.PressX, self.PressY = gui.MousePos()
		
		end
	
		ent:SetAngles( self.Angles )
	
	end

end


-- Player Model animations
list.Set( "PlayerOptionsAnimations", "gman", { "menu_gman" } )

list.Set( "PlayerOptionsAnimations", "hostage01", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage02", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage03", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage04", { "idle_all_scared" } )

list.Set( "PlayerOptionsAnimations", "zombine", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "corpse", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "zombiefast", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "zombie", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "skeleton", { "menu_zombie_01" } )

list.Set( "PlayerOptionsAnimations", "combine", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "combineprison", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "combineelite", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "police", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "policefem", { "menu_combine" } )

list.Set( "PlayerOptionsAnimations", "css_arctic", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_gasmask", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_guerilla", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_leet", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_phoenix", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_riot", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_swat", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_urban", { "pose_standing_02", "idle_fist" } )
