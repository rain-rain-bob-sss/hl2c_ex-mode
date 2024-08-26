-- tbh this was just edit of weapon_medkit weapon for it to fit with the hl2c EX gamemode
AddCSLuaFile()

SWEP.Base = "weapon_medkit"
SWEP.PrintName = "HL2c Medkit"
SWEP.Author = "Uklejamini"
SWEP.Purpose = "Heal people with your primary attack, or yourself with the secondary."
SWEP.Instructions = "Effectiveness is increased by 2% per Medical skill point, max efficiency 120%. Remember, healing other players will give you 1/4 of health you heal!"

SWEP.Slot = 5
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_medkit.mdl")
SWEP.WorldModel = Model("models/weapons/w_medkit.mdl")
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = 60
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.HealAmount = 10
SWEP.MaxAmmo = 100 -- Max ammo

local HealSound = Sound( "HealthKit.Touch" )
local DenySound = Sound( "WallHealth.Deny" )

function SWEP:Initialize()
	self:SetHoldType( "slam" )

	if CLIENT then return end

	timer.Create("hl2ce_medkit_ammo"..self:EntIndex(), 1, 0, function()
		if IsValid(self) && (self:Clip1() < self.MaxAmmo) then
			local owner = self:GetOwner()
			self:SetClip1(math.min(self:Clip1() + 1 + ((GAMEMODE.EndlessMode and 0.1 or 0.02) * owner:GetSkillAmount("Surgeon")), self.MaxAmmo + (self.MaxAmmo * ((GAMEMODE.EndlessMode and 0.1 or 0.02) * owner:GetSkillAmount("Surgeon")))))
		end
	end)
end

function SWEP:PrimaryAttack()
	if CLIENT then return end

	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(true)
	end

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64,
		filter = self.Owner
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
		if ent:IsPlayer() then
			self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(), self.Owner:Health() + need * 0.25))
			self.Owner:GiveXP(need * 0.35)
		elseif ent:IsFriendlyNPC() then
			self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(), self.Owner:Health() + need * 0.2))
			self.Owner:GiveXP(need * 0.28)
		end

		ent:EmitSound( HealSound )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration() + 0.5 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		-- Even though the viewmodel has looping IDLE anim at all times, we need this to make fire animation work in multiplayer
		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		self.Owner:EmitSound( DenySound )
		self:SetNextPrimaryFire( CurTime() + 1 )
		self:SetNextSecondaryFire( CurTime() + 1 )

	end

end

function SWEP:SecondaryAttack()

	if ( CLIENT ) then return end

	local ent = self.Owner

	local need = self.HealAmount
	if ( IsValid( ent ) ) then need = math.min( ent:GetMaxHealth() - ent:Health(), self.HealAmount ) end

	if ( IsValid( ent ) && self:Clip1() >= need && ent:Health() < ent:GetMaxHealth() ) then

		self:TakePrimaryAmmo( need )

		ent:SetHealth( math.min( ent:GetMaxHealth(), ent:Health() + need ) )
		ent:EmitSound( HealSound )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration() + 0.5 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) then self:SendWeaponAnim( ACT_VM_IDLE ) end end )

	else

		ent:EmitSound( DenySound )
		self:SetNextPrimaryFire( CurTime() + 1 )
		self:SetNextSecondaryFire( CurTime() + 1 )

	end

end

function SWEP:OnRemove()

	timer.Stop( "medkit_ammo" .. self:EntIndex() )
	timer.Stop( "weapon_idle" .. self:EntIndex() )

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
