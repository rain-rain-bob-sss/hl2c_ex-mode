function GM:LoadServerData()
    local filedir = "hl2c_eternal/server"
    local filedir2 = "hl2c_eternal/server/globaldata.txt"

    if not file.IsDir(filedir, "DATA") then file.CreateDir(filedir) end

    if file.Exists(filedir2, "DATA") then
        local TheFile = file.Read(filedir2, "DATA")
        local DataPieces = string.Explode("\n", TheFile)
 
        local Output = {}
 
        for k, v in pairs(DataPieces) do
            local TheLine = string.Explode(";", v)
            local data = TheLine[1]
            local value = TheLine[2]

            if data == "Difficulty" then
                self:SetDifficulty(value, true)
            end
        end
    end
end

function GM:SaveServerData()
    local Data = {}
	Data["Difficulty"] = self:GetDifficulty(true)

    local StringToWrite = ""
	for k, v in pairs(Data) do
		if StringToWrite == "" then
			StringToWrite = k ..";".. v
		else
			StringToWrite = StringToWrite .."\n".. k ..";".. v
		end
	end

    local filedir = "hl2c_eternal/server/globaldata.txt"
	file.Write(filedir, StringToWrite)
	print("Saved global server data to file: "..filedir)
end


