-- Finds the player meta table or terminates
local meta = FindMetaTable( "Entity" )
if !meta then return end

function meta:IsFriendlyNPC()
	return table.HasValue(FRIENDLY_NPCS, self:GetClass()) and not MAP_FORCE_NO_FRIENDLIES
end

function meta:IsGodlikeNPC()
	return table.HasValue(GODLIKE_NPCS, self:GetClass()) and not MAP_FORCE_NO_FRIENDLIES
end


-- attempt to rework HP beyond 32 bit limit
-- Only up to 1e30 because damage at more than 3.4e38 can overflow to infinity
local max = 2.1e9
local inf_max = 1e70
meta.OldHealthEX = meta.OldHealthEX or meta.Health
function meta:Inf_Health()
	return math.ceil(tonumber(self:GetDTString(DT_FLOAT_ENT_HEALTH)) or 0)
end
function meta:Health()
	local infhp = self:Inf_Health()
	local oldhp = self:OldHealthEX()
	if infhp > oldhp and infhp >= max then
		return infhp
	end
	return oldhp
end

meta.OldSetHealthEX = meta.OldSetHealthEX or meta.SetHealth
function meta:Inf_SetHealth(value)
	self:SetDTString(DT_FLOAT_ENT_HEALTH, tostring(math.Clamp(value, -inf_max, inf_max)))
end
function meta:SetHealth(value)
	self:OldSetHealthEX(math.Clamp(value, -max, max))
	self:Inf_SetHealth(value)
end

meta.OldGetMaxHealthEX = meta.OldGetMaxHealthEX or meta.GetMaxHealth
function meta:Inf_GetMaxHealth()
	return math.ceil(tonumber(self:GetDTString(DT_FLOAT_ENT_MAXHEALTH)) or 0)
end
function meta:GetMaxHealth()
	local infmaxhp = self:Inf_GetMaxHealth()
	local oldmaxhp = self:OldGetMaxHealthEX()
	if infmaxhp > oldmaxhp then
		return infmaxhp
	end
	return infmaxhp != 0 and math.min(oldmaxhp, infmaxhp) or oldmaxhp
end

if SERVER then
	meta.OldSetMaxHealthEX = meta.OldSetMaxHealthEX or meta.SetMaxHealth
	function meta:Inf_SetMaxHealth(value)
		self:SetDTString(DT_FLOAT_ENT_MAXHEALTH, tostring(math.Clamp(value, -inf_max, inf_max)))
	end
	function meta:SetMaxHealth(value)
		self:OldSetMaxHealthEX(math.Clamp(value, -max, max))
		self:Inf_SetMaxHealth(value)
	end
end
