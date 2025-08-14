-- Finds the player meta table or terminates
local meta = FindMetaTable( "Entity" )
if !meta then return end

function meta:IsFriendlyNPC()
	return table.HasValue(FRIENDLY_NPCS, self:GetClass()) and not MAP_FORCE_NO_FRIENDLIES and not self.AllowFriendlyFire
end

function meta:IsGodlikeNPC()
	return table.HasValue(GODLIKE_NPCS, self:GetClass()) and not MAP_FORCE_NO_FRIENDLIES and not self.AllowFriendlyFire
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

function meta:InputSetHealth(iNewHealth)
	local iDelta = abs(self:Health() - iNewHealth)
	if iNewHealth > self:Health() then 
		self:SetHealth(iNewHealth)
	elseif iNewHealth < self:Health() then 
		local armor = self:Armor()
		self:SetArmor(0)
		self:TakeDamage(iDelta,self,self)
		self:SetArmor(armor)
	end
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


function meta:GiveStatus(name,lifetime) 
	if not scripted_ents.GetStored("status_"..name) then return nil,false end
	local status = scripted_ents.GetStored("status_"..name).t
	if not status then return nil,false end
	local selfstatus = self["status_"..name] or {}
	self["status_"..name] = selfstatus
	if status.stackable then 
		if status.maxstacks then
			local c = 0
			for _,v in pairs(selfstatus) do 
				if IsValid(v) then
					c = c + 1
					if c >= status.maxstacks then return v,false end
				end
			end
		end
	else
		for _,v in pairs(selfstatus) do 
			if IsValid(v) then
				return v,false
			end
		end
	end
	if SERVER then 
		local ent = ents.Create("status_"..name)
		if not IsValid(ent) then return nil,false end
		ent:SetPos(self:GetPos())
		ent:SetParent(self)
		ent.LifeTime = lifetime
		ent:Spawn()
		table.insert(selfstatus,ent)
		return ent,true
	end
end

function meta:GiveBleed(owner,lifetime)
	local bleed,created = self:GiveStatus("bleed",lifetime)
	bleed:SetOwner(owner)
	bleed:Setup()
	return bleed,created
end

function meta:GiveDelayedDamage(owner,damage)
	local ddmg,created = self:GiveStatus("delayeddamage")
	ddmg:SetOwner(owner)
	ddmg:Setup(damage)
	return ddmg,created
end

function meta:GetLastAttacker()
	return self.LastAttacker or NULL 
end

if SERVER then 
	function meta:OverrideMapCreationID(id)
		self.MapCreationIDOverride = id
	end
	meta.HCEOldMapCreationID = meta.HCEOldMapCreationID or meta.MapCreationID 
	function meta:MapCreationID(...)
		if self.MapCreationIDOverride then
			return self.MapCreationIDOverride
		end
		return self:HCEOldMapCreationID(...)
	end

	function meta:GetData(withsavetbl)
		return {
			classname = self:GetClass(),
			pos = self:GetPos(),
			ang = self:GetAngles(),
			model = self:GetModel(),
			name = self:GetName(),
			spawnflags = self:GetSpawnFlags(),
			keyvalues = self.HL2CEKeyValues or {},
			outputs = self.HL2CEOutputs or {},
			mapcreationid = self:MapCreationID(),
			savetable = withsavetbl and self:GetSaveTable() or {},
		}
	end

	function meta:SpawnWithData(data)
		self:SetPos(data.pos)
		self:SetAngles(data.ang)
		self:SetModel(data.model)
		self:SetSpawnFlags(data.spawnflags)
		self:SetName(data.name)
		for i, outputs in pairs(data.outputs or {}) do
			for _, output in pairs(outputs) do
				local str = i.." "..output
				self:Fire("AddOutput",str)
			end
		end
		self.HL2CEOutputs = data.outputs
		self:Spawn()
		self:Activate()

		for i,v in pairs(data.savetable) do 
			self:SetSaveValue(i,v)
		end

		self:OverrideMapCreationID(data.mapcreationid)
	end
end