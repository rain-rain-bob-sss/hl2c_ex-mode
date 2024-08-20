-- Include the required lua files
include( "cl_scoreboard_playerrow.lua" )


-- Start our new vgui element
local PANEL = {}


-- Apply the scheme of things
function PANEL:ApplySchemeSettings()

	self.nameLabel:SetFont( "DefaultSmall" )

	self.scoreLabel:SetFont( "DefaultSmall" )

	self.deathsLabel:SetFont( "DefaultSmall" )

	self.pingLabel:SetFont( "DefaultSmall" )

end


-- Called when our vgui element is created
function PANEL:Init()

	self.playerRows = {}

	self.nameLabel = vgui.Create( "DLabel", self )
	self.nameLabel:SetText( "Name" )

	self.scoreLabel = vgui.Create( "DLabel", self )
	self.scoreLabel:SetText( "Score" )

	self.deathsLabel = vgui.Create( "DLabel", self )
	self.deathsLabel:SetText( "Deaths" )

	self.pingLabel = vgui.Create( "DLabel", self )
	self.pingLabel:SetText( "Ping" )

end


-- Called every frame
function PANEL:Paint()

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawLine( 0, 13, self:GetWide(), 13 )

end


-- Does the actual layout
function PANEL:PerformLayout()

	self.nameLabel:SizeToContents()
	self.nameLabel:SetPos( 58, 0 )

	self.scoreLabel:SizeToContents()
	self.scoreLabel:SetPos( self:GetWide() - self.scoreLabel:GetWide() - 100, 0 )

	self.deathsLabel:SizeToContents()
	self.deathsLabel:SetPos( self:GetWide() - self.deathsLabel:GetWide() - 50, 0 )

	self.pingLabel:SizeToContents()
	self.pingLabel:SetPos( self:GetWide() - self.pingLabel:GetWide() - 5, 0 )

	local playerRowsSorted = {}
	for _, row in pairs( self.playerRows ) do
	
		table.insert( playerRowsSorted, row )
	
	end
	table.sort( playerRowsSorted, function( a, b ) return a:HigherOrLower( b ) end )

	local y = 15
	for _, row in ipairs( playerRowsSorted ) do
	
		if ( game.MaxPlayers() <= 10 ) then
		
			row:SetPos( 0, y )
			row:SetSize( self:GetWide(), 35 )
			row:UpdatePlayerRow()
			y = y + 35
		
		else
		
			row:SetPos( 0, y )
			row:SetSize( self:GetWide(), 20 )
			row:UpdatePlayerRow()
			y = y + 20
		
		end
	
	end

end


-- Updates the scoreboard
function PANEL:UpdatePlayerList()

	for ply, row in pairs( self.playerRows ) do
	
		if ( !IsValid( ply ) || ( ply:Team() != self.teamToList ) ) then
		
			row:Remove()
			self.playerRows[ ply ] = nil
		
		end
	
	end

	for _, ply in pairs( player.GetAll() ) do
	
		if ( !self.playerRows[ ply ] ) then
		
			local playerRow = vgui.Create( "scoreboard_playerrow", self )
			playerRow:SetPlayer( ply )
			self.playerRows[ ply ] = playerRow
		
		end
	
	end

	self:InvalidateLayout()

end


--- Register our scoreboard element
vgui.Register( "scoreboard_playerlist", PANEL, "DPanel" )
