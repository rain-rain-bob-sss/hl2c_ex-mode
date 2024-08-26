---- Player Database managing ----

function GM:LoadPlayer(ply)
    if not file.IsDir(self.VaultFolder.."/players/"..string.lower(string.gsub(ply:UniqueID(), ":", "_")), "DATA") then
        file.CreateDir(self.VaultFolder.."/players/"..string.lower(string.gsub(ply:UniqueID(), ":", "_")))
    end
    if file.Exists(self.VaultFolder.."/players/".. string.lower(string.gsub(ply:UniqueID(), ":", "_") .."/profile.txt"), "DATA") then
        local TheFile = file.Read(self.VaultFolder.."/players/".. string.lower(string.gsub(ply:UniqueID(), ":", "_") .."/profile.txt"), "DATA")
        local DataPieces = string.Explode("\n", TheFile)
 
        local Output = {}
 
        for k, v in pairs(DataPieces) do
            local TheLine = string.Explode(";", v) -- convert txt string to stats table
            local variable = TheLine[1]
            local val = TheLine[2]

            if variable == "UnlockedPerks" then
                ply.UnlockedPerks = util.JSONToTable(val)
                continue
            end
            ply[variable] = tonumber(val) or val  -- dump all their stats into their player table
        end
  
    else
        ply.XP = 0 
        ply.Level = 1
        ply.StatPoints = 0
         
        for k, v in pairs(self.SkillsInfo) do
            ply["Stat"..k] = 0
        end
 
        print("Created a new profile for "..ply:Nick() .." (UniqueID: "..ply:UniqueID()..")")

        self:SavePlayer(ply)
    end
    self:NetworkString_UpdateStats(ply)
    self:NetworkString_UpdateSkills(ply)
end

function GM:SavePlayer(ply)
    if (ply.LastSave or 0) >= CurTime() then return end
    if self.DisableDataSave then return end
    ply.LastSave = CurTime() + 5

	local Data = {}
	Data["XP"] = ply.XP
	Data["Level"] = ply.Level
	Data["StatPoints"] = ply.StatPoints
	Data["Prestige"] = ply.Prestige
	Data["PrestigePoints"] = ply.PrestigePoints
	Data["Eternity"] = ply.Eternity
	Data["EternityPoints"] = ply.EternityPoints
	Data["UnlockedPerks"] = util.TableToJSON(ply.UnlockedPerks)


	for k, v in pairs(self.SkillsInfo) do
		Data["Stat"..k] = ply["Stat"..k]
	end


	local StringToWrite = ""
	for k, v in pairs(Data) do
		if(StringToWrite == "") then
			StringToWrite = k ..";".. v
		else
			StringToWrite = StringToWrite .."\n".. k ..";".. v
		end
	end
	
	print("✓ ".. ply:Nick() .." profile saved into database")	
	file.Write(self.VaultFolder.."/players/"..string.lower(string.gsub(ply:UniqueID(), ":", "_") .."/profile.txt"), StringToWrite)
end
