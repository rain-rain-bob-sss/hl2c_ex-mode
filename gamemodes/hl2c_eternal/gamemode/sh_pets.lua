-- are you sure? bro dont copy it from hl2cr
-- nah I SELF-CODE IT THEN

GM.Pets = {
    ["npc_headcrab"] = {
        Health = 15,
        DamageMul = 3,
    }
}

function GM:SpawnHl2cePet(ply, pet)
    if not ply:HasEternityUnlocked() then
        ply:PrintMessage(3, "You don't have unlocked Pets yet!")
        return
    end


end

function GM:UpgradeHl2cePet(ply, pet)
    if not ply:HasEternityUnlocked() then
        return
    end


end


