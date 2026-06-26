local HU = require("../hud-utils")

local M = {}

local real_djui_attempting_to_open = djui_attempting_to_open_playerlist

_G.djui_attempting_to_open_playerlist = function()
	return false
end

local function get_player_location(i)
	local np = gNetworkPlayers[i]
	if not np then
		return "Unknown"
	end

	local location = get_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex)
	return location or "Unknown"
end

local function remove_color(text, get_color)
	local start = text:find("\\")
	local next = 1
	while (next ~= nil) and (start ~= nil) do
		start = text:find("\\")
		if start ~= nil then
			next = text:find("\\", start + 1)
			if next == nil then
				next = text:len() + 1
			end

			if get_color then
				local color = text:sub(start, next)
				local render = text:sub(1, start - 1)
				text = text:sub(next + 1)
				return text, color, render
			else
				text = text:sub(1, start - 1) .. text:sub(next + 1)
			end
		end
	end
	return text
end

local function get_active_mods()
	if not gActiveMods or type(gActiveMods) ~= "table" then
		return "—"
	end

	if #gActiveMods == 0 then
		return "None"
	end

	local out = {}

	for i = 1, #gActiveMods do
		local mod = gActiveMods[i]

		if mod and mod.name then
			out[#out + 1] = HU.get_truncated_name(remove_color(tostring(mod.name)), 19, true)
		end
	end

	if #out == 0 then
		return "None"
	end

	return table.concat(out, "\n")
end

local ListAnim = {
	time = 0,
	speed = 1,
	progress = 0,
	anim = {
		startVal = 0,
		targetVal = 1,
		timeEnter = 10,
		timeStay = 9999, -- stays open while held
		timeExit = 10,
	},
}

function M.render_playerlist()
	gServerSettings.enablePlayerList = 0

	local prevTime = ListAnim.time

	ListAnim.prevTime = ListAnim.time

	if real_djui_attempting_to_open() then
		if ListAnim.time < ListAnim.anim.timeEnter then
			ListAnim.time = ListAnim.time + 1
		end
	else
		if ListAnim.time > 0 then
			ListAnim.time = ListAnim.time - 1
		end
	end

	if ListAnim.time <= 0 then
		return
	end

	local tPrev = prevTime / ListAnim.anim.timeEnter
	local tCurr = ListAnim.time / ListAnim.anim.timeEnter

	tPrev = 1 - (1 - tPrev) * (1 - tPrev)
	tCurr = 1 - (1 - tCurr) * (1 - tCurr)

	if djui_attempting_to_open_playerlist() then
		tPrev = tPrev * tPrev * (3 - 2 * tPrev)
		tCurr = tCurr * tCurr * (3 - 2 * tCurr)
	else
		tPrev = tPrev * tPrev * (3 - 2 * tPrev)
		tCurr = tCurr * tCurr * (3 - 2 * tCurr)
	end

	local opacity = math.floor(255 * tCurr)

	local screenW = djui_hud_get_screen_width()
	local screenH = djui_hud_get_screen_height()

	local width = screenW * 0.5
	local height = screenH * 0.6

	local x = (screenW - width) / 2

	local centerY = screenH / 2

	local yPrev = centerY - (height / 2) - ((1 - tPrev) * 120)
	local yCurr = centerY - (height / 2) - ((1 - tCurr) * 120)

	local titleYPrev = yPrev + 15
	local titleYCurr = yCurr + 15

	local headerYPrev = yPrev + 55
	local headerYCurr = yCurr + 55

	local baseYPrev = yPrev + 95
	local baseYCurr = yCurr + 95

	local mods = get_active_mods()
	local count = network_player_connected_count()

	-- BACKGROUND (INTERPOLATED)
	djui_hud_set_color(8, 56, 59, math.floor(200 * tCurr))
	HU.djui_hud_render_rect_rounded_interpolated(x, yPrev, width, height, x, yCurr, width, height, 24)

	-- TITLE
	djui_hud_set_color(255, 255, 255, opacity)
	djui_hud_print_text_interpolated("Players: " .. count, x + 20, titleYPrev, 1, x + 20, titleYCurr, 1)

	-- HEADERS
	djui_hud_set_color(200, 255, 255, opacity)

	djui_hud_print_text_interpolated("Name", x + 55, headerYPrev, 0.7, x + 55, headerYCurr, 0.7)

	djui_hud_print_text_interpolated("Description", x + 250, headerYPrev, 0.7, x + 250, headerYCurr, 0.7)

	djui_hud_print_text_interpolated("Location", x + width - 420, headerYPrev, 0.7, x + width - 420, headerYCurr, 0.7)

	djui_hud_print_text_interpolated(
		"Game Wins\nMinigame Wins",
		x + width - 280,
		headerYPrev - 15,
		0.7,
		x + width - 280,
		headerYCurr - 15,
		0.7
	)

	djui_hud_print_text_interpolated("Mods", x + width - 140, headerYPrev, 0.7, x + width - 140, headerYCurr, 0.7)

	djui_hud_set_color(255, 255, 255, opacity)
	djui_hud_print_text_interpolated(tostring(mods), x + width - 140, baseYPrev, 0.7, x + width - 140, baseYCurr, 0.7)

	djui_hud_set_color(255, 255, 255, math.floor(100 * tCurr))
	HU.djui_hud_render_rect_rounded_interpolated(
		x + 15,
		yPrev + 80,
		width - 30,
		2,
		x + 15,
		yCurr + 80,
		width - 30,
		2,
		1
	)

	local activePlayers = {}
	for i = 0, MAX_PLAYERS - 1 do
		if gNetworkPlayers[i].connected then
			table.insert(activePlayers, i)
		end
	end

	-- ROWS
	local rowSpacing = 28

	for idx, pIndex in ipairs(activePlayers) do
		local np = gNetworkPlayers[pIndex]

		if np then
			local location = get_player_location(pIndex)
			local sSync = gPlayerSyncTable[pIndex]
			local wins = sSync.gameWins or 0

			local rowYPrev = baseYPrev + ((idx - 1) * rowSpacing)
			local rowYCurr = baseYCurr + ((idx - 1) * rowSpacing)

			-- HEAD
			HU.render_player_head_interpolated(
				pIndex,
				x + 20,
				rowYPrev,
				x + 20,
				rowYCurr,
				1.5,
				1.5,
				false,
				false,
				opacity
			)

			HU.print_colored_text_interpolated(
				network_get_player_text_color_string(pIndex) .. tostring(np.name or "Unknown"),
				x + 55,
				rowYPrev,
				x + 55,
				rowYCurr,
				0.8,
				opacity
			)

			djui_hud_set_color(
				np.descriptionR or 255,
				np.descriptionG or 255,
				np.descriptionB or 255,
				(np.descriptionA or 255) * tCurr
			)

			djui_hud_print_text_interpolated(
				tostring(np.description or "???"),
				x + 250,
				rowYPrev,
				0.7,
				x + 250,
				rowYCurr,
				0.7
			)

			djui_hud_set_color(255, 255, 255, opacity)

			djui_hud_print_text_interpolated(
				tostring(location),
				x + width - 420,
				rowYPrev,
				0.7,
				x + width - 420,
				rowYCurr,
				0.7
			)

			djui_hud_set_color(255, 255, 100, opacity)

			djui_hud_print_text_interpolated(
				tostring(wins) .. " | " .. tostring(sSync.minigameWins or 0),
				x + width - 280,
				rowYPrev,
				0.7,
				x + width - 280,
				rowYCurr,
				0.7
			)
		end
	end
end

return M
