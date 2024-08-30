-- are you sure? bro dont copy it from hl2cr
-- nah I SELF-CODE IT THEN

GM.Pets = {
    ["npc_headcrab"] = {
        Health = 15
    }
}

function GM:SpawnHl2cePet(ply, pet)
    if not ply:HasEternityUnlocked() then
        ply:PrintTranslatedMessage(3, "PetsLocked")
        return
    end


end
