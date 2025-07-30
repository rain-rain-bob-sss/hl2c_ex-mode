-- tbh this was just edit of weapon_medkit weapon for it to fit with the hl2c EX gamemode
AddCSLuaFile()

SWEP.Base = "weapon_medkit"
SWEP.PrintName = "HL2c Medkit"
SWEP.Author = "Uklejamini"
--SWEP.Purpose = "Heal people with your primary attack."
SWEP.Purpose = translate.Get("medkit_purpose")
--SWEP.Instructions = "Effectiveness is increased by 2% per Medical skill point, max efficiency 120%. Remember, healing other players will give you 1/4 of health you heal!"
SWEP.Instructions=translate.Get("medkit_instructions")

SWEP.Slot = 5
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_medkit.mdl")
SWEP.WorldModel = Model("models/weapons/w_medkit.mdl")
SWEP.ViewModelFOV = 70
SWEP.UseHands = true

SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.HealAmount = 6
--uhhhehmmm local loooooooooooooooooocaaaaaaaaaaaaaaaaaaaaaaallllllllllllllllllllllll
local MaxAmmo = 150 -- Max ammo
SWEP.CanUseInCitadel=true

local HealSound = Sound( "HealthKit.Touch" )
local DenySound = Sound( "WallHealth.Deny" )

function SWEP:Initialize()
	self:SetHoldType( "slam" )

	if CLIENT then return end

	timer.Create("hl2ce_medkit_ammo"..self:EntIndex(), 2, 0, function()
		if IsValid(self) && (self:Clip1() < self:MaxAmmo()) then self:SetClip1(math.min(self:Clip1() + self:GetRegenAmount(), self:MaxAmmo())) end
	end)
end

function SWEP:GetRegenAmount()
	local ply=self:GetOwner()
	if not IsValid(ply) then return 0 end
	return 4*(1 + (GAMEMODE.EndlessMode and 0.1 or 0.02)*ply:GetSkillAmount("Surgeon"))
end

function SWEP:MaxAmmo()
	local maxammo=MaxAmmo
	local ply=self:GetOwner()
	if not IsValid(ply) then return maxammo end
	maxammo = maxammo*(1 + (GAMEMODE.EndlessMode and 0.1 or 0.02)*ply:GetSkillAmount("Surgeon"))
	return maxammo
end

local hullvec=Vector(15,15,15)
local hullmin=-hullvec
local hullmax=hullvec
local dist=72
local ffunc=function(ent)
	return (ent:IsNPC() or ent:IsPlayer()) and ent:Health()<ent:GetMaxHealth()
end
function SWEP:PrimaryAttack()
	if CLIENT then return end

	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(true)
	end

	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * dist,
		filter = function(e) return e~=self.Owner and ffunc(e) end,
		mins=hullmin,
		maxs=hullmax
	} )

	if ( self.Owner:IsPlayer() ) then
		self.Owner:LagCompensation( false )
	end

	local ent = tr.Entity

	local need = self.HealAmount + (self.HealAmount * ((GAMEMODE.EndlessMode and 0.05 or 0.02) * self.Owner:GetSkillAmount("Medical")))
	if ( IsValid( ent ) ) then need = math.min( ent:GetMaxHealth() - ent:Health(), self.HealAmount + (self.HealAmount * ((GAMEMODE.EndlessMode and 0.05 or 0.02) * self.Owner:GetSkillAmount("Medical"))) ) end

	if ( IsValid( ent ) && self:Clip1() >= need && ( ent:IsPlayer() or ent:IsNPC() ) && ent:Health() < ent:GetMaxHealth() ) then

		self:TakePrimaryAmmo(need)
		ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + need))
		if self.Owner:HasPerkActive("medkit_charging") and SERVER and ent:IsPlayer() then
			ent:SetArmor(math.min(ent:GetMaxArmor(),ent:Armor() + need * 0.5))
		end
		if ent:IsPlayer() then
			self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(), self.Owner:Health() + need * 0.25))
			self.Owner:GiveXP(need * 0.35)
		elseif ent:IsFriendlyNPC() then
			self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(), self.Owner:Health() + need * 0.2))
			self.Owner:GiveXP(need * 0.28)
		end

		ent:EmitSound( HealSound )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextPrimaryFire( CurTime() + 0.1 )
		self:SetNextSecondaryFire( CurTime() + 0.1 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		-- Even though the viewmodel has looping IDLE anim at all times, we need this to make fire animation work in multiplayer
		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		self.Owner:EmitSound( DenySound )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:SetNextSecondaryFire( CurTime() + 0.2 )

	end

end

function SWEP:SecondaryAttack()
	local ent = self:GetOwner()

	local need = self.HealAmount + (self.HealAmount * ((GAMEMODE.EndlessMode and 0.05 or 0.02) * self.Owner:GetSkillAmount("Medical")))
	if ( IsValid( ent ) ) then need = math.min( ent:GetMaxHealth() - ent:Health(), self.HealAmount + (self.HealAmount * ((GAMEMODE.EndlessMode and 0.05 or 0.02) * self.Owner:GetSkillAmount("Medical"))) ) end

	if ( IsValid( ent ) && self:Clip1() >= need && ( ent:IsPlayer() or ent:IsNPC() ) && ent:Health() < ent:GetMaxHealth() ) then

		self:TakePrimaryAmmo(need)
		ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + need))
		if ent:HasPerkActive("medkit_charging") and SERVER then
			ent:SetArmor(math.min(ent:GetMaxArmor(),ent:Armor() + need * 0.5))
		end

		ent:EmitSound( HealSound )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		-- Even though the viewmodel has looping IDLE anim at all times, we need this to make fire animation work in multiplayer
		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		self.Owner:EmitSound( DenySound )
		self:SetNextPrimaryFire( CurTime() + 0.25 )
		self:SetNextSecondaryFire( CurTime() + 0.25 )

	end
