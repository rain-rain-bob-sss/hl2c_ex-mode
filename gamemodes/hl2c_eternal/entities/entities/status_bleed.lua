AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Bleeding"
ENT.LifeTime = 8
ENT.RemoveTime = 0
ENT.NextBleedTick = 0
ENT.stackable = true 
ENT.maxstacks = 5

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Setup()
    if SERVER then 
        self.RemoveTime = CurTime() + self.LifeTime
    end
end

function ENT:Think()
    if SERVER then 
        local remove = not IsValid(self:GetParent()) or (self:GetParent().Alive and not self:GetParent():Alive())
        if self.RemoveTime ~= 0 or remove then 
            if (self.RemoveTime < CurTime()) or remove then SafeRemoveEntity(self) return end 
        end
        if self.NextBleedTick < CurTime() then
            local victim = self:GetParent()
            victim.cdmgtype = 1
            local dmg = DamageInfo()
            dmg:SetDamage(1)
            dmg:SetDamageType(self.DamageType or DMG_DIRECT)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            victim:TakeDamageInfo(dmg)
            victim.cdmgtype = 0
            self.NextBleedTick = CurTime() + 0.55
        end
        self:NextThink(CurTime() + 0.1)
        return true
    end
end

if CLIENT then
    function ENT:Draw() end
    killicon.AddFont("status_bleed","DebugOverlay","Bleeding",Color(255,0,0))
end