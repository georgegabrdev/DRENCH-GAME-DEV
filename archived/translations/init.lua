local smlua_text_utils_get_language = smlua_text_utils_get_language

local translations = {
	English = require("archived.translations.english"),
	Spanish = require("archived.translations.spanish"),
	Portuguese = require("archived.translations.portuguese"),
}

function translate(id)
	local lang = smlua_text_utils_get_language()

	local t = translations[lang] or translations.English
	return t[id] or translations.English[id] or id
end

function translate_simon_do()
	local lang = smlua_text_utils_get_language()
	local t = translations[lang] or translations.English

	return t.simonMessages[gGlobalSyncTable.simonSays]
		or translations.English.simonMessages[gGlobalSyncTable.simonSays]
		or ""
end

function murder_instructions_calc(isSheriff, isMurderer)
	if isSheriff then
		return translate("murder_sheriff")
	elseif isMurderer then
		return translate("murder_murderer")
	else
		return translate("murder_innocent")
	end
end
