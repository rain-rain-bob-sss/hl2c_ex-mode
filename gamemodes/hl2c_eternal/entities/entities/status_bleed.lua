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
        local remove = (self:GetParent().Alive and not self:GetParent():Alive())
        if self.RemoveTime ~= 0 or remove then 
            if (self.RemoveTime < CurTime()) or remove then SafeRemoveEntity(self) return end 
        end
        if self.NextBleedTick < CurTime() then
            local victim = self:GetParent()
            victim.bleeddamage = true
            victim:TakeDamage(4,self:GetOwner(),self)
            victim.bleeddamage = false
            self.NextBleedTick = CurTime() + 0.5
        end
        self:NextThink(CurTime() + 0.1)
        return true
    end
end

if CLIENT then
    function ENT:Draw() end
    killicon.AddFont("status_bleed","DebugOverlay","Bleeding",Color(255,0,0))
end