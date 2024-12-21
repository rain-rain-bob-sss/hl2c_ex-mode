-- Not going to be implemented. Too much work for this.

-- GM.Pets = {
--     ["npc_headcrab"] = {
--         Health = 15,
--         DamageMul = 3,
--     }
-- }

-- function GM:SpawnHl2cePet(ply, pet)
--     if not ply:HasEternityUnlocked() then
--         ply:PrintMessage(3, "You don't have unlocked Pets yet!")
--         return
--     end

--     ply:PrintMessage(3, "spawning pet")
--     local ent = ents.Create(pet)
--     if not ent:IsValid() then ply:PrintMessage(3, "failed!") return end
--     ent:SetPos(ply:GetPos())
--     ent:SetAngles(Angle(0, ply:EyeAngles().yaw, 0))
--     ent:SetOwner(ply)
--     ent:Spawn()
--     ent.IsPet = true


-- end

-- function GM:UpgradeHl2cePet(ply, pet)
--     if not ply:HasEternityUnlocked() then
--         return
--     end


-- end


