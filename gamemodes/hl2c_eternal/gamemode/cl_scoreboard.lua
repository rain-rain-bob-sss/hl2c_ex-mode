-- Include the required lua files
include( "cl_scoreboard_playerlist.lua" )


-- Start our new vgui element
local PANEL = {}


-- Apply the scheme of things
function PANEL:ApplySchemeSettings()

	self.hostnameLabel:SetFont( "Roboto16" )
	self.hostnameLabel:SetTextColor( Color( 255, 220, 0, 255 ) )

	self.numPlayersLabel:SetFont( "Roboto16" )
	self.numPlayersLabel:SetTextColor( Color( 255, 220, 0, 255 ) )

end


-- Called when our vgui element is created
function PANEL:Init()

	self.hostnameLabel = vgui.Create( "DLabel", self )

	self.numPlayersLabel = vgui.Create( "DLabel", self )

	self.playerList = vgui.Create( "scoreboard_playerlist", self )

	self:UpdateScoreboard()
	timer.Create( "hl2c_scoreboard_updater", 3, 0, function() self:UpdateScoreboard() end )

end


-- Called every frame
function PANEL:Paint()

	draw.RoundedBox( 10, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color( 0, 0, 0, 159 ) )

end


-- Does the actual layout
function PANEL:PerformLayout()

	self:SetSize( ScrW() * 0.85, ScrH() * 0.85 )
	self:SetPos( ( ScrW() - self:GetWide() ) / 2, ( ScrH() - self:GetTall() ) / 2 )

	self.hostnameLabel:SizeToContents()
	self.hostnameLabel:SetPos( 10, 5 )

	self.numPlayersLabel:SizeToContents()
	self.numPlayersLabel:SetPos( self:GetWide() - self.numPlayersLabel:GetWide() - 10, 5 )

	self.playerList:SetPos( 5, 30 )
	self.playerList:SetSize( self:GetWide() - 10, self:GetTall() - 10 )

end


-- Updates the scoreboard
function PANEL:UpdateScoreboard( force )

	if ( !force && !self:IsVisible() ) then return end

	self.hostnameLabel:SetText( GetHostName().." ("..GAMEMODE.Name.." ["..GAMEMODE.Version.."])" )

	local numPlayers = player.GetCount()
	if ( numPlayers == 1 ) then
	
		--self.numPlayersLabel:SetText( "1 Player" )
		self.numPlayersLabel:SetText( translate.Get("scoreboard_singleplayer") )
	
	else
	
		--self.numPlayersLabel:SetText( numPlayers.." Players" )
		self.numPlayersLabel:SetText( translate.Format("scoreboard_players",numPlayers) )
	
	end

	self:InvalidateLayout()

	self.playerList:UpdatePlayerList()

end


-- Register our scoreboard element
vgui.Register( "scoreboard", PANEL, "DPanel" )
