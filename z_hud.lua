-- disable everything except camera and health
local HU = require("hud-utils")
local MWI = require("c-mWins")
function behind_hud_render()
	hud_set_value(
		HUD_DISPLAY_FLAGS,
		HUD_DISPLAY_FLAGS_CAMERA | HUD_DISPLAY_FLAGS_POWER | HUD_DISPLAY_FLAGS_CAMERA_AND_POWER
	)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, behind_hud_render)

-- all hud stuff
local scoreMenuTimer = 0
local addPointTimer = 0
local scoreMenuFinal = false
local standingsBarCurrY = {}
local lastCountdownNumber = 0
local countdownTimer = 0
local hudHint = -1
local gaveMiniWin = false
local hud_hints = {
	"Wah-hah! Wario thinks you should punch your opponents to get them out! Show no mercy!",
	"It's a me, Mario! Have you seen the-a gold pot? That must be a lot-a coins! Wowza!",
	"It's me, Toad! Listen, I've played these games before! If you have Elimination Mode active... you'll be gone forever if you're eliminated! The horror! AAAAA!",
	"Hello, I'm Luigi and I'm here to tell you about Choose Mode. The host can choose any game they'd like to play, including setting up 1v1 Duel games. I highly recommend you give the option a chance.",
	'Wah, that big Toad in Red Light, Green Light is a CHEATER! He\'ll try and fake you out, and will sometimes turn WHILE saying "Green Light"! Wah, only I should be allowed to cheat!',
	"Toad again! We're fighting each other with these coins looming above us... it must be a metaphor for something! I just know it!",
	"Wario's favorite game is Glass Bridge! There's NO way to tell which glass pane is safe, even if you've worked in a glass factory! I always wait for someone else to go to see which is the right one, wah ha!",
	"This mod was a collaboration with many people, too many to list in these tips! But most of the programming was done by EmilyEmmi, who is very cool. These tips are not biased, of course.",
	"Wah, they say that not riding the carousel in Mingle is \"cheating\", eh? I'll throw my opponents off and get them in trouble! How's that for cheating, huh?",
	"Star Steal is one of my-a personal favorites! You move slower while holding the Super Star, so you'll need to-a dodge, ha-ha!",
	"It's Toad! I dread playing Bomb Tag... I always get hit at the last second! The players holding Bob-Ombs run faster, so my advice is to try and flank them! Screaming also helps! AAAAA!",
	'Hello, I\'m Luigi and I find the minigame "King Of The Hill" to be an enjoyable experience. I myself am against fighting though, so I just wait until the coast is clear.',
	"I'ma Wario! Want to crush your enemies in Duel or Lights Out? Use the Ground Pound! It deals BIG damage if you can time it right! Give me a cut of the money though, since I invented it!",
	"Every music track except the one for Mingle was created by murioz! Without her contributions, you'd be listening to Bob-Omb Battlefield over and over...",
	'The lobby, Mingle, Glass Bridge, and Red Light, Green Light maps were created by biobak, who is also working on the upcoming rom hack "Return To Yoshi\'s Island"!',
	"The King Of The Hill, Toad Town, and Koopa Keep maps were created by Woissil on short notice. Whomp's Fortress was used as a debug map, and you could fall off and lose instantly... it was not fun.",
	"The Duels map was created by me, EmilyEmmi. That's why it's so barebones compared to the others...",
	"I'M TOAD AND I HATE LIGHTS OUT! I try to climb the chains to get away, but they're too slippery and I fall and get hurt! OUCH!",
	"Wah, I was looking into Bomb Tag, and I found out that IT'S RIGGED! They always give the Bob-Ombs to the players that have held them for the least amount of time! They must hate winners like me!",
	"Hello, player. Have you noticed that some doors will refuse to open in Mingle? Apparently, less doors are available after the 3rd round. I hope you find this advice useful.",
	"You have to look out for-a more than just players in Star Steal! If you fall into lava, you'll also lose the Star-a! Be careful!",
	"I'ma Wario, and I'ma gonna win Duels with my exclusive info! You can get a full heal if you take out another player. It's the perfect strategy, since I'm the best brawler around!",
	"This mod is brought to you by our (totally legit) sponsors from the Squeex YouTube community! You can see their ads on the monitor in the lobby.",
	"This audio files used to take up 23.7 MB! It took ages to download. After Squishy trimmed and compressed all of the audio, this size was reduced to just over 2.5 MB. Wow...",
}

local function get_display_name(i)
	local np = gNetworkPlayers[i]
	if not np then
		return "Unknown"
	end

	local name = np.name or "Unknown"

	if name == "Player" then
		name = "Player " .. i
	end

	return name
end

