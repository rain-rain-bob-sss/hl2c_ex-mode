if SERVER then
    ENT.Base = "base_brush"
    ENT.Type = "brush"

    function ENT:Initialize()
        self:AddSolidFlags(FSOLID_TRIGGER_TOUCH_DEBRIS)
    end

    function ENT:PassesTriggerFilters(ent)
        return true
    end

    function ENT:GetEntities()
        local list={}
        util.TraceEntity({
            start=self:GetPos(),
            endpos=self:GetPos(),
            mask=MASK_ALL,
            ignoreworld=true,
            filter = function(e)
                if e==self then return false end
                table.insert(list,e)
                return false
            end
        },self)
        return list
    end
end