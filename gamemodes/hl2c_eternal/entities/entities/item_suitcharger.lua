AddCSLuaFile()

ENT.Type = "anim"

ENT.MaxJuice = 75

ENT.AutomaticFrameAdvance = false

local CHARGE_RATE = 0.04

local sounds = {
    deny = "SuitRecharge.Deny",
    start = "SuitRecharge.Start",
    lcc = "SuitRecharge.ChargingLoop",
    rc = "SuitRecharge.Start"
}

function ENT:SetupDataTables()
    self:NetworkVar( "Float", 0, "Juice" )
    self:NetworkVar( "Float", 4, "Juice2" )
    self:NetworkVar( "Float", 1, "State" )
    self:NetworkVar( "Int", 2, "Reactivate" )
    self:NetworkVar( "Int", 3, "On" )
end

function ENT:PlaySeq(name)
    self:ResetSequence(self:LookupSequence(name))
end

function ENT:Initialize()
    self:SetModel("models/props_combine/suit_charger001.mdl")

    self:SetMoveType(MOVETYPE_NONE)
    if SERVER then self:PhysicsInitStatic(SOLID_VPHYSICS) end

    self:PlaySeq("idle")

    self:AddEffects(EF_NOSHADOW)

    self.MaxJuice = self.MaxJuice * math.Clamp(GAMEMODE:GetDifficulty(),1,3)

    self.MaxJuice = math.floor(self.MaxJuice)

    self:SetState(0)
    self:SetJuice(self.MaxJuice)
    self:SetJuice2(self.MaxJuice)

    self:SetCycle(1 - math.Clamp(self:GetJuice2() / self.MaxJuice, 0, 1))

    if SERVER then self:SetUseType(CONTINUOUS_USE) end

    self.Inited = false
end

function ENT:FrameAdvance2()
    self:SetPlaybackRate(0)
    local target = 1 - math.Clamp(self:GetJuice() / self.MaxJuice, 0, 1)
    self.C = self.C or 0
    self.C = math.Approach(self.C,target,FrameTime() * 1)
    self:SetCycle(self.C)
end

function ENT:Think()

    if not self.Inited then
        if self:HasSpawnFlags( 16384 ) then --SF_KLEINER_RECHARGER
            --self.MaxJuice = self.MaxJuice / 2
            self.CITADEL = false
            self.BAD = true
        elseif self:HasSpawnFlags( 8192 ) then --SF_CITADEL_RECHARGER
            --self.MaxJuice = self.MaxJuice * 2
            self.BAD = false
            self.CITADEL = true
        end

        self.Inited = false
    end

    if self.Think2 then
        self:FrameAdvance()
        return self:Think2()
    end
    if self:GetJuice2() > 0 then
        self:FrameAdvance2()
    else
        self:FrameAdvance()
    end

    return true
end

function ENT:KeyValue( k, v )
	-- 99% of all outputs are named 'OnSomethingHappened'.
	if ( string.Left( k, 2 ) == "On" ) then
		self:StoreOutput( k, v )
	end
end

ENT.m_flSoundTime = 0
ENT.m_flNextCharge = 0

function ENT:Use(ply,call,type,val)
    if not ply or not ply:IsPlayer() then return end

    self:SetUseType(CONTINUOUS_USE)

    if self:GetOn() > 0 then
        self:SetJuice2(self:GetJuice2())
    end

    if self:GetJuice() <= 0 then
        self:PlaySeq("emptyclick")
        self:SetState(1)
        self:Off()
    end

    if self:GetJuice() <= 0 then
        if self.m_flSoundTime < CurTime() then
            self.m_flSoundTime = CurTime() + 0.62
            self:EmitSound(sounds["deny"])
        end
        return
    end

    if (ply:Armor() >= ply:GetMaxArmor() * (self.CITADEL and 2 or 1)) and not (self.CITADEL and ply:Health() < ply:GetMaxHealth()) then
        self:SetUseType(SIMPLE_USE)

        self:EmitSound(sounds["deny"])
        return
    end

    local CHARGE_RATE = CHARGE_RATE * (self.CITADEL and 0.6 or 1)

    self:NextThink(CurTime() + CHARGE_RATE)
    self.Think2 = self.Off

    if self.m_flNextCharge > CurTime() then return end

    if self:GetOn() <= 0 then
        self:SetOn(self:GetOn() + 1)
        self:EmitSound(sounds["start"])

        self.m_flSoundTime = CurTime() + 0.56

        self:TriggerOutput("OnPlayerUse",ply)
    end

    if self:GetOn() == 1 and self.m_flSoundTime < CurTime() then
        self:SetOn(self:GetOn() + 1)
        self:EmitSound(sounds["lcc"])
    end

    local heal = math.max(0,math.min(ply:GetMaxArmor() * (self.CITADEL and 2 or 1) - ply:Armor(),self.CITADEL and 2 or 1))
    self:SetJuice(self:GetJuice() - (self.CITADEL and heal / (250 / 75) or (self.BAD and heal * 2 or heal)))
    ply:SetArmor(ply:Armor() + heal)

    if self.CITADEL then
        heal = math.max(0,math.min(ply:GetMaxHealth() - ply:Health(),2))
        ply:SetHealth(ply:Health() + heal)
    end

    self:FrameAdvance2()

    self:TriggerOutput("OutRemainingCharge",ply,self:GetJuice() / self.MaxJuice)

    self.m_flNextCharge = CurTime() + CHARGE_RATE
end

function ENT:Recharge()
    self:EmitSound(sounds["rc"])

    self:SetJuice(self.MaxJuice)
    self:SetJuice2(self.MaxJuice)
    self:SetState(0)

    self:PlaySeq("idle")
    self:FrameAdvance2()

    self:SetReactivate(0)

    self.Think2 = nil
end

function ENT:Off()
    if self:GetOn() > 1 then
        self:StopSound(sounds["lcc"])
    end

    if self:GetState() == 1 then
        self:SetCycle(1)
    end

    self:SetOn(0)

    self:SetJuice2(self:GetJuice())

    if self:GetReactivate() == 0 then

        if self:GetJuice() <= 0 then
            self:SetReactivate(25)
            self:NextThink(CurTime() + self:GetReactivate())
            self.Think2 = self.Recharge
        else
            self.Think2 = nil
        end

    end
end