function on_hud_render()
	djui_hud_set_resolution(RESOLUTION_N64)
	djui_hud_set_font(FONT_SPECIAL)

	-- reset score menu fields
	if gGlobalSyncTable.gameState ~= GAME_STATE_SCORES then
		scoreMenuTimer = 0
		addPointTimer = 0
		hudHint = -1
		scoreMenuFinal = false
	end

	if inMenu then
		return render_menu()
	end

	-- side bar
	local sideBarLines = {}
	local screenWidth, screenHeight = djui_hud_get_screen_width(), djui_hud_get_screen_height()
	local width = math.floor(screenWidth * 0.2)
	local scale = 0.25
	local lengthLimit = width / scale - 40 * scale
	if gGlobalSyncTable.gameState ~= GAME_STATE_MINI_END then
		gaveMiniWin = false
	end

	if gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
		scale = 0.2
		lengthLimit = width / scale - 40 * scale
		for_each_connected_player(function(i)
			local sMario = gPlayerSyncTable[i]
			local addStr = "\\#ff5050\\Waiting..."
			if sMario.ready then
				addStr = "\\#50ff50\\Ready!"
			end
			local name = network_get_player_text_color_string(i) .. get_display_name(i)
			name = cap_color_text(name, 18)
			add_line_to_table(sideBarLines, name .. ": " .. addStr, lengthLimit)
		end)
		if gGlobalSyncTable.gameTimer ~= 0 then
			local timeUntilStart = math.max(5 - gGlobalSyncTable.gameTimer // 30, 0)
			add_line_to_table(sideBarLines, "Starting in " .. tostring(timeUntilStart), lengthLimit)
		end
	elseif gGlobalSyncTable.gameState == GAME_STATE_RULES then
		local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
		add_line_to_table(sideBarLines, "\\#ffff50\\" .. gData.name, lengthLimit)
		if gGlobalSyncTable.eliminationMode then
			table.insert(sideBarLines, "\\#ff5050\\Elimination Mode")
		end
		table.insert(
			sideBarLines,
			translate("minigame_text") .. gGlobalSyncTable.miniGameNum .. "/" .. gGlobalSyncTable.maxMiniGames
		)
		table.insert(sideBarLines, "")

		local desc = gData.desc
		if is_final_duel() or gGlobalSyncTable.eliminationMode then
			if gGlobalSyncTable.teamCount == 0 then
				desc = gData.descElim or desc
			else
				desc = gData.descTeamsElim or desc
			end
		elseif gGlobalSyncTable.teamCount ~= 0 then
			desc = gData.descTeams or desc
		end
		add_line_to_table(sideBarLines, desc, lengthLimit)

		if gGlobalSyncTable.gameTimer > 360 then
			local number = (450 - gGlobalSyncTable.gameTimer) // 30 + 1
			if lastCountdownNumber ~= number then
				lastCountdownNumber = number
				countdownTimer = 0

				if number == 3 then
					play_stream_sfx("three", gGlobalSoundSource)
				elseif number == 2 then
					play_stream_sfx("two", gGlobalSoundSource)
				elseif number == 1 then
					play_stream_sfx("one", gGlobalSoundSource)
				elseif number == 0 then
					play_stream_sfx("go", gGlobalSoundSource)
				end
			end
			djui_hud_set_font(FONT_MENU)
			local alpha = 0
			if countdownTimer < 30 then
				alpha = -(255 * math.abs(countdownTimer - 15) // 15) + 255
			end
			local scale = 1
			local width = djui_hud_measure_text(tostring(number)) * scale
			local x = (screenWidth - width) / 2
			local y = screenHeight / 2 - 32 * scale
			djui_hud_set_color(255, 255, 255, alpha)
			djui_hud_print_text(tostring(number), x, y, scale)
			djui_hud_set_font(FONT_SPECIAL)
			countdownTimer = countdownTimer + 1
		else
			lastCountdownNumber = 0
		end
	elseif gGlobalSyncTable.gameState == GAME_STATE_ACTIVE then
		local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
		add_line_to_table(sideBarLines, "\\#ffff50\\" .. gData.name, lengthLimit)
		if gGlobalSyncTable.eliminationMode then
			table.insert(sideBarLines, "\\#ff5050\\Elimination Mode")
		end

		if gData.roundTime and gGlobalSyncTable.eliminateThisRound ~= 0 then
			if gGlobalSyncTable.eliminateThisRound == 1 then
				add_line_to_table(sideBarLines, "\\#ff5050\\Last place eliminated", lengthLimit)
			else
				add_line_to_table(
					sideBarLines,
					"\\#ff5050\\Bottom " .. tostring(gGlobalSyncTable.eliminateThisRound) .. " eliminated",
					lengthLimit
				)
			end

			-- display our score and safe score
			local sMario0 = gPlayerSyncTable[0]
			local score = sMario0.roundScore or 0
			local scoreText = translate("yourscore")
			if sMario0.eliminated and (spectatedPlayer > 0 and spectatedPlayer < MAX_PLAYERS) then
				-- display spectated player's score instead
				score = gPlayerSyncTable[spectatedPlayer].roundScore or 0
				scoreText = translate("theirscore")
			end
			local scale = 0.25
			local safeScore = get_safe_score(get_standings_table("roundScore"))
			local color = "\\#50ff50\\"
			if safeScore > score then
				color = "\\#ff5050\\"
			end
			local text
			local text2
			if gData.removeDecimal then
				text = string.format(scoreText .. color .. "%.0f", score / 10)
				text2 = string.format("%s %.0f", translate("safescore"), safeScore / 10)
			else
				text = string.format(scoreText .. color .. "%.1f", score / 10)
				text2 = string.format("%s %.1f", translate("safescore"), safeScore / 10)
			end
			local width = djui_hud_measure_text(remove_color(text)) * scale
			local width2 = djui_hud_measure_text(remove_color(text2)) * scale
			local maxWidth = math.max(width, width2)
			local x = (screenWidth - maxWidth) / 2
			local y = 10 * scale
			djui_hud_set_color(0, 0, 0, 100)
			HU.djui_hud_render_rect_rounded(
				x - 10 * scale,
				y - 17 * scale,
				maxWidth + 20 * scale,
				84 * scale,
				14 * scale
			)
			x = (screenWidth - width) / 2
			djui_hud_print_text_with_color_and_outline(text, x, y, scale)
			y = y + 32 * scale
			x = (screenWidth - width2) / 2
			djui_hud_print_text_with_color_and_outline(text2, x, y, scale)
		end
		local excluded_g = {
			[GAME_MODE_BOMB_TAG] = true,
			[GAME_MODE_DICE] = true,
			[GAME_MODE_DUEL] = true,
		}
		local lbStandings = get_standings_table("roundScore")
		local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
		local excluded = excluded_g[gGlobalSyncTable.gameMode] == true
		local hasScores = false
		if not excluded and gData then
			for i, data in ipairs(lbStandings) do
				if (data[2] or 0) ~= 0 then
					hasScores = true
					break
				end
			end
		end

		if hasScores then
			local lbScale = 0.2
			local lbWidth = screenWidth * 0.22
			local lbX = screenWidth - lbWidth - 10
			local lbEntryH = 32 * lbScale
			local lbPad = 10 * lbScale
			local lbCount = 0
			for i, data in ipairs(lbStandings) do
				if gNetworkPlayers[data[1]].connected then
					lbCount = lbCount + 1
				end
			end

			local lbTotalH = lbCount * lbEntryH + lbPad * 2 + 20 * lbScale
			local lbY = (screenHeight - lbTotalH) / 2

			djui_hud_set_color(0, 0, 0, 120)
			HU.djui_hud_render_rect_rounded(lbX - lbPad, lbY - lbPad, lbWidth + lbPad * 2, lbTotalH, 10 * lbScale)

			djui_hud_set_font(FONT_SPECIAL)
			local headerText = "\\#ffff50\\RANKINGS"
			local hw = djui_hud_measure_text(remove_color(headerText)) * lbScale
			djui_hud_print_text_with_color_and_outline(headerText, lbX + (lbWidth - hw) / 2, lbY, lbScale, 255, 2)
			lbY = lbY + 20 * lbScale

			local lbPlace = 1
			local lbPrevScore = nil
			local lbDisplayedPlace = 1

			for i, data in ipairs(lbStandings) do
				local index = data[1]
				local np = gNetworkPlayers[index]
				if np.connected then
					local score = data[2] or 0

					if lbPrevScore ~= nil and score ~= lbPrevScore then
						lbDisplayedPlace = lbPlace
					elseif lbPrevScore == nil then
						lbDisplayedPlace = 1
					end
					lbPrevScore = score
					lbPlace = lbPlace + 1

					if index == 0 then
						djui_hud_set_color(255, 255, 255, 30)
						HU.djui_hud_render_rect_rounded(
							lbX - lbPad,
							lbY - 4 * lbScale,
							lbWidth + lbPad * 2,
							lbEntryH,
							6 * lbScale
						)
					end

					local placeStr = placeString(lbDisplayedPlace)
					djui_hud_print_text_with_color_and_outline(placeStr, lbX, lbY, lbScale / 1.2, 255, 2)

					local nameColor = network_get_player_text_color_string(index)
					local name = cap_color_text(nameColor .. get_display_name(index), 999)
					djui_hud_print_text_with_color_and_outline(name, lbX + 40 * lbScale, lbY, lbScale / 1.2, 255, 2)

					local scoreVal = gData.removeDecimal and string.format("%.0f", score / 10)
						or string.format("%.1f", score / 10)

					local scoreColor = "\\#ffffff\\"
					if gGlobalSyncTable.eliminateThisRound ~= 0 then
						local safeScore = get_safe_score(lbStandings)
						scoreColor = score >= safeScore and "\\#50ff50\\" or "\\#ff5050\\"
					end
					local scoreText = scoreColor .. scoreVal
					local sw = djui_hud_measure_text(remove_color(scoreText)) * lbScale
					djui_hud_print_text_with_color_and_outline(
						scoreText,
						lbX + lbWidth - sw,
						lbY,
						lbScale / 1.1,
						255,
						2
					)

					lbY = lbY + lbEntryH
				end
			end
		end
		table.insert(sideBarLines, "")

		local roundTime = gData.roundTime or 0
		if gData.firstRoundTime and gGlobalSyncTable.round == 1 then
			roundTime = gData.firstRoundTime
		end
		if gGlobalSyncTable.freezeRoundTimer then
			roundTime = 0
		end
		local maxTime = gData.maxTime or 3 * 30 * 60 -- default 3 minutes max
		if gData.maxRounds and gData.roundTime and gData.roundTime > 0 then
			maxTime = gData.firstRoundTime or gData.roundTime
			maxTime = maxTime + gData.roundTime * (gData.maxRounds - 1)
		end

		local gameTimeLeft = maxTime - gGlobalSyncTable.gameTimer
		local roundTimeLeft = roundTime - gGlobalSyncTable.roundTimer
		if maxTime == -1 then
			gameTimeLeft = 99999 -- FOREVER
		end

		---@type boolean?,boolean?
		local sideBarOverride, sideBarDisable = false, false
		if gData.hudRenderFunc then
			sideBarOverride, sideBarDisable = gData.hudRenderFunc(
				screenWidth,
				screenHeight,
				sideBarLines,
				lengthLimit,
				roundTime,
				roundTimeLeft,
				gameTimeLeft,
				maxTime
			)
		end
		if sideBarDisable then
			sideBarLines = {} -- no side bar
		elseif not sideBarOverride then
			if roundTime ~= 0 and gameTimeLeft >= roundTimeLeft then
				add_line_to_table(
					sideBarLines,
					get_time_string(roundTimeLeft) .. translate("untilelimination"),
					lengthLimit
				)
			elseif maxTime ~= -1 then
				add_line_to_table(
					sideBarLines,
					get_time_string(gameTimeLeft) .. translate("untilgameends"),
					lengthLimit
				)
			else
				sideBarLines = {} -- no side bar
			end
		end

		if gMarioStates[0].action == ACT_SPECTATE then
			local scale = 0.2
			local paddingX = 6
			local paddingY = 2
			local rectHeight = 11
			local thickness = 0.25

			local targetName = "Unknown"

			if gNetworkPlayers[spectatedPlayer] then
				targetName = network_get_player_text_color_string(spectatedPlayer) .. get_display_name(spectatedPlayer)
			end

			local text = "\\#ffffff\\< " .. targetName .. " \\#ffffff\\>"

			local rawWidth = djui_hud_measure_text(text)
			local measureText = rawWidth * scale

			local screenW = djui_hud_get_screen_width()
			local screenH = djui_hud_get_screen_height()

			local x = (screenW - measureText) / 2
			local y = screenH - 30

			local rectWidth = measureText + (paddingX * 2)
			local rectX = x - paddingX
			local rectY = y - paddingY

			if gNetworkPlayers[targetPlayer] then
				djui_hud_set_color(0, 255, 255, 128)
				HU.djui_hud_render_rect_rounded_outlined(rectX, rectY, rectWidth, rectHeight, 8, 56, 59, thickness, 128)
			else
				djui_hud_set_color(0, 255, 255, 128)
				HU.djui_hud_render_rect_rounded(rectX, rectY, rectWidth, rectHeight, 5)
			end

			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text(text, x, y, scale)
		end
	elseif gGlobalSyncTable.gameState == GAME_STATE_MINI_END then
		if is_final_duel() then
			return
		end
		local scale = 1
		local text = "\\#ff2828\\No one won..."

		if gGlobalSyncTable.eliminationMode then
			local sMario = gPlayerSyncTable[0]
			if not sMario.eliminated then
				text = "\\#50ff50\\YOU SURVIVED"
			elseif sMario.roundEliminated ~= 0 then
				text = "\\#ff2828\\YOU DIED"
			else
				text = ""
			end
		else
			local standings = get_standings_table("earnedPoints")
			local foundWinner = false
			local prevScore = 0
			for i, data in ipairs(standings) do
				local index = data[1]
				if data[2] ~= 0 and ((not foundWinner) or prevScore == data[2]) then
					prevScore = data[2]
					if foundWinner then
						text = "\\#ffff50\\Multiple winners!"
						break
					else
						foundWinner = true
						text = network_get_player_text_color_string(index)
							.. get_display_name(index)
							.. "\\#ffff50\\ wins!"
						if index == 0 and not gaveMiniWin then
							gaveMiniWin = true
							MWI.add_m_win()
						end
					end
				elseif foundWinner and prevScore ~= data[2] then
					break
				end
			end
		end

		if #text ~= 0 then
			local width = djui_hud_measure_text(remove_color(text)) * scale
			local x = (screenWidth - width) / 2
			local y = screenHeight / 2 - 16 * scale
			djui_hud_set_color(0, 0, 0, 100)
			HU.djui_hud_render_rect_rounded(x - 10 * scale, y - 10 * scale, width + 20 * scale, 52 * scale, 10 * scale)
			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text_with_color_and_outline(text, x, y, scale, 255, 2)
		end
	elseif gGlobalSyncTable.gameState == GAME_STATE_SCORES then
		local standings = {}
		local prevPlace = {}
		if gGlobalSyncTable.eliminationMode then
			scoreMenuFinal = true
			standings = get_standings_table_bool("eliminated")
		elseif not scoreMenuFinal then
			standings = get_standings_table("earnedPoints")
		else
			standings = get_standings_table("points")
			if gGlobalSyncTable.miniGameNum > 1 then
				local lastStandings = get_standings_table("points", "earnedPoints")
				local prevScore = 0
				local place = 1
				local newPlace = 0
				local prevTeam = -1
				for i, data in ipairs(lastStandings) do
					local index = data[1]
					local sMario = gPlayerSyncTable[index]
					if sMario.team == nil or sMario.team == 0 or sMario.team ~= prevTeam then
						newPlace = newPlace + 1
						prevTeam = sMario.team
					end
					if data[2] ~= prevScore then
						prevScore = data[2]
						place = newPlace
					end
					prevPlace[index] = place
				end
			end
		end

		while do_solo_debug() and #standings < MAX_PLAYERS do
			table.insert(standings, { #standings, #standings })
		end

		local scale = 0.2
		local width = screenWidth * 0.5
		local x = 0
		local y = 5
		local leftToEarn = false
		local prevScore = 0
		local place = 1
		local newPlace = 0
		local prevTeam = -1
		for i, data in ipairs(standings) do
			local index = data[1]
			local sMario = gPlayerSyncTable[index]
			local gamePoints = sMario.points or 0
			if not scoreMenuFinal then
				gamePoints = gamePoints - (sMario.earnedPoints or 0)
			elseif (not gGlobalSyncTable.eliminatedMode) and sMario.team and sMario.team ~= 0 then
				gamePoints = data[2]
			end
			local renderY = y
			if standingsBarCurrY[index] and scoreMenuTimer ~= 0 then
				renderY = smooth_approach(renderY, standingsBarCurrY[index], 0.25)
			end
			standingsBarCurrY[index] = renderY

			x = (screenWidth - width) / 2
			if sMario.team == nil or sMario.team == 0 or sMario.team > #TEAM_DATA then
				djui_hud_set_color(0, 0, 0, 100)
			else
				local color = TEAM_DATA[sMario.team][2]
				djui_hud_set_color(color.r, color.g, color.b, 100)
			end
			HU.djui_hud_render_rect_rounded(x, renderY - 10 * scale, width, 52 * scale, 10 * scale)

			x = x + 20 * scale
			if not gGlobalSyncTable.eliminationMode then
				if sMario.team == nil or sMario.team == 0 or sMario.team ~= prevTeam then
					newPlace = newPlace + 1
					prevTeam = sMario.team
				end
				if data[2] ~= prevScore then
					prevScore = data[2]
					place = newPlace
				end
				if prevPlace[index] then
					local progressText = "\\#02fa13\\-"
					if prevPlace[index] < place then
						progressText = "\\#025dfa\\v"
					elseif prevPlace[index] > place then
						progressText = "\\#fa5102\\^"
					end
					djui_hud_print_text_with_color_and_outline(progressText, x, renderY, scale, 255, 2)
				end
				x = x + 30 * scale
				local text = placeString(place)
				djui_hud_print_text_with_color_and_outline(text, x, renderY, scale, 255, 2)
				x = x + 70 * scale
			end

			local np = gNetworkPlayers[index]
			local name = network_get_player_text_color_string(index) .. np.name
			djui_hud_print_text_with_color_and_outline(name, x, renderY, scale, 255, 2)

			local scoreText = ""
			local earned = (sMario.earnedPoints or 0)
			if not gGlobalSyncTable.eliminationMode then
				if (not scoreMenuFinal) and addPointTimer ~= 0 then
					gamePoints = gamePoints + math.min(addPointTimer, earned)
				end
				earned = earned - addPointTimer
				scoreText = "\\#ffff50\\" .. tostring(gamePoints)
				if scoreMenuFinal and gGlobalSyncTable.teamCount ~= 0 then
					scoreText = scoreText .. " (" .. tostring(sMario.points) .. ")"
				end
			elseif not data[2] then
				scoreText = "\\#50ff50\\Alive"
			else
				scoreText = "\\#ff2828\\Dead"
			end
			x = (screenWidth + width) / 2 - (djui_hud_measure_text(remove_color(scoreText)) + 20) * scale
			djui_hud_print_text_with_color_and_outline(scoreText, x, renderY, scale, 255, 2)

			if (not scoreMenuFinal) and earned > 0 then
				x = (screenWidth + width) / 2 - 120 * scale
				scoreText = "+" .. tostring(earned)
				leftToEarn = true
				scoreText = "\\#ffff50\\" .. scoreText
				djui_hud_print_text_with_color_and_outline(scoreText, x, renderY, scale, 255, 2)
			end

			y = y + 60 * scale
		end

		scoreMenuTimer = scoreMenuTimer + 1
		if leftToEarn and scoreMenuTimer >= 60 and scoreMenuTimer % 3 == 0 then
			addPointTimer = addPointTimer + 1
			play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
		end
		if (not (leftToEarn or scoreMenuFinal)) and scoreMenuTimer >= 150 then
			scoreMenuFinal = true
			play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
		end

		if hudHint == -1 then
			hudHint = math.random(1, #hud_hints)
		end
		local text = hud_hints[hudHint]
		local connectionsNeeded = 2
		local validPlayers = 0
		for_each_connected_player(function(index)
			validPlayers = validPlayers + 1
			if validPlayers >= connectionsNeeded then
				return true
			end
		end)
		if validPlayers == 0 or not (do_solo_debug() or validPlayers >= connectionsNeeded) then
			text = "Waiting for players..."
		end

		local scale = 0.2
		local lines = {}
		add_line_to_table(lines, text, (screenWidth * 0.8) / scale)
		local y = screenHeight - #lines * 32 * scale
		for i, line in ipairs(lines) do
			local width = djui_hud_measure_text(line) * scale
			local x = (screenWidth - width) / 2
			djui_hud_print_text_with_color_and_outline(line, x, y, scale, 255, 2)
			y = y + 32 * scale
		end
	elseif gGlobalSyncTable.gameState == GAME_STATE_GAME_END then
		local lines = {}
		local winners = get_winners_table()
		local names = {}
		local teamCounted = {}
		for i, index in ipairs(winners) do
			local sMario = gPlayerSyncTable[index]
			if sMario.team == nil or sMario.team == 0 or sMario.team > #TEAM_DATA then
				local text = network_get_player_text_color_string(index) .. get_display_name(index)
				table.insert(names, text)
			elseif not teamCounted[sMario.team] then
				teamCounted[sMario.team] = 1
				local text = TEAM_DATA[sMario.team][3]
				table.insert(names, text)
			end
		end

		if #names == 0 then
			table.insert(lines, "\\#ff2828\\No one won...")
		elseif #names == 1 then
			local text = names[1] .. "\\#ffff50\\ wins!"
			table.insert(lines, text)
		else
			table.insert(lines, "\\#ffff50\\Winners:")
			for i, name in ipairs(names) do
				table.insert(lines, name)
			end
		end

		local scale = 0.5
		local y = 20
		for i, line in ipairs(lines) do
			local width = djui_hud_measure_text(remove_color(line)) * scale
			local x = (screenWidth - width) / 2
			djui_hud_set_color(0, 0, 0, 100)
			HU.djui_hud_render_rect_rounded(x - 10 * scale, y - 10 * scale, width + 20 * scale, 52 * scale, 10 * scale)
			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text_with_color_and_outline(line, x, y, scale, 255, 2)
			y = y + 52 * scale
		end
	end

	if #sideBarLines ~= 0 then
		local x = 20 * scale
		local y = (screenHeight / 2) - #sideBarLines * 16 * scale
		djui_hud_set_color(0, 0, 0, 100)
		HU.djui_hud_render_rect_rounded(2, y - 10 * scale, width, (#sideBarLines * 32 + 20) * scale, 12 * scale)
		for i, line in ipairs(sideBarLines) do
			djui_hud_print_text_with_color_and_outline(line, x, y, scale, 255, 2)
			y = y + 32 * scale
		end
	end
	local modifiers = {}
	local modifierList = {
		{ modifierBits.superSpeed, "50ff50", "Super Speed" },
		{ modifierBits.highGravity, "ff5050", "High Gravity" },
		{ modifierBits.lowGravity, "50a0ff", "Low Gravity" },
		{ modifierBits.invertedControls, "ff8080", "Inverted Controls" },
		{ modifierBits.instaKill, "ff0000", "Instakill" },
		{ modifierBits.ZBC, "ff5050", "Z Button Challenge" },
		{ modifierBits.BBC, "ff5050", "B Button Challenge" },
	}

	for _, mod in ipairs(modifierList) do
		if is_modifier_active(mod[1]) then
			modifiers[#modifiers + 1] = "\\#" .. mod[2] .. "\\" .. mod[3]
		end
	end

	if #modifiers > 0 then
		djui_hud_set_font(FONT_NORMAL)
		local modScale = 0.25
		local padding = 4
		local lineHeight = 10

		local title = "\\#ffff50\\MODIFIERS"

		local maxWidth = djui_hud_measure_text(remove_color(title)) * modScale

		for _, text in ipairs(modifiers) do
			local w = djui_hud_measure_text(remove_color(text)) * modScale
			if w > maxWidth then
				maxWidth = w
			end
		end

		local boxWidth = maxWidth + padding * 2
		local boxHeight = (#modifiers + 1) * lineHeight + padding - 12

		local x = screenWidth - boxWidth - 8
		local y = 8

		-- background
		djui_hud_set_color(0, 0, 0, 220)
		HU.djui_hud_render_rect_rounded(x, y, boxWidth, boxHeight, 8)

		-- outline
		djui_hud_set_color(0, 0, 0, 180)
		HU.djui_hud_render_rect_rounded_outlined(x, y, boxWidth, boxHeight, 0, 0, 0, 1, 180)

		-- text
		local textX = x + padding
		local textY = y + padding - 12

		textY = textY + lineHeight

		for _, text in ipairs(modifiers) do
			HU.djui_hud_print_colored_text(text, textX, textY, modScale)

			textY = textY + lineHeight
		end
	end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

-- radar in Star Steal
local starRadar = { prevX = 0, prevY = 0, prevScale = 0 }
function behind_hud_render()
	if gGlobalSyncTable.gameMode ~= GAME_MODE_STAR_STEAL or gGlobalSyncTable.gameState == GAME_STATE_LOBBY then
		return
	end

	local o = obj_get_first_with_behavior_id(id_bhvStealStar)
	if not o then
		return
	end

	djui_hud_set_resolution(RESOLUTION_N64)
	local pos = { x = o.oPosX, y = o.oPosY + 20, z = o.oPosZ }
	local out = { x = 0, y = 0, z = 0 }
	djui_hud_world_pos_to_screen_pos(pos, out)

	local dX = out.x
	local dY = out.y
	local screenWidth = djui_hud_get_screen_width()
	local screenHeight = djui_hud_get_screen_height()

	local dist = vec3f_dist(pos, gMarioStates[0].pos)
	local alpha = clamp(dist, 0, 900) - 800
	if alpha <= 0 then
		starRadar.prevX = dX
		starRadar.prevY = dY
		return
	end

	if out.z > -260 then
		local cdist = vec3f_dist(pos, gLakituState.pos)
		if dist < cdist then
			dY = 0
		else
			dY = screenHeight
		end
	end

	local tex = gTextures.star
	local scale = (clamp(dist, 0, 2400) / 2000)
	local width = tex.width * scale
	dX = dX - width / 2
	dY = dY - width / 2
	if dX > (screenWidth - width) then
		dX = (screenWidth - width)
	elseif dX < 0 then
		dX = 0
	end
	if dY > (screenHeight - width) then
		dY = (screenHeight - width)
	elseif dY < 0 then
		dY = 0
	end

	djui_hud_set_color(255, 255, 255, alpha)
	djui_hud_render_texture_interpolated(
		tex,
		starRadar.prevX,
		starRadar.prevY,
		starRadar.prevScale,
		starRadar.prevScale,
		dX,
		dY,
		scale,
		scale
	)

	starRadar.prevX = dX
	starRadar.prevY = dY
	starRadar.prevScale = scale
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, behind_hud_render)

-- ============================================================
-- PAUSE MENU (ported from WarioWare)
-- ============================================================

local teamNameRef = { "Random" }
for i = 1, #TEAM_DATA do
	table.insert(teamNameRef, TEAM_DATA[i][3])
end

local menuSelectedMode = -1
function build_game_mode_menu(menu)
	for i = 0, GAME_MODE_MAX - 1 do
		local gData = GAME_MODE_DATA[i]
		table.insert(menu, {
			gData.name,
			function()
				menuSelectedMode = i
				if i == GAME_MODE_DUEL then
					enter_menu(4)
					return
				elseif type(gData.level) == "table" then
					enter_menu(5)
					return
				end
				gGlobalSyncTable.selectedMode = i
				djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
				inMenu = false
			end,
		})
	end
end

function build_team_select_menu(menu)
	for i = 0, MAX_PLAYERS - 1 do
		table.insert(menu, {
			gNetworkPlayers[i].name,
			function(x)
				gPlayerSyncTable[i].team = x
			end,
			false,
			function()
				return (not gNetworkPlayers[i].connected) or gPlayerSyncTable[i].spectator
			end,
			currNum = gPlayerSyncTable[i].team or 0,
			minNum = 0,
			maxNum = gGlobalSyncTable.teamCount,
			runOnChange = true,
			nameRef = teamNameRef,
		})
	end
end

local MENU_COLORS = {
	bg = { r = 0, g = 15, b = 25, a = 200 },
	bgTex = { r = 200, g = 255, b = 255, a = 50 },
	descBg = { r = 0, g = 15, b = 25, a = 255 },
	scrollBg = { r = 0, g = 15, b = 25, a = 255 },
	scrollBar = { r = 155, g = 255, b = 255, a = 155 },
}
TEX_TRIANGLE = get_texture_info("triangle")

inMenu = false
local menuOption = 1
local menuID = 1
local stickCooldownX = 0
local stickCooldownY = 0
local cancelTime = 0
local specTime = 0
local frameCounter = 0
local menu_history = {}
local menuMotionEnabled = true
local menuMotionY = 0
local bgTexScroll = 0
local menuMotionScrollY = -1
local resetMenuMotion = false
local menuMotionButton = {}

local function djui_hud_set_color_from_table(color, alpha)
	djui_hud_set_color(color.r or 255, color.g or 255, color.b or 255, alpha or color.a or 255)
end

-- menu data
menu_data = {
	[1] = {
		{
			"Game Settings",
			function()
				enter_menu(2)
			end,
			true,
		},
		{
			"Select Next Minigame",
			function()
				enter_menu(3)
			end,
			true,
			function()
				return (
					gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY
					and gGlobalSyncTable.gameState ~= GAME_STATE_SCORES
				)
					or (
						gGlobalSyncTable.gameModeSelection ~= SELECT_MODE_CHOOSE
						and (
							gGlobalSyncTable.gameModeSelection ~= SELECT_MODE_ORDER
							or gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY
						)
					)
			end,
		},
		{
			"Modifiers",
			function()
				enter_menu(7)
			end,
			true,
		},
		{
			"Force Start Game",
			function()
				gGlobalSyncTable.forceStart = not gGlobalSyncTable.forceStart
				if gGlobalSyncTable.forceStart then
					local connectionsNeeded = 2
					local validPlayers = 0
					for_each_connected_player(function(index)
						validPlayers = validPlayers + 1
						if validPlayers >= connectionsNeeded then
							return true
						end
					end)
					if validPlayers ~= 0 and (do_solo_debug() or validPlayers >= connectionsNeeded) then
						djui_chat_message_create("\\#ffff50\\Starting the game...")
					else
						djui_chat_message_create("\\#ff5050\\Need at least 2 players!")
						gGlobalSyncTable.forceStart = false
					end
				else
					djui_chat_message_create("\\#ff5050\\Canceled forced start.")
				end
			end,
			true,
			function()
				return (gGlobalSyncTable.gameState ~= GAME_STATE_LOBBY)
			end,
		},
		{
			"Auto Start Game",
			function(x)
				gGlobalSyncTable.autoGame = (x == 0) -- On = true, Off = false
			end,
			true,
			runOnChange = true,
			currNum = gGlobalSyncTable.autoGame and 0 or 1,
			minNum = 0,
			maxNum = 1,
			nameRef = {
				"\\#50ff50\\On",
				"\\#ff5050\\Off",
			},
		},
		{
			"Cancel Game",
			function()
				if cancelTime >= get_time() - 5 then
					gGlobalSyncTable.gameState = GAME_STATE_LOBBY
					gGlobalSyncTable.gameTimer = 0
					if gGlobalSyncTable.teamSelection == TEAM_SELECTION_RANDOM then
						do_team_selection()
					end
					cancelTime = 0
					inMenu = false
				else
					djui_chat_message_create("\\#ff5050\\Are you sure? Press A again to continue.")
					cancelTime = get_time()
				end
			end,
			true,
			function()
				return (gGlobalSyncTable.gameState == GAME_STATE_LOBBY)
			end,
		},
		{
			"Team",
			function(x)
				gPlayerSyncTable[0].team = x
			end,
			false,
			function()
				return not (
					gGlobalSyncTable.teamCount ~= 0
					and gGlobalSyncTable.teamSelection == TEAM_SELECTION_PLAYER
					and gGlobalSyncTable.gameState == GAME_STATE_LOBBY
				)
			end,
			runOnChange = true,
			updateNum = function(button)
				button.maxNum = gGlobalSyncTable.teamCount or 0
				local team = gPlayerSyncTable[0].team or 0
				if team <= button.maxNum then
					button.currNum = team
				else
					button.currNum = 0
				end
			end,
			currNum = 0,
			minNum = 0,
			maxNum = 0,
			nameRef = teamNameRef,
		},
		{
			"Open CS Menu",
			function()
				charSelect.set_menu_open(true)
				inMenu = false
			end,
			false,
			function()
				return not charSelectExists
			end,
		},
		{
			translate("spectate_text"),
			function()
				local sMario0 = gPlayerSyncTable[0]
				local skipCheck = gGlobalSyncTable.gameState == GAME_STATE_LOBBY
					or (gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE and not gGlobalSyncTable.eliminationMode)
				if sMario0.spectator or skipCheck or specTime >= get_time() - 5 then
					specTime = 0
					toggle_spectator()
					inMenu = false
				else
					djui_chat_message_create("\\#ff5050\\WARNING: This will eliminate you! Press A again to continue.")
					specTime = get_time()
				end
			end,
			false,
		},
		{
			translate("music_text"),
			function(x)
				disableMusic = x
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 3,
			nameRef = { "\\#50ff50\\On", "\\#ff5050\\Off", "Mingle Only", "High Quality" },
			save = "disableMusic",
			localSave = true,
		},
		{
			translate("colorblind_text"),
			function(x)
				showColorNames = (x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
			save = "showColorNames",
			localSave = true,
		},
		{
			"Exit Menu",
			function()
				inMenu = false
			end,
			false,
		},
		{
			"CoopDX Menu",
			function()
				djui_open_pause_menu()
			end,
			false,
		},
	},
	[2] = {
		{
			"Game Mode Selection",
			function(x)
				gGlobalSyncTable.gameModeSelection = x
				gGlobalSyncTable.selectedMode = -1
			end,
			minNum = 0,
			currNum = gGlobalSyncTable.gameModeSelection,
			maxNum = 3,
			runOnChange = true,
			nameRef = { "Choose", "In Order", "Random", "All" },
			save = "gameModeSelection",
		},
		{
			"Include All Player Duel",
			function(x)
				gGlobalSyncTable.includeAllDuel = (x == 1)
			end,
			true,
			function()
				return (gGlobalSyncTable.gameModeSelection == SELECT_MODE_CHOOSE or gGlobalSyncTable.eliminationMode)
			end,
			currNum = (gGlobalSyncTable.includeAllDuel and 1) or 0,
			minNum = 0,
			maxNum = 1,
			runOnChange = true,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
			save = "includeAllDuel",
		},
		{
			"Total Minigames",
			function(x)
				gGlobalSyncTable.maxMiniGames = x
			end,
			true,
			function()
				return gGlobalSyncTable.gameModeSelection == SELECT_MODE_ALL
			end,
			currNum = gGlobalSyncTable.maxMiniGames,
			maxNum = 99,
			runOnChange = true,
			save = "maxMiniGames",
		},
		{
			"Final Duel",
			function(x)
				gGlobalSyncTable.finalDuel = (x == 1)
			end,
			true,
			function()
				return (gGlobalSyncTable.gameModeSelection ~= SELECT_MODE_ALL and gGlobalSyncTable.maxMiniGames <= 1)
					or (gGlobalSyncTable.teamCount == 2 and not gGlobalSyncTable.eliminationMode)
			end,
			currNum = (gGlobalSyncTable.finalDuel and 1) or 0,
			minNum = 0,
			maxNum = 1,
			runOnChange = true,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
			save = "finalDuel",
		},
		{
			"Elimination Mode",
			function(x)
				gGlobalSyncTable.eliminationMode = (x == 1)
			end,
			currNum = (gGlobalSyncTable.eliminationMode and 1) or 0,
			minNum = 0,
			maxNum = 1,
			runOnChange = true,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
			save = "eliminationMode",
		},
		{
			"Percent Ready to Start",
			function(x)
				gGlobalSyncTable.percentToStart = x
			end,
			true,
			currNum = gGlobalSyncTable.percentToStart,
			minNum = 0,
			maxNum = 100,
			runOnChange = true,
			save = "percentToStart",
		},
		{
			"Teams",
			function(x)
				gGlobalSyncTable.teamCount = x
				if x == 0 then
					for i = 0, MAX_PLAYERS - 1 do
						gPlayerSyncTable[i].team = 0
					end
				else
					do_team_selection()
				end
			end,
			true,
			currNum = gGlobalSyncTable.teamCount,
			minNum = 0,
			maxNum = 8,
			excludeNum = 1,
			runOnChange = true,
			nameRef = { "\\#ff5050\\Off" },
			save = "teamCount",
		},
		{
			"Team Selection",
			function(x)
				gGlobalSyncTable.teamSelection = x
				if x == TEAM_SELECTION_RANDOM then
					do_team_selection()
				end
			end,
			true,
			function()
				return gGlobalSyncTable.teamCount == 0
			end,
			currNum = gGlobalSyncTable.teamSelection,
			minNum = 0,
			maxNum = 2,
			runOnChange = true,
			nameRef = { "Random", "Host's Choice", "Players' Choice" },
			save = "teamSelection",
		},
		{
			"Select Teams...",
			function()
				enter_menu(6)
			end,
			true,
			function()
				return gGlobalSyncTable.teamSelection ~= TEAM_SELECTION_HOST or gGlobalSyncTable.teamCount == 0
			end,
		},
	},
	[3] = { buildFunc = build_game_mode_menu }, -- auto built
	[4] = {
		{
			"Total Duelers",
			function(x)
				local secondToLastOption = menu_data[4][#menu_data[4] - 1]
				local lastOption = menu_data[4][#menu_data[4]]
				for i = 1, x do
					menu_data[4][i + 1] = {
						"Dueler " .. i,
						function()
							-- do nothing
						end,
						playerRef = true,
						currNum = (menu_data[4][i + 1] and get_menu_option(4, i + 1)) or 0,
						minNum = 0,
						maxNum = MAX_PLAYERS - 1,
					}
				end
				if #menu_data[4] > x + 1 then
					for i = x + 2, #menu_data[4] do
						menu_data[4][i] = nil
					end
				end
				table.insert(menu_data[4], secondToLastOption)
				table.insert(menu_data[4], lastOption)
			end,
			currNum = 2,
			minNum = 2,
			maxNum = MAX_PLAYERS,
			runOnChange = true,
		},
		{
			"Dueler 1",
			function()
				-- do nothing
			end,
			playerRef = true,
			currNum = 0,
			minNum = 0,
			maxNum = MAX_PLAYERS - 1,
		},
		{
			"Dueler 2",
			function()
				-- do nothing
			end,
			playerRef = true,
			currNum = 0,
			minNum = 0,
			maxNum = MAX_PLAYERS - 1,
		},
		{
			"\\#50ff50\\Confirm Duelers",
			function()
				for i = 0, MAX_PLAYERS - 1 do
					local sMario = gPlayerSyncTable[i]
					sMario.validForDuel = false
				end
				local duelers = 0
				for i = 2, #menu_data[4] - 2 do
					local index = get_menu_option(4, i)
					local sMario = gPlayerSyncTable[index]
					if not sMario.validForDuel then
						duelers = duelers + 1
						sMario.validForDuel = true
					end
				end
				if do_solo_debug() or duelers >= 2 then
					gGlobalSyncTable.selectedMode = GAME_MODE_DUEL
					gGlobalSyncTable.allDuel = false
					djui_chat_message_create("Selected \\#ffff50\\Duel")
					inMenu = false
				else
					djui_chat_message_create("\\#ff5050\\Must have at least 2 duelers!")
				end
			end,
		},
		{
			"\\#ffff50\\All Player Duel",
			function()
				gGlobalSyncTable.selectedMode = GAME_MODE_DUEL
				gGlobalSyncTable.allDuel = true
				djui_chat_message_create("Selected \\#ffff50\\Duel")
				inMenu = false
			end,
		},
	},
	[5] = {
		{
			"Toad Town",
			function()
				gGlobalSyncTable.gameLevelOverride = LEVEL_TOAD_TOWN
				gGlobalSyncTable.selectedMode = menuSelectedMode
				local gData = GAME_MODE_DATA[menuSelectedMode or 0]
				djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
				inMenu = false
			end,
		},
		{
			"Koopa Keep",
			function()
				gGlobalSyncTable.gameLevelOverride = LEVEL_KOOPA_KEEP
				gGlobalSyncTable.selectedMode = menuSelectedMode
				local gData = GAME_MODE_DATA[menuSelectedMode or 0]
				djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
				inMenu = false
			end,
		},
		{
			"DS Fort",
			function()
				gGlobalSyncTable.gameLevelOverride = LEVEL_DS_FORT
				gGlobalSyncTable.selectedMode = menuSelectedMode
				local gData = GAME_MODE_DATA[menuSelectedMode or 0]
				djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
				inMenu = false
			end,
		},
		{
			"Duel",
			function()
				gGlobalSyncTable.gameLevelOverride = LEVEL_DUEL
				gGlobalSyncTable.selectedMode = menuSelectedMode
				local gData = GAME_MODE_DATA[menuSelectedMode or 0]
				djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
				inMenu = false
			end,
		},
		{
			"Random",
			function()
				gGlobalSyncTable.gameLevelOverride = -1
				gGlobalSyncTable.selectedMode = menuSelectedMode
				local gData = GAME_MODE_DATA[menuSelectedMode or 0]
				djui_chat_message_create("Selected \\#ffff50\\" .. gData.name)
				inMenu = false
			end,
		},
	},
	[6] = { buildFunc = build_team_select_menu }, -- auto built
	[7] = {
		{
			"Super Speed",
			function(x)
				toggle_modifier_by_bit(modifierBits.superSpeed, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
		{
			"High Gravity",
			function(x)
				toggle_modifier_by_bit(modifierBits.highGravity, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
		{
			"Low Gravity",
			function(x)
				toggle_modifier_by_bit(modifierBits.lowGravity, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
		{
			"Inverted Controls",
			function(x)
				toggle_modifier_by_bit(modifierBits.invertedControls, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
		{
			"Instakill",
			function(x)
				toggle_modifier_by_bit(modifierBits.instaKill, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
		{
			"Z Button Challenge",
			function(x)
				toggle_modifier_by_bit(modifierBits.ZBC, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
		{
			"B Button Challenge",
			function(x)
				toggle_modifier_by_bit(modifierBits.BBC, x ~= 0)
			end,
			false,
			runOnChange = true,
			currNum = 0,
			minNum = 0,
			maxNum = 1,
			nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
		},
	},
}

local TEX_DRENCH = get_texture_info("drench_icon")

function render_menu()
	djui_hud_set_resolution(RESOLUTION_DJUI)
	djui_hud_set_font(FONT_NORMAL)

	local screenWidth = djui_hud_get_screen_width()
	local screenHeight = djui_hud_get_screen_height()

	-- Dark background
	djui_hud_set_color_from_table(MENU_COLORS.bg)
	djui_hud_render_rect(0, 0, screenWidth + 10, screenHeight + 10)

	-- Scrolling tiled background texture
	local tex = TEX_DRENCH
	local bgTexScale = 5
	local maxTexX = math.ceil(screenWidth / (tex.width * bgTexScale))
	local maxTexY = math.ceil(screenHeight / (tex.height * bgTexScale))
	djui_hud_set_color_from_table(MENU_COLORS.bgTex)
	for tileY = -1, maxTexY do
		for tileX = -1, maxTexX do
			if tileX % 2 == tileY % 2 then
				djui_hud_render_texture(
					tex,
					bgTexScroll + tex.width * tileX * bgTexScale,
					bgTexScroll + tex.height * tileY * bgTexScale,
					bgTexScale,
					bgTexScale
				)
			end
		end
	end
	if menuMotionEnabled then
		bgTexScroll = (bgTexScroll + 2) % (tex.width * bgTexScale)
	else
		bgTexScroll = 0
	end
	tex = TEX_TRIANGLE

	local menu = menu_data[menuID]
	if not menu then
		return
	end

	-- Count valid buttons and find how far down the selected one is
	local scroll = false
	local scale = 3
	local totalButtons = 0
	local downBy = 0
	for i, button in ipairs(menu) do
		if option_valid(button, true) then
			totalButtons = totalButtons + 1
		end
		if menuOption == i then
			downBy = totalButtons
		end
	end
	scroll = (totalButtons > 1)

	-- Smooth vertical motion
	local desc = ""
	local x = 0
	local y = (screenHeight * 0.5) - 40 * (scale - 1) * downBy
	if resetMenuMotion or not menuMotionEnabled then
		menuMotionY = y
		menuMotionScrollY = -1
		menuMotionButton = {}
		resetMenuMotion = false
	else
		y = smooth_approach(y, menuMotionY, 0.25)
		menuMotionY = y
	end

	for i, button in ipairs(menu) do
		if option_valid(button, true) then
			local text = button[1]
			local textScale = scale
			local isSelectable = option_valid(button)

			-- Build description for the selected button
			if i == menuOption then
				if button.desc then
					desc = button.desc
					if type(desc) == "table" then
						local currNum = button.currNum or 0
						local min = button.minNum or 0
						desc = desc[currNum - min + 1] or desc[#desc] or ""
					end
					if button.descExtra then
						desc = string.format(desc, button.descExtra(button.currNum or 0))
					else
						desc = string.format(desc, button.currNum or 0)
					end
				end
			else
				textScale = textScale - 1
			end

			-- Append current numeric / named value
			if button.currNum then
				local optionText = ""
				local min = button.minNum or 0
				if button.playerRef then
					if button.currNum ~= -1 then
						local np = gNetworkPlayers[button.currNum]
						if not np.connected then
							button.currNum = 0
							np = gNetworkPlayers[0]
						end
						local playerColor = network_get_player_text_color_string(np.localIndex)
						optionText = playerColor .. np.name
					else
						optionText = "Random"
					end
				elseif button.nameRef and button.nameRef[button.currNum - min + 1] then
					optionText = button.nameRef[button.currNum - min + 1]
				elseif button.timeRef then
					if button.currNum ~= 0 then
						local seconds = button.currNum
						local minutes = seconds // 60
						seconds = seconds % 60
						optionText = string.format("%d:%02d", minutes, seconds)
					else
						optionText = "Infinite"
					end
				else
					local numScale = button.scale or 1
					optionText = tostring(button.currNum * numScale)
					if button.optionPrefix then
						optionText = button.optionPrefix .. optionText
					end
				end

				if i == menuOption and isSelectable then
					optionText = " < " .. optionText .. " \\#5050ff\\>"
				else
					optionText = ": " .. optionText
				end
				optionText = "\\#5050ff\\ " .. optionText
				text = text .. optionText
			end

			x = 100
			local width = djui_hud_measure_text(remove_color(text)) * textScale
			local testWidth = width / textScale * scale
			local origTextScale = textScale
			if x + 20 * scale + testWidth > screenWidth * 0.7 - tex.width then
				local origScale = textScale
				textScale = textScale / 2
				width = width / origScale * textScale
			end

			if i == menuOption then
				x = x + 20 * scale
			end

			-- Smooth per-button horizontal motion
			if menuMotionButton[i] == nil or not menuMotionEnabled then
				menuMotionButton[i] = {}
				menuMotionButton[i].x = x
				menuMotionButton[i].scale = textScale
			else
				local prevX = menuMotionButton[i].x
				local prevScale = menuMotionButton[i].scale
				local origScale = textScale
				x = smooth_approach(x, prevX, 0.25)
				textScale = smooth_approach(textScale * 10, prevScale * 10, 0.25) / 10
				menuMotionButton[i].x = x
				menuMotionButton[i].scale = textScale
				width = width / origScale * textScale
			end

			local valid = option_valid(button)
			local alpha = (valid and 255) or 100
			if origTextScale ~= textScale then
				y = y + 40 * (origTextScale - textScale) / 2
			end
			djui_hud_print_text_with_color(text, x, y, textScale, alpha)
			if i == menuOption then
				djui_hud_set_color(0, 255, 255, sins(frameCounter * 500) * 50 + 25)
				frameCounter = frameCounter + 1
				if frameCounter >= 60 then
					frameCounter = 0
				end
				djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * textScale + 12)
			end
			if origTextScale ~= textScale then
				y = y - 40 * (origTextScale - textScale) / 2
			end
			y = y + 40 * origTextScale
		end
	end

	-- Right-side description panel
	djui_hud_set_color_from_table(MENU_COLORS.descBg)
	djui_hud_render_rect(screenWidth * 0.7, 0, screenWidth + 10, screenHeight + 10)
	local triY = -tex.height
	while triY < screenHeight do
		djui_hud_render_texture(TEX_TRIANGLE, screenWidth * 0.7 - tex.width, triY, 1, 2)
		triY = triY + tex.height * 2
	end
	if #desc ~= 0 then
		local descScale = 1
		local lines = {}
		local line = ""
		desc = desc:gsub("\n", " \n ")
		local words = split(desc, " ")
		local lineWidth = 0
		local spaceWidth = djui_hud_measure_text(" ") * descScale
		for _, word in ipairs(words) do
			if word == "\n" then
				table.insert(lines, line)
				line = ""
				lineWidth = 0
			else
				local wordWidth = djui_hud_measure_text(remove_color(word)) * descScale
				if lineWidth + wordWidth > screenWidth * 0.3 - 50 then
					table.insert(lines, line)
					line = ""
					lineWidth = 0
				end
				line = line .. word .. " "
				lineWidth = lineWidth + wordWidth + spaceWidth
			end
		end
		if #line ~= 0 then
			table.insert(lines, line)
		end
		local dx = screenWidth * 0.7 + 25
		local dy = (screenHeight / 2) - (#lines * 16 + 16) * descScale
		local colorString = ""
		for _, ln in ipairs(lines) do
			djui_hud_print_text_with_color(colorString .. ln, dx, dy, descScale)
			colorString = ""
			local color = djui_hud_get_color()
			if color.r ~= 255 or color.g ~= 255 or color.b ~= 255 then
				colorString = string.format("\\#%02x%02x%02x\\", color.r, color.g, color.b)
			end
			dy = dy + 32 * descScale
		end
	end

	-- Animated scroll bar
	if scroll then
		local sx = 50 - 16
		local sy = 50
		djui_hud_set_color_from_table(MENU_COLORS.scrollBg)
		djui_hud_render_rect(sx, sy, 20, screenHeight - 100)
		local portion = 1 / totalButtons
		local height = (screenHeight - 104) * portion
		sy = sy + ((screenHeight - 104) - height) * (downBy - 1) / (totalButtons - 1)
		if menuMotionEnabled and menuMotionScrollY ~= -1 then
			local prevSY = menuMotionScrollY
			sy = smooth_approach(sy, prevSY, 0.25)
			menuMotionScrollY = sy
		else
			menuMotionScrollY = sy
		end
		djui_hud_set_color_from_table(MENU_COLORS.scrollBar)
		djui_hud_render_rect(sx + 2, sy + 2, 16, height)
	end
end

sMenuInputsPressed = 0
sMenuInputsDown = 0
---@param m MarioState
function menu_controls(m)
	if m.playerIndex ~= 0 then
		return
	end
	if not inMenu then
		if m.controller.buttonPressed & START_BUTTON ~= 0 then
			m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
			sMenuInputsDown = START_BUTTON
			open_menu()
		else
			return
		end
	end

	if m.freeze < 3 then
		m.freeze = 3
	end

	-- Disable controls for everything but the menu
	sMenuInputsPressed = m.controller.buttonDown & (m.controller.buttonDown ~ sMenuInputsDown)
	sMenuInputsDown = m.controller.buttonDown
	m.controller.buttonDown = 0
	m.controller.buttonPressed = 0
	m.controller.stickX = 0
	m.controller.stickY = 0

	if sMenuInputsPressed & R_TRIG ~= 0 then
		djui_open_pause_menu()
	end

	local stickX = m.controller.rawStickX
	if (sMenuInputsDown & L_JPAD) ~= 0 then
		stickX = stickX - 65
	end
	if (sMenuInputsDown & R_JPAD) ~= 0 then
		stickX = stickX + 65
	end
	local stickY = m.controller.rawStickY
	if (sMenuInputsDown & D_JPAD) ~= 0 then
		stickY = stickY - 65
	end
	if (sMenuInputsDown & U_JPAD) ~= 0 then
		stickY = stickY + 65
	end

	if stickCooldownY > 0 then
		stickCooldownY = stickCooldownY - 1
	end
	if stickCooldownX > 0 then
		stickCooldownX = stickCooldownX - 1
	end

	local menu = menu_data[menuID]
	if not menu then
		inMenu = false
		return
	end
	local button = menu[menuOption]

	if (sMenuInputsPressed & A_BUTTON) ~= 0 and button and button[2] and not button.runOnChange then
		if not option_valid(button) then
			play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
		else
			play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
			button[2](button.currNum, button)
		end
	elseif (sMenuInputsPressed & B_BUTTON) ~= 0 then
		if #menu_history ~= 0 then
			play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
			enter_menu(menu_history[#menu_history][1], menu_history[#menu_history][2], true)
			table.remove(menu_history, #menu_history)
		else
			play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
			m.controller.buttonDown = B_BUTTON
			inMenu = false
		end
	elseif (sMenuInputsPressed & START_BUTTON) ~= 0 then
		play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
		m.controller.buttonDown = START_BUTTON
		inMenu = false
	end

	if not button then
		return
	end

	-- Horizontal stick: change numeric values
	if button.currNum and stickCooldownX == 0 and (stickX > 64 or stickX < -64) and option_valid(button) then
		local min = button.minNum or 0
		local max = button.maxNum or 999
		local change = 1
		-- Hold X for ×10 increments on wide-range options
		local changeScale = (max - min >= 10 and sMenuInputsDown & X_BUTTON ~= 0 and 10) or 1
		if stickX < 0 then
			change = -change
		end

		play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
		button.currNum = button.currNum + change * changeScale

		if max < button.currNum then
			button.currNum = min
		elseif min > button.currNum then
			button.currNum = max
		elseif button.currNum == button.excludeNum then
			button.currNum = button.currNum + change
		end

		-- Skip disconnected players when using playerRef
		if button.playerRef and button.currNum >= 0 and button.currNum < MAX_PLAYERS then
			local np = gNetworkPlayers[button.currNum]
			while not np.connected do
				button.currNum = button.currNum + change
				if max < button.currNum then
					button.currNum = min
				elseif button.currNum == button.excludeNum then
					button.currNum = button.currNum + change
				end
				if button.currNum < 0 or button.currNum >= MAX_PLAYERS then
					break
				end
				np = gNetworkPlayers[button.currNum]
			end
		end

		stickCooldownX = 5
		if button.runOnChange and button[2] then
			button[2](button.currNum, button)
			if (network_is_server() or button.localSave) and button.save then
				mod_storage_save(button.save, tostring(button.currNum))
			end
		end
	end

	-- Vertical stick: navigate buttons
	if #menu > 1 and stickCooldownY == 0 then
		if stickY > 64 then
			play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
			local valid = true
			local LIMIT = #menu
			while valid and LIMIT ~= 0 do
				LIMIT = LIMIT - 1
				menuOption = menuOption - 1
				if menuOption < 1 then
					menuOption = #menu
				end
				button = menu[menuOption]
				valid = not option_valid(button, true)
			end
			stickCooldownY = 5
		elseif stickY < -64 then
			play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
			local valid = true
			local LIMIT = #menu
			while valid and LIMIT ~= 0 do
				LIMIT = LIMIT - 1
				menuOption = menuOption + 1
				if #menu < menuOption then
					menuOption = 1
				end
				button = menu[menuOption]
				valid = not option_valid(button, true)
			end
			stickCooldownY = 5
		end
	end
end

function open_menu()
	inMenu = not inMenu
	if inMenu then
		menu_history = {}
		menuMotionButton = {}
		resetMenuMotion = true
		sMenuInputsDown = gMarioStates[0].controller.buttonDown
		enter_menu(1, 1, true)
		play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
	end
	return true
end

function enter_menu(id, option, back)
	if not back then
		table.insert(menu_history, { menuID, menuOption })
	end

	menuMotionButton = {}
	if not inMenu then
		inMenu = true
		resetMenuMotion = true
		menu_history = {}
		sMenuInputsDown = gMarioStates[0].controller.buttonDown
	end
	menuID = id or 1
	menuOption = option or 1

	local menu = menu_data[menuID]
	if not menu then
		inMenu = false
		return
	elseif menu.buildFunc then
		menu_data[menuID] = { buildFunc = menu.buildFunc }
		menu = menu_data[menuID]
		menu.buildFunc(menu)
	end

	local totalValid = 0
	local lastValidOption = 0
	for i = 1, #menu do
		if option_valid(menu[i], true) then
			totalValid = totalValid + 1
			lastValidOption = i
		elseif menuOption == i then
			if lastValidOption == 0 then
				menuOption = menuOption + 1
			else
				menuOption = lastValidOption
			end
		end
	end

	if totalValid == 0 then
		if #menu_history ~= 0 then
			enter_menu(menu_history[#menu_history][1], menu_history[#menu_history][2], true)
			table.remove(menu_history, #menu_history)
		else
			inMenu = false
		end
		return
	end

	for i, button in ipairs(menu) do
		if button.save then
			local value = 0
			if not button.localSave then
				value = gGlobalSyncTable[button.save]
			else
				value = _ENV[button.save]
			end
			if type(value) == "boolean" then
				button.currNum = (value and 1) or 0
			elseif type(value) == "number" and value % 1 == 0 then
				button.currNum = value
				local min = button.minNum or 0
				local max = button.maxNum or 100
				if value < min then
					button.currNum = min
				elseif value > max then
					button.currNum = max
				end
			end
		end
		if button.updateNum then
			button.updateNum(button)
		end
	end
end

function reload_menu()
	enter_menu(menuID, menuOption, true)
end

function set_menu_option(id, option, value)
	menu_data[id][option].currNum = value
end

function get_menu_option(id, option)
	return menu_data[id][option].currNum
end

-- Two-argument version: ignoreSelect skips selectInvalid checks,
-- matching the WarioWare behaviour used for visibility vs. interactability.
function option_valid(button, ignoreSelect)
	if (not ignoreSelect) and button.selectInvalid and button.selectInvalid() then
		return false
	end
	if button[3] and not (network_is_server() or network_is_moderator()) then
		return false
	elseif button[4] then
		return (not button[4]())
	end
	return true
end

-- Load saved menu settings on startup
for a, menu in ipairs(menu_data) do
	for b, button in ipairs(menu) do
		if (network_is_server() or button.localSave) and button.save then
			local value = tonumber(mod_storage_load(button.save))
			local min = button.minNum or 0
			local max = button.maxNum or 999
			if value and value % 1 == 0 and button.currNum and value >= min and value <= max then
				button[2](value, button)
				button.currNum = value
			end
		end
	end
end

-- CS support
if charSelectExists then
	charSelect.restrict_palettes(false)
end
