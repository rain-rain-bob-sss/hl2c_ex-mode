-- Start our new vgui element
local PANEL = {}


-- Apply the scheme of things
function PANEL:ApplySchemeSettings()

	self.nameLabel:SetFont( "roboto16Bold" )

	self.statusLabel:SetFont( "roboto16Bold" )

	self.scoreLabel:SetFont( "roboto16Bold" )

	self.deathsLabel:SetFont( "roboto16Bold" )

	self.pingLabel:SetFont( "roboto16Bold" )

end


-- Figures out where to place itself
function PANEL:HigherOrLower( row )

	if ( !self.ply:IsValid() || ( self.ply:Team() == TEAM_CONNECTING ) ) then return false end
	if ( !row.ply:IsValid() || ( row.ply:Team() == TEAM_CONNECTING ) ) then return true end

	if ( self.ply:Frags() == row.ply:Frags() ) then
	
		return self.ply:Deaths() < row.ply:Deaths()
	
	end

	return self.ply:Frags() > row.ply:Frags()

end


-- Called when our vgui element is created
function PANEL:Init()

	self.ply = 0

	if ( game.MaxPlayers() <= 10 ) then
		
		self.posX = 78
		self.posY = 9
		self.avatarX = 43
		self.avatarY = 1
		self.SpecialImageX = 26
		self.SpecialImageY = 9
		self.avatarSize = 32
		self.SpecialImageSize = 16
	
	else
	
		self.posX = 78
		self.posY = 2
		self.avatarX = 58
		self.avatarY = 2
		self.SpecialImageX = 26
		self.SpecialImageY = 2
		self.avatarSize = 16
		self.SpecialImageSize = 16

	end

	self.muteIcon = vgui.Create( "DImageButton", self )
	self.muteIcon.DoClick = function() self.ply:SetMuted( !self.ply:IsMuted() ) end

	self.avatarImage = vgui.Create( "AvatarImage", self )

	self.SpecialImage = vgui.Create("DImage", self)

	self.nameLabel = vgui.Create( "DLabel", self )

	self.statusLabel = vgui.Create( "DLabel", self )

	self.scoreLabel = vgui.Create( "DLabel", self )

	self.deathsLabel = vgui.Create( "DLabel", self )

	self.pingLabel = vgui.Create( "DLabel", self )

end


-- Called every frame
function PANEL:Paint()
	if ( !IsValid( self.ply ) ) then return end
	if ( LocalPlayer() == self.ply ) then
		surface.SetDrawColor( Color( 125, 125, 125, 75 ) )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
end


-- Does the actual layout
function PANEL:PerformLayout()

	self.muteIcon:SetPos( 5, self.posY )
	self.muteIcon:SetSize( 16, 16 )
	self.muteIcon:SetToolTip("Mute player")

	self.avatarImage:SetPos( self.avatarX, self.avatarY )
	self.avatarImage:SetSize( self.avatarSize, self.avatarSize )

	self.SpecialImage:SetPos(self.SpecialImageX, self.SpecialImageY)
	self.SpecialImage:SetSize(self.SpecialImageSize, self.SpecialImageSize)
	self.SpecialImage:SetMouseInputEnabled(true)
	self.SpecialImage:SetVisible(false)

	if gamemode.Call("IsSpecialPerson", self.ply, self.SpecialImage) then
		self.SpecialImage:SetVisible(true)
	else
		self.SpecialImage:SetTooltip()
		self.SpecialImage:SetVisible(false)
	end

	self.nameLabel:SizeToContents()
	self.nameLabel:SetPos( self.posX, self.posY )

	self.statusLabel:SizeToContents()
	self.statusLabel:SetPos( self:GetWide() - self.statusLabel:GetWide() - 200, self.posY )

	self.scoreLabel:SizeToContents()
	self.scoreLabel:SetPos( self:GetWide() - self.scoreLabel:GetWide() - 100, self.posY )

	self.deathsLabel:SizeToContents()
	self.deathsLabel:SetPos( self:GetWide() - self.deathsLabel:GetWide() - 50, self.posY )

	self.pingLabel:SizeToContents()
	self.pingLabel:SetPos( self:GetWide() - self.pingLabel:GetWide() - 5, self.posY )

end


-- Sets the player in question
function PANEL:SetPlayer( ply )

	self.ply = ply
	self.avatarImage:SetPlayer( ply )

	if ( self.ply == LocalPlayer() ) then
	
		self.muteIcon:SetEnabled( false )
	
	end

end


-- Updates the scoreboard
function PANEL:UpdatePlayerRow()

	if ( self.ply:IsMuted() ) then
		self.muteIcon:SetIcon( "icon16/sound_mute.png" )
	else
		self.muteIcon:SetIcon( "icon16/sound.png" )
	end

	self.nameLabel:SetText( self.ply:Name() )

	if ( self.ply:Team() != TEAM_ALIVE ) then
	
		self.statusLabel:SetText( team.GetName( self.ply:Team() ) )
	
	else
	
		self.statusLabel:SetText( "" )
	
	end

	self.scoreLabel:SetText( self.ply:Frags() )
	self.deathsLabel:SetText( self.ply:Deaths() )
	self.pingLabel:SetText( self.ply:Ping() )

	self:InvalidateLayout()

end


-- Register our scoreboard element
vgui.Register( "scoreboard_playerrow", PANEL, "DPanel" )
