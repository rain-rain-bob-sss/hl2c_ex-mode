-- Entity information
ENT.Base = "base_brush"
ENT.Type = "brush"

ENT.m_TouchingEntities = {}


function ENT:StartTouch(ent)
	self.m_TouchingEntities[ent] = true
end


function ENT:EndTouch(ent)
	self.m_TouchingEntities[ent] = true
end
