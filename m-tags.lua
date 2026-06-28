if unsupported then
	return
end

----------------
--- TAG DATA ---
----------------

local TAG_DATA = {
	{ key = "CREATOR", name = "[CREATOR]", color = "\\#27F568\\" },
	{ key = "HOST", name = "[HOST]", color = "\\#FF8000\\" },
	{ key = "COOL_GUY", name = "\\#ab00ff\\[Cool \\#00ff85\\guy]", color = "" },
	--2808064910043531445
}

TAG_TYPE = {}
DEF_TAGS = {}

for i, data in ipairs(TAG_DATA) do
	local id = i
	TAG_TYPE[data.key] = id
	DEF_TAGS[id] = {
		name = data.name,
		color = data.color,
	}
end

-----------------
--- DC TO TAG ---
-----------------

----------------------
--- COOPNET TO TAG ---
----------------------

-- add your coopNet id here
local coopnetToTag = {
	["12766692904149469634"] = TAG_TYPE.CREATOR, -- Georgegabr1
	["2808064910043531445"] = TAG_TYPE.COOL_GUY,
}

local discordToTag = {
	["980159405674856478"] = TAG_TYPE.CREATOR, -- Georgegabr1
}

-----------------
--- TAG LOGIC ---
-----------------

gPlayerSyncTable[0].tagId = 0
local myTagResolved = false
local myCachedTagId = 0
local initTimer = 0

local function get_my_discord_id()
	local id = "0"
	if network_discord_id_from_local_index then
		id = network_discord_id_from_local_index(0)
	elseif get_local_discord_id then
		id = get_local_discord_id()
	end

	if not id or id == "" then
		return "0"
	end
	return tostring(id)
end

local function get_my_coopnet_id()
	local id = "0"
	if get_coopnet_id then
		id = get_coopnet_id(0)
	end

	if not id or id == "" then
		return "0"
	end
	return tostring(id)
end

local function resolve_my_tag()
	if myTagResolved then
		if gPlayerSyncTable[0].tagId ~= myCachedTagId then
			gPlayerSyncTable[0].tagId = myCachedTagId
		end
		return
	end

	local discordId = get_my_discord_id()
	local coopnetId = get_my_coopnet_id()

	if (discordId ~= "0" and discordId ~= "") or (coopnetId ~= "0" and coopnetId ~= "") then
		if discordToTag[discordId] then
			gPlayerSyncTable[0].tagId = discordToTag[discordId]
		elseif coopnetToTag[coopnetId] then
			gPlayerSyncTable[0].tagId = coopnetToTag[coopnetId]
		else
			gPlayerSyncTable[0].tagId = 0
		end

		myCachedTagId = gPlayerSyncTable[0].tagId
		myTagResolved = true
	else
		initTimer = initTimer + 1
		if initTimer > 90 then
			gPlayerSyncTable[0].tagId = 0
			myCachedTagId = 0
			myTagResolved = true
		end
	end
end

local function on_sync_valid()
	if myTagResolved then
		local currentTag = gPlayerSyncTable[0].tagId
		gPlayerSyncTable[0].tagId = 0
		gPlayerSyncTable[0].tagId = currentTag
	end
end

local function get_formatted_tag(playerIndex)
	local tagId = gPlayerSyncTable[playerIndex].tagId
	if tagId and tagId > 0 and DEF_TAGS[tagId] then
		local def = DEF_TAGS[tagId]
		return def.color .. def.name .. " "
	end
	return ""
end

local function get_player_display_name(playerIndex)
	local np = gNetworkPlayers[playerIndex]
	local playerColor = network_get_player_text_color_string(playerIndex)
	local tagStr = get_formatted_tag(playerIndex)

	if not np then
		return ""
	end

	local name = np.name
	if name == "Player" then
		name = "Player " .. playerIndex
	end

	return string.format("%s%s%s", tagStr, playerColor, name)
end

local function main_update()
	resolve_my_tag()

	if network_is_server() then
		gPlayerSyncTable[0].tagId = TAG_TYPE.HOST
	end
end

local function on_chat_message(m, msg)
	local s = gPlayerSyncTable[m.playerIndex]

	if s and s.tagId and s.tagId > 0 and DEF_TAGS[s.tagId] then
		local displayName = get_player_display_name(m.playerIndex)
		local formattedMsg = string.format("%s\\#dcdcdc\\: %s", displayName, msg)

		djui_chat_message_create(formattedMsg)

		if m.playerIndex == 0 then
			play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
		else
			play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
		end
		return false
	end
end

------------------
--- C/D POPUPS ---
------------------

local function on_player_disconnected(m)
	gPlayerSyncTable[m.playerIndex].tagId = 0
end

-------------
--- HOOKS ---
-------------

hook_event(HOOK_UPDATE, main_update)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)
hook_event(HOOK_ON_SYNC_VALID, on_sync_valid)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
