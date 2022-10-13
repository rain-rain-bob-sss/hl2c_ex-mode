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
 
            ply[TheLine[1]] = TheLine[2]  -- dump all their stats into their player table
        end
  
    else
        ply.XP = 0 
        ply.Level = 1
        ply.StatPoints = 0
         
        for k, v in pairs(SkillsList) do
            local TheStatPieces = string.Explode(";", v)
            local TheStatName = TheStatPieces[1]
            ply[TheStatName] = 0
        end
 
        print("Created a new profile for "..ply:Nick() .." (UniqueID: "..ply:UniqueID()..")")

        self:SavePlayer(ply)
    end
    self:NetworkString_UpdateStats(ply)
    self:NetworkString_UpdateSkills(ply)
end

function GM:SavePlayer(ply)
    if (ply.LastSave or 0) >= CurTime() then return end
    ply.LastSave = CurTime() + 5

	local Data = {}
	Data["XP"] = ply.XP
	Data["Level"] = ply.Level
	Data["StatPoints"] = ply.StatPoints


	for k, v in pairs(SkillsList) do
		local TheStatPieces = string.Explode(";", v)
		local TheStatName = TheStatPieces[1]
		Data[TheStatName] = ply[TheStatName]
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