end

function SWEP:OnRemove()

	timer.Remove( "hl2ce_medkit_ammo" .. self:EntIndex() )
	timer.Remove( "weapon_idle" .. self:EntIndex() )

end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

	return true

end

function SWEP:CustomAmmoDisplay()

	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:Clip1()

	return self.AmmoDisplay

end

function SWEP:Think()
	if SERVER then
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * dist,
			filter = function(e) return e~=self.Owner and ffunc(e) end,
			mins=hullmin,
			maxs=hullmax
		} )
		self:SetNWEntity("HitEnt",tr.Entity)
	end
end

function SWEP:DrawHUD()
	local w,h=ScrW(),ScrH()
	local ent=self:GetNWEntity("HitEnt")
	local text=""
	local text2=""
	local x,y=0,0
	if ent:IsNPC() then
		text="NPC Health  "
		text2=ent:Health().." / "..ent:GetMaxHealth()
	elseif ent:IsPlayer() then
		text="Player Health  "
		text2=ent:Health().." / "..ent:GetMaxHealth()
	end
	local follow=false
	if ent:IsNPC() or ent:IsPlayer() then follow=true end
	if IsValid(ent) and follow then
		local scrdata=ent:LocalToWorld(ent:OBBCenter()):ToScreen()
		x=scrdata.x
		y=scrdata.y-80
	end
	if text=="" then return end
	local bw=draw.WordBox( 4,x,y, text, "HudDefault", Color( 10, 10, 10,160 ), Color( 255, 255, 0 ), TEXT_ALIGN_RIGHT )
	draw.WordBox( 4,x+bw/2,y, text2, "HudNumbers", Color( 10, 10, 10,160 ), Color( 255, 255, 0 ),  TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
end

local curx,cury=-1,0
local curscale=0
--local crosshairmat=Material("hud/v_crosshair1")
local vector_one=Vector(1,1,1)
local blahblahblahcos=0
function SWEP:DoDrawCrosshair( x, y )
	--if curx==-1 then curx=x cury=y end
	local ent=self:GetNWEntity("HitEnt")
	local follow=false
	if ent:IsNPC() or ent:IsPlayer() then follow=true end
	if IsValid(ent) and follow then
		local scrdata=ent:LocalToWorld(ent:OBBCenter()):ToScreen()
		x=scrdata.x
		y=scrdata.y
	end
	local xspeed=10
	local yspeed=10
	curx=curx+(x-curx)*(1-math.exp(-FrameTime()*xspeed))
	cury=cury+(y-cury)*(1-math.exp(-FrameTime()*yspeed))
	local a=50+math.abs(math.sin(blahblahblahcos))*150
	if not follow then a=55 else blahblahblahcos=blahblahblahcos+FrameTime()*5 end
	local prct=self:Clip1()/self:MaxAmmo()
	local clr=Color(255,0,0,a):Lerp(Color(255,255,0,a),prct)
	surface.SetDrawColor( clr.r, clr.g, clr.b, clr.a )
	--surface.SetMaterial(crosshairmat)
	--surface.DrawTexturedRect( curx - 32, cury - 32, 64, 64 )
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	local scale=2.5
	if follow then
		scale=6
	end
	local text="+"
	local font="Crosshairs"
	curscale=curscale+(scale-curscale)*(1-math.exp(-FrameTime()*2))
	local m = Matrix()
	m:Translate( Vector( curx, cury, 0 ) )
	m:Rotate( Angle( 0, 0, 0 ) )
	m:Scale( vector_one * ( curscale or 1 ) )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	m:Translate( Vector( -w / 2, -h / 2, 0 ) )

	cam.PushModelMatrix( m, true )
		draw.DrawText( text,font, 0, 0, clr)
	cam.PopModelMatrix()

	render.PopFilterMag()
	render.PopFilterMin()
	return true
end

function SWEP:Deploy()
	if CLIENT and self.Owner==LocalPlayer() then
		curx=ScrW()*2
		cury=ScrH()*2
		curscale=0
	end
	return true
end
