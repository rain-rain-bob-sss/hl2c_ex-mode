-- Finds the player meta table or terminates
local meta = FindMetaTable( "Entity" )
if !meta then return end

function meta:IsFriendlyNPC()
	return table.HasValue(FRIENDLY_NPCS, self:GetClass()) and not MAP_FORCE_NO_FRIENDLIES
end

function meta:IsGodlikeNPC()
	return table.HasValue(GODLIKE_NPCS, self:GetClass()) and not MAP_FORCE_NO_FRIENDLIES
end
