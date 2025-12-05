AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Bleeding"
ENT.Damage = 0
ENT.Attacker = NULL
ENT.stackable = true
ENT.NextDamageTick = 0
function ENT:Initialize()
    self:DrawShadow(false)
end

function ENT:Setup(dmg)
    if SERVER then self.Damage = dmg end
end

function ENT:Think()
    if SERVER then
        local remove = not IsValid(self:GetParent()) or (self:GetParent().Alive and not self:GetParent():Alive())
        if self.Damage <= 0 then remove = true end
        if remove then
            SafeRemoveEntity(self)
            return
        end

        if self.NextDamageTick < CurTime() then
            local mult = 1 - (0.8 / math.max(1, math.log10(self.Damage) - 2))
            local damage = math.ceil(self.Damage * mult)
            self.Damage = self.Damage - math.ceil(self.Damage * mult)
            local victim = self:GetParent()
            victim.cdmgtype = DMG_TYPE_DELAY
            local dmg = DamageInfo()
            dmg:SetDamage(damage)
            dmg:SetDamageType(self.DamageType or DMG_DIRECT)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            victim:TakeDamageInfo(dmg)
            victim.cdmgtype = 0
            self.NextDamageTick = CurTime() + 0.5
        end

        self:NextThink(CurTime() + 0.1)
        return true
    end
end

if CLIENT then
    function ENT:Draw()
    end

    killicon.AddFont("status_delayeddamage", "DebugOverlay", "Delayed Damage", Color(0, 0, 255))
end
