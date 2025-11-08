function GM:LoadServerData()
    local filedir = "hl2c_eternal/server"
    local filedir2 = "hl2c_eternal/server/globaldata.txt"

    if not file.IsDir(filedir, "DATA") then file.CreateDir(filedir) end

    if file.Exists(filedir2, "DATA") then
        local TheFile = file.Read(filedir2, "DATA")
        local DataPieces = util.JSONToTable(TheFile)

        for k, v in pairs(DataPieces) do
            local variable = k
            local val = v

            if variable == "Difficulty" then
                GAMEMODE:SetDifficulty(InfNumber(val.mantissa, val.exponent))
            end
        end
   end
end

function GM:SaveServerData()
    if self.DisableDataSave then return end

    local Data = {}
    local function insertdata(key, value)
        if isinfnumber(value) then
            Data[key] = {isinfnumber = true, mantissa = value.mantissa, exponent = value.exponent}
            return
        end

        Data[key] = value
    end

	insertdata("Difficulty", self:GetDifficulty(true, true))

    local filedir = "hl2c_eternal/server/globaldata.txt"
    local savedata = util.TableToJSON(Data, true)
	file.Write(filedir, savedata)
	print("Saved global server data to file: "..filedir)
end


