---- Player Database managing ----

local function OverrideOldVariables(tbl)
    for k, v in pairs(self.SkillsInfo) do
        if tbl["Stat"..k] then
            tbl.Skills[k] = tbl["Stat"..k]
        end
    end
end

function GM:LoadPlayer(ply)
    if ply:IsBot() then return end
    if not file.IsDir(self.VaultFolder.."/players/"..string.lower(string.gsub(ply:UniqueID(), ":", "_")), "DATA") then
        file.CreateDir(self.VaultFolder.."/players/"..string.lower(string.gsub(ply:UniqueID(), ":", "_")))
    end
    if file.Exists(self.VaultFolder.."/players/".. string.lower(string.gsub(ply:UniqueID(), ":", "_") .."/profile.txt"), "DATA") then
        local DataFile = file.Read(self.VaultFolder.."/players/".. string.lower(string.gsub(ply:UniqueID(), ":", "_") .."/profile.txt"), "DATA")

        local DataPieces = util.JSONToTable(DataFile)
 
        for k, v in pairs(DataPieces) do
            local variable = k
            local val = v

            local infnumber = isinfnumber(ply[variable])
            ply[variable] = tonumber(val) or val  -- dump all their stats into their player table
            
            if istable(ply[variable]) and ply[variable].isinfnumber then
                ply[variable] = InfNumber(ply[variable].mantissa or 1, ply[variable].exponent)
            elseif infnumber then
                ply[variable] = InfNumber(ply[variable])
            end
        end
  
    else
        ply.XP = 0 
        ply.Level = 1
        ply.StatPoints = 0

        ply.Skills = {}
        for k, v in pairs(self.SkillsInfo) do
            ply.Skills[k] = 0
        end
 
        print("Created a new profile for "..ply:Nick() .." (UniqueID: "..ply:UniqueID()..")")

        self:SavePlayer(ply)
    end

    self:NetworkString_UpdateStats(ply)
    self:NetworkString_UpdateSkills(ply)
end

function GM:SavePlayer(ply)
    if ply:IsBot() then return end
    if (ply.LastSave or 0) >= CurTime() then return end
    if self.DisableDataSave then return end
    ply.LastSave = CurTime() + 5

	local Data = {}

    local function insertdata(key, value)
        if isinfnumber(value) then
            Data[key] = {isinfnumber = true, mantissa = value.mantissa, exponent = value.exponent}
            return
        end

        Data[key] = value
    end

	insertdata("XP", ply.XP)
	insertdata("Level", ply.Level)
	insertdata("StatPoints", ply.StatPoints)
	insertdata("Prestige", ply.Prestige)
	insertdata("PrestigePoints", ply.PrestigePoints)
	insertdata("Eternities", ply.Eternities)
	insertdata("EternityPoints", ply.EternityPoints)
	insertdata("Celestiality", ply.Celestiality)
	insertdata("CelestialityPoints", ply.CelestialityPoints)

	insertdata("XPUsedThisPrestige", ply.XPUsedThisPrestige)
	insertdata("Moneys", ply.Moneys)
    
	insertdata("UnlockedPerks", ply.UnlockedPerks)
	insertdata("Skills", ply.Skills)

    local savedata = util.TableToJSON(Data, true)

	print("✓ ".. ply:Nick() .." profile saved into database")
	file.Write(self.VaultFolder.."/players/"..string.lower(string.gsub(ply:UniqueID(), ":", "_") .."/profile.txt"), savedata)
end
