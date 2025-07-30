if (SERVER) then
    AddCSLuaFile()
	util.AddNetworkString("hl2ce_dmgnum")
	function GM:SendDMGNum(ply, dmg, pos, ent, ang, type)
		net.Start("hl2ce_dmgnum")
		net.WriteInt(dmg, 32)
		net.WriteVector(pos)
		net.WriteEntity(ent)
		net.WriteAngle(ang)
		net.WriteInt(type, 32)
		if ent.bleeddamage then
			net.WriteInt(1, 8)
		else
			net.WriteInt(0, 8)
		end
		net.Send(ply)
	end

	function GM:SendDamageNumber(ply,dmg,pos,ent,ang,type)
        if ent:GetInternalVariable("m_takedamage") <= 0 then return end 
        if dmg == 0 then return end
        --if ent.Alive and not ent:Alive() then return end --? ? ?
        if pos == vector_origin then 
            pos = ent:NearestPoint(ply:EyePos()) 
        end
	    self:SendDMGNum(ply, dmg, pos, ent, ang or ply:EyeAngles(), type or DMG_GENERIC)
	end
else
	local e
	net.Receive("hl2ce_dmgnum", function()
		local dmg = net.ReadInt(32)
		local pos = net.ReadVector()
		local ent = net.ReadEntity()
		local ang = net.ReadAngle()
		local type = net.ReadInt(32)
		local type2 = net.ReadInt(8)
		e = EffectData()
		e:SetOrigin(pos)
		e:SetMagnitude(dmg)
		e:SetEntity(ent)
		e:SetAngles(ang)
		e:SetDamageType(type)
		e:SetFlags(type2)
		util.Effect("hl2ce_dmgnum", e, true)
	end)
end