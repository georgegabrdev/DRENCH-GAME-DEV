--------------
--- TABLES ---
--------------
---

local LOADED_TRANSLATIONS = {}

local smlua_text_utils_get_language = smlua_text_utils_get_language
---------------
--- REQUIRE ---
---------------

local LANGUAGES = { "en", "es", "pt-br", "fr" }

for _, lang in ipairs(LANGUAGES) do
	LOADED_TRANSLATIONS[lang] = require(lang)
end

local LANGUAGE_CODES = {
	English = "en",
	Spanish = "es",
	Portuguese = "pt-br",
	French = "fr",
}

function murder_role_calc(IsSheriff, IsMurderer)
	local lang = smlua_text_utils_get_language()

	if IsSheriff == true then
		if lang == "Spanish" then
			return "\\#7affff\\Sheriff"
		elseif lang == "Portuguese" then
			return "\\#7affff\\Xerife"
		elseif lang == "French" then
			return "\\#7affff\\Shérif"
		else
			return "\\#7affff\\Sheriff"
		end
	elseif IsMurderer == true then
		if lang == "Spanish" then
			return "\\#ff7a7a\\Asesino"
		elseif lang == "Portuguese" then
			return "\\#ff7a7a\\Assassino"
		elseif lang == "French" then
			return "\\#ff7a7a\\Meurtrier"
		else
			return "\\#ff7a7a\\Murderer"
		end
	else
		if lang == "Spanish" then
			return "\\#7aff7a\\Inocente"
		elseif lang == "Portuguese" then
			return "\\#7aff7a\\Inocente"
		elseif lang == "French" then
			return "\\#7aff7a\\Innocent"
		else
			return "\\#7aff7a\\Innocent"
		end
	end
end

function murder_instructions_calc(IsSheriff, IsMurderer)
	if IsSheriff then
		return translate("murder_sheriff")
	elseif IsMurderer then
		return translate("murder_murderer")
	else
		return translate("murder_innocent")
	end
end

function translate_simon_do()
	local sS = gGlobalSyncTable.simonSays
	local lang = smlua_text_utils_get_language()

	if lang == "Spanish" then
		if sS == 1 then
			return "Salta!"
		elseif sS == 2 then
			return "Ataca!"
		elseif sS == 3 then
			return "No te muevas!"
		elseif sS == 4 then
			return "Camina!"
		elseif sS == 5 then
			return "Quémate en lava!"
		elseif sS == 6 then
			return "Agarra un borde!"
		elseif sS == 7 then
			return "Corre!"
		elseif sS == 8 then
			return "Haz un Backflip!"
		end
	elseif lang == "Portuguese" then
		if sS == 1 then
			return "Pule!"
		elseif sS == 2 then
			return "Ataque!"
		elseif sS == 3 then
			return "Não se mexa!"
		elseif sS == 4 then
			return "Ande!"
		elseif sS == 5 then
			return "Queime na lava!"
		elseif sS == 6 then
			return "Segure uma borda!"
		elseif sS == 7 then
			return "Corra!"
		elseif sS == 8 then
			return "Faça um Backflip!"
		end
	else
		if sS == 1 then
			return "Jump!"
		elseif sS == 2 then
			return "Attack!"
		elseif sS == 3 then
			return "Don't Move!"
		elseif sS == 4 then
			return "Walk!"
		elseif sS == 5 then
			return "Burn in lava!"
		elseif sS == 6 then
			return "Grab a ledge!"
		elseif sS == 7 then
			return "Run!"
		elseif sS == 8 then
			return "Do a Backflip!"
		end
	end
end

function get_hint(index)
	local code = language or "en"
	local hint_key = "hint_" .. tostring(index)

	if LOADED_TRANSLATIONS[code] and LOADED_TRANSLATIONS[code][hint_key] then
		return LOADED_TRANSLATIONS[code][hint_key]
	end

	return LOADED_TRANSLATIONS["en"][hint_key] or ""
end

function translate(id)
	local code = language or "en"

	if LOADED_TRANSLATIONS[code] and LOADED_TRANSLATIONS[code][id] then
		return LOADED_TRANSLATIONS[code][id]
	end

	return LOADED_TRANSLATIONS["en"][id] or id
end
