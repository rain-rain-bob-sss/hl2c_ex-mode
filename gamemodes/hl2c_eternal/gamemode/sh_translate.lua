-- Translation library by William Moodhe
-- Feel free to use this in your own addons.
-- See the languages folder to add your own languages.

--[[Copied from ZS because was too lazy to add one by myself, anyways it was edited a bit for file reduce]]

translate = {}

local Languages = {}
local Translations = {}
local AddingLanguage
local DefaultLanguage = "en"
local CurrentLanguage = DefaultLanguage
local DBG=false

if CLIENT then
	-- Need to make a new convar since gmod_language isn't sent to server.
	CreateClientConVar("gmod_language_rep", "en", false, true)

	timer.Create("checklanguagechange", 1, 0, function()
		CurrentLanguage = GetConVar("gmod_language"):GetString()
		if CurrentLanguage ~= GetConVar("gmod_language_rep"):GetString() then
			-- Let server know our language changed.
			RunConsoleCommand("gmod_language_rep", CurrentLanguage)
		end
	end)
end

function translate.GetLanguages()
	return Languages
end

function translate.GetLanguageName(short)
	return Languages[short]
end

function translate.GetTranslations(short)
	return Translations[short] or Translations[DefaultLanguage]
end

function translate.AddLanguage(short, long)
	Languages[short] = long
	Translations[short] = Translations[short] or {}
	AddingLanguage = short
end

function translate.AddTranslation(id, text)
	if not AddingLanguage or not Translations[AddingLanguage] then return end

	Translations[AddingLanguage][id] = text
end

function translate.Get(id)
	return (DBG and "[DBG]" or "")..(translate.GetTranslations(CurrentLanguage)[id] or translate.GetTranslations(DefaultLanguage)[id] or ("@"..id.."@"))
end

function translate.Format(id, ...)
	return (DBG and "[DBG]" or "")..(string.format(translate.Get(id), ...))
end

function translate.Interpolate(id,tbl)
	return (DBG and "[DBG]" or "")..(string.Interpolate(translate.Get(id),tbl))
end

function translate.Function(id, ...)
	local func=translate.GetTranslations(CurrentLanguage)[id]
	if not func then
		func=translate.GetTranslations(DefaultLanguage)[id]
	end
	if not func then
		return ("@"..id.."@")
	end
	return (DBG and "[DBG]" or "")..(func(...) or "")
end

if SERVER then
	function translate.ClientGet(pl, ...)
		CurrentLanguage = pl:GetInfo("gmod_language_rep")
		return translate.Get(...)
	end

	function translate.ClientFormat(pl, ...)
		CurrentLanguage = pl:GetInfo("gmod_language_rep")
		return translate.Format(...)
	end

	function translate.ClientInterpolate(pl, ...)
		CurrentLanguage = pl:GetInfo("gmod_language_rep")
		return translate.Interpolate(...)
	end

	function PrintTranslatedMessage(printtype, str, ...)
		for _, pl in pairs(player.GetAll()) do
			pl:PrintMessage(printtype, translate.ClientFormat(pl, str, ...))
		end
	end
end

if CLIENT then
	function translate.ClientGet(_, ...)
		return translate.Get(...)
	end
	function translate.ClientFormat(_, ...)
		return translate.Format(...)
	end
	function translate.ClientInterpolate(pl, ...)
		return translate.Interpolate(...)
	end
end

local function AddLanguages(late)
	local GM = GM or GAMEMODE
	for i, filename in pairs(file.Find(GM.FolderName.."/gamemode/"..(late and "late_languages" or "languages").."/*.lua", "LUA")) do
		LANG = {}
		AddCSLuaFile((late and "late_languages" or "languages").."/"..filename)
		include((late and "late_languages" or "languages").."/"..filename)
		for k, v in pairs(LANG) do
			translate.AddTranslation(k, v)
		end
		LANG = nil
	end
end
AddLanguages()

/* -- Not working due to ERROR
timer.Simple(0, function()
	AddLanguages(true)
end)
*/
local meta = FindMetaTable("Player")
if not meta then return end

function meta:PrintTranslatedMessage(hudprinttype, translateid, ...)
	if ... ~= nil then
		self:PrintMessage(hudprinttype, translate.ClientFormat(self, translateid, ...))
	else
		self:PrintMessage(hudprinttype, translate.ClientGet(self, translateid))
	end
end
