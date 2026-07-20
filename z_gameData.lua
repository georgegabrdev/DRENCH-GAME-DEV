local duelSideTimer = 30
local sonicMingleRingTimer = 0
local prevDiceSpeedBoost = false

local coinRainSpawnTimer = 0
local coinRainInterval = 10 -- spawn every 20 frames

GAME_MODE_DATA = {
	[GAME_MODE_GLASS] = {
		name = "Glass Bridge",
		desc = "Get across the bridge without falling! Only one glass pane is safe in each row. Will you push your luck, or let someone else take the fall?",
		level = LEVEL_GLASS,
		interact = PLAYER_INTERACTIONS_SOLID,
		kbStrength = 5,
		music = "dire",
		fasterActions = true,
		marioUpdateFunc = function(m) -- switch to custom falling action
			if
				m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE
				and m.action ~= ACT_GB_FALL
				and m.action ~= ACT_SPECTATE
				and m.floor
				and m.floor.type == SURFACE_DEATH_PLANE
				and m.vel.y <= -75
				and m.pos.y - m.floorHeight <= 8000
			then
				set_mario_action(m, ACT_GB_FALL, 0)
			end
		end,
		victoryFunc = function(m)
			if m.action & ACT_FLAG_AIR == 0 and m.floor and m.floor.type == SURFACE_TIMER_END then
				if gPlayerSyncTable[m.playerIndex].roundScore >= 10 then
					return true
				elseif m.playerIndex == 0 then
					play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
					djui_chat_message_create("\\#ff5050\\You aren't allowed to skip any glass panes!")
					set_to_spawn_pos(m, true)
				end
			end
			return false
		end,
		startingSetup = function()
			-- spawn thwomps for all players
			for i = 0, MAX_PLAYERS - 1 do
				local m = gMarioStates[i]
				spawn_object_no_rotate(id_bhvGBThwomp, E_MODEL_THWOMP, m.pos.x, m.pos.y + 1000, m.pos.z, function(o)
					o.oBehParams = i
				end, false)
			end
		end,
		allowPvpFunc = function(attacker, victim, interaction)
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			local sVictim = gPlayerSyncTable[victim.playerIndex]

			if sAttacker.roundScore == 0 or sVictim.roundScore == 0 then
				return false
			end
		end,
	},
	[GAME_MODE_LIGHTS_OUT] = {
		name = "Lights Out",
		desc = "This is a simple game: Stay alive. You'll earn 10 points for surviving this game. You could attack other players for some extra points... but wouldn't that be risky?",
		descElim = "This is a simple game: Stay alive. There's nothing to hurt you here unless you start attacking each other or something. But why would you do that?",
		maxTime = 3 * 60 * 30, -- 3 minutes
		level = LEVEL_LIGHTS_OUT,
		interact = PLAYER_INTERACTIONS_PVP,
		music = "dire",
		fallDamage = true,
		showHealthSpec = true,
		marioUpdateFunc = function(m)
			if m.playerIndex ~= 0 then
				return
			end
			if gGlobalSyncTable.eliminationMode then
				return
			end
			local sMario = gPlayerSyncTable[0]
			local currentPoints = (lightsOutDamageDealt // 2) -- 1 point for every 2 damage dealt
			if (not gGlobalSyncTable.eliminationMode) and currentPoints > sMario.earnedPoints then
				local newPoints = (currentPoints - sMario.earnedPoints)
				sMario.earnedPoints = currentPoints
				djui_chat_message_create("\\#ffff50\\+" .. newPoints .. " point(s) (" .. newPoints * 2 .. " DMG)")
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			end
		end,
		pointCalcFunc = function(index) -- 10 points on top of existing points
			local sMario = gPlayerSyncTable[index]
			return sMario.earnedPoints + 10
		end,
		hostUpdateFunc = function()
			if gGlobalSyncTable.gameTimer == 1 then
				lightsOutTimeUntilBlackout = math.random(15, 60) * 30 -- 15-60 seconds
			end
			lightsOutTimeUntilBlackout = lightsOutTimeUntilBlackout - 1
			if lightsOutTimeUntilBlackout == 0 then
				lightsOutTimeUntilBlackout = math.random(15, 60) * 30 -- 15-60 seconds
				network_send_include_self(true, { id = PACKET_BLACKOUT })
			end
		end,
		onPvpFunc = function(attacker, victim, interaction)
			local sVictim = gPlayerSyncTable[victim.playerIndex]
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			if sVictim.team == 0 or sAttacker.team ~= sVictim.team then
				network_send_to(attacker.playerIndex, true, {
					id = PACKET_DAMAGE,
					damage = victim.hurtCounter // 4,
				})
			end
		end,
		nametagFunc = function(index, pos, name)
			-- disable nametags unless we are spectating
			if index ~= 0 and gMarioStates[0].action ~= ACT_SPECTATE then
				return ""
			end
		end,
	},
	[GAME_MODE_RED_GREEN_LIGHT] = {
		name = "Red Light, Green Light",
		desc = 'Reach the finish line! When Toad shouts "Red Light!", don\'t let him see you moving! You can move behind obstacles to avoid being seen. Tread carefully!',
		maxTime = 2 * 60 * 30, -- 2 minutes
		level = LEVEL_RGLIGHT,
		music = "", -- no music
		interact = PLAYER_INTERACTIONS_SOLID,
		kbStrength = 10,
		nerfSonic = true,
		fasterActions = true,
		victoryFunc = function(m)
			return (m.floor and m.floor.type == SURFACE_TIMER_END)
		end,
	},
	[GAME_MODE_MINGLE] = {
		name = "Mingle",
		desc = "Stay on the carousel ride! When Waluigi calls a number, enter a room with EXACTLY that many players- no more, no less. Use the switch inside of the room to lock players out. Cooperation is key!",
		level = LEVEL_MINGLE,
		interact = PLAYER_INTERACTIONS_SOLID,
		kbStrength = 10,
		showHealth = true,
		roundTime = 13 * 30, -- 13 seconds
		music = "mingle",
		doEliminationPoints = true,
		marioUpdateFunc = function(m)
			if (not gGlobalSyncTable.mingleHurry) and (m.floor == nil or m.floor.object == nil) then
				if m.playerIndex == 0 and mingleWasOnCarousel then
					mingleWasOnCarousel = false
					play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
					djui_chat_message_create("\\#ff5050\\Stay on the carousel!")
				end
				m.health = m.health - 8

				-- Extra chars sonic support
				if m.playerIndex == 0 then
					sonicMingleRingTimer = sonicMingleRingTimer + 1
					if sonicMingleRingTimer >= 15 then
						sonic_lose_one_ring(0)
						sonicMingleRingTimer = 0
					end
				end
			elseif m.playerIndex == 0 then
				mingleWasOnCarousel = true
				sonicMingleRingTimer = 0
			end
		end,
		eliminateFunc = function() -- eliminate players not in a room with the right amount of people
			local eliminated = 0
			local roomData = {}
			for_each_connected_player(function(i)
				local m = gMarioStates[i]
				local sMario = gPlayerSyncTable[i]
				if not sMario.eliminated then
					local roomNum = 0
					local o = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvLockSwitch)
					if o and dist_between_objects(m.marioObj, o) <= 1000 then
						roomNum = o.oBehParams2ndByte + 1
					end
					if roomData[roomNum] == nil then
						roomData[roomNum] = {}
					end
					table.insert(roomData[roomNum], m)
				end
			end)
			for a, room in pairs(roomData) do
				if DEBUG_MODE then
					log_to_console(tostring(a) .. ": " .. tostring(#room))
				end
				if a == 0 or #room ~= gGlobalSyncTable.minglePlayerCount then
					for b, m in ipairs(room) do
						eliminated = eliminated + 1
						eliminate_mario(m)
					end
				end
			end
			return eliminated
		end,
		hostUpdateFunc = function()
			if
				((not gGlobalSyncTable.mingleHurry) and gGlobalSyncTable.roundTimer < 89)
				or gGlobalSyncTable.roundTimer == 89
			then
				gGlobalSyncTable.roundTimer = 90
				gGlobalSyncTable.freezeRoundTimer = true
				local low = 27
				local high = 45
				if gGlobalSyncTable.round ~= 1 then
					low = 3 -- after round 1, we can call players early
				end
				local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode]
				local maxTime = gData.maxTime or 3 * 30 * 60 -- default 3 minutes max
				if gData.maxRounds and gData.roundTime and gData.roundTime > 0 then
					maxTime = gData.firstRoundTime or gData.roundTime
					maxTime = maxTime + gData.roundTime * (gData.maxRounds - 1)
				end
				-- there isn't 90 seconds left, change max time to half of the remaining time
				if high * 60 > maxTime - gGlobalSyncTable.gameTimer then
					high = (maxTime - gGlobalSyncTable.gameTimer) // 60
					if low > high then -- set time too high to occur
						low = 100
						high = 100
					end
				end
				gGlobalSyncTable.mingleSpinTime = math.random(low, high) * 30
				if gGlobalSyncTable.mingleHurry then
					gGlobalSyncTable.mingleHurry = false
					network_send_include_self(true, {
						id = PACKET_MINGLE_RESTART,
					})
				end
			elseif not gGlobalSyncTable.mingleHurry then
				gGlobalSyncTable.roundTimer = 90
				gGlobalSyncTable.freezeRoundTimer = true
				gGlobalSyncTable.mingleSpinTime = gGlobalSyncTable.mingleSpinTime - 1
				if gGlobalSyncTable.mingleSpinTime <= 0 then
					gGlobalSyncTable.mingleHurry = true
					gGlobalSyncTable.freezeRoundTimer = false
					local alivePlayers = 0
					for_each_connected_player(function(i)
						local sMario = gPlayerSyncTable[i]
						if not sMario.eliminated then
							alivePlayers = alivePlayers + 1
						end
						if alivePlayers >= 5 then
							return true
						end
					end)
					local maxPlayerCount = alivePlayers
					if not gGlobalSyncTable.eliminationMode then
						-- ensure game eliminates everyone
						maxPlayerCount = maxPlayerCount - 1
					end
					maxPlayerCount = clamp(maxPlayerCount, 1, 4)
					gGlobalSyncTable.minglePlayerCount = math.random(1, maxPlayerCount)
					local mingleMaxDoors = 8
					-- after 2 rounds, there will be a limited number of doors available
					if DEBUG_MODE or gGlobalSyncTable.round > 2 then
						mingleMaxDoors = maxPlayerCount // gGlobalSyncTable.minglePlayerCount
						if DEBUG_MODE then
							mingleMaxDoors = 3
						end

						local mingleDoorsOpen = 0 -- bitwise value representing which doors are open
						local availableToOpen = {}
						for i = 0, 7 do
							table.insert(availableToOpen, i)
						end
						for i = 1, mingleMaxDoors do
							local tableIndex = math.random(1, #availableToOpen)
							local door = availableToOpen[tableIndex]
							table.remove(availableToOpen, tableIndex)
							mingleDoorsOpen = mingleDoorsOpen | (1 << door)
						end
						gGlobalSyncTable.mingleDoorsOpen = mingleDoorsOpen
					end

					gGlobalSyncTable.mingleMaxDoors = mingleMaxDoors
					network_send_include_self(true, {
						id = PACKET_MINGLE_CALLOUT,
						count = gGlobalSyncTable.minglePlayerCount,
					})
				end
			end
		end,
		kbStrengthOverrideFunc = function()
			return (gGlobalSyncTable.mingleHurry and 20)
		end,
		hudRenderFunc = function(
			screenWidth,
			screenHeight,
			sideBarLines,
			lengthLimit,
			roundTime,
			roundTimeLeft,
			gameTimeLeft,
			maxTime
		)
			-- displays player count on sidebar too
			if
				gGlobalSyncTable.mingleHurry
				and roundTime ~= 0
				and roundTimeLeft <= 10 * 30
				and gameTimeLeft >= roundTimeLeft
			then
				local text = tostring(gGlobalSyncTable.minglePlayerCount) .. " player"
				if gGlobalSyncTable.minglePlayerCount ~= 1 then
					text = text .. "s"
				end
				add_line_to_table(sideBarLines, text, lengthLimit)
				add_line_to_table(sideBarLines, get_time_string(roundTimeLeft) .. " until elimination", lengthLimit)
			elseif maxTime ~= -1 then
				add_line_to_table(sideBarLines, get_time_string(gameTimeLeft) .. " until game ends", lengthLimit)
			else
				return true, true -- no side bar
			end
			return true
		end,
	},
	[GAME_MODE_STAR_STEAL] = {
		name = "Star Steal",
		desc = "Get the Star, and hold it to increase your score! Hit a player to take the Star from them! You'll be eliminated if your score is too low. Hmmm, this seems familiar...",
		level = { LEVEL_TOAD_TOWN, LEVEL_KOOPA_KEEP }, -- selects toad town or koopa keep
		interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
		firstRoundTime = 90 * 30, -- 1 minute and 30 seconds
		roundTime = 30 * 30, -- 30 seconds
		maxRounds = 5,
		autoElimination = true,
		doEliminationPoints = true,
		mercyRuleScale = 10, -- Max points we can gain in 1 second, used to calculate mercy rule
		nerfSonic = true,
		fasterActions = true,
		marioUpdateFunc = function(m) -- earn points when holding star, and give to nearest opponent on hit
			local sMario = gPlayerSyncTable[m.playerIndex]
			local gIndex = network_global_index_from_local(m.playerIndex)
			m.health = 0x880
			sonic_set_full_rings(m.playerIndex)
			if gIndex == gGlobalSyncTable.starStealOwner then
				-- speed cap
				if m.forwardVel > 40 then
					m.forwardVel = 40
				end
				m.particleFlags = m.particleFlags | PARTICLE_SPARKLES

				-- don't continue if we're not the local player
				if m.playerIndex ~= 0 then
					m.hurtCounter = 0
					return
				end

				if m.hurtCounter ~= 0 then
					m.hurtCounter = 0
					-- give to nearest opponent
					local maxDist = 10000
					local selectedPlayer = 0
					for_each_connected_player(function(index)
						if index == 0 then
							return
						end
						local sMario2 = gPlayerSyncTable[index]
						if sMario2.eliminated then
							return
						end
						if sMario2.team and sMario2.team ~= 0 and sMario2.team == sMario.team then
							return
						end
						local dist = dist_between_objects(gMarioStates[index].marioObj, m.marioObj)
						if dist < maxDist then
							maxDist = dist
							selectedPlayer = index
						end
					end)
					if selectedPlayer ~= 0 then
						gGlobalSyncTable.starStealOwner = network_global_index_from_local(selectedPlayer)
						-- send packet to notify about steal
						network_send_include_self(true, {
							id = PACKET_STAR_STEAL,
							oldOwner = gIndex,
							newOwner = gGlobalSyncTable.starStealOwner,
						})
					end
				else
					playerLocalTimer = playerLocalTimer + 1
					if playerLocalTimer >= 3 then
						playerLocalTimer = 0
						attempt_raise_score(sMario)
					end
				end
			elseif m.playerIndex == 0 then
				playerLocalTimer = 0
			end
		end,
		onPvpFunc = function(attacker, victim, interaction)
			local gIndex = network_global_index_from_local(0)
			victim.hurtCounter = 0
			if gGlobalSyncTable.starStealOwner == gIndex then
				gGlobalSyncTable.starStealOwner = network_global_index_from_local(attacker.playerIndex)
				-- send packet to notify about steal
				network_send_include_self(true, {
					id = PACKET_STAR_STEAL,
					oldOwner = gIndex,
					newOwner = gGlobalSyncTable.starStealOwner,
				})
			end
		end,
	},
	[GAME_MODE_BOMB_TAG] = {
		name = "Bomb Tag",
		desc = "Don't hold a Bob-Omb! Tag another player to pass your Bob-Omb to them. If you're holding a Bob-Omb when time runs out... you can probably guess what happens.",
		level = { LEVEL_TOAD_TOWN, LEVEL_KOOPA_KEEP }, -- selects toad town or koopa keep
		interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
		kbStrength = 10,
		roundTime = 30 * 30, -- 30 seconds
		maxRounds = 6,
		nerfSonic = true,
		fasterActions = true,
		marioUpdateFunc = function(m)
			local sMario = gPlayerSyncTable[m.playerIndex]
			m.health = 0x880
			sonic_set_full_rings(m.playerIndex)
			if m.action == ACT_LAVA_BOOST then
				set_to_spawn_pos(m, true)
				if not sMario.holdingBomb then
					m.freeze = 30
					set_mario_action(m, ACT_GB_FALL, 0)
				end
			end
			if m.playerIndex == 0 then
				if sMario.holdingBomb then
					playerLocalTimer = playerLocalTimer + 1
					if playerLocalTimer >= 3 then
						playerLocalTimer = 0
						sMario.roundScore = sMario.roundScore + 1
					end
				else
					playerLocalTimer = 0
				end
			end
		end,
		doEliminationPoints = true,
		eliminateFunc = function() -- eliminate all players that are holding a bomb
			local eliminated = 0
			for_each_connected_player(function(i)
				local sMario = gPlayerSyncTable[i]
				if (not sMario.eliminated) and sMario.holdingBomb then
					eliminated = eliminated + 1
					eliminate_mario(gMarioStates[i])
				end
			end)
			return eliminated
		end,
		hostUpdateFunc = function() -- assign bombs at start of bomb tag
			if gGlobalSyncTable.roundTimer ~= 1 then
				return
			end

			local aliveTable = {}
			for_each_connected_player(function(i)
				local sMario = gPlayerSyncTable[i]
				if not sMario.eliminated then
					sMario.holdingBomb = false
					table.insert(aliveTable, i)
				end
			end)
			local bombsToAssign = calculate_players_to_eliminate(false, true)

			-- shuffle table
			for i = #aliveTable, 2, -1 do
				local j = math.random(i)
				aliveTable[i], aliveTable[j] = aliveTable[j], aliveTable[i]
			end
			-- sort table so that the players with the least held time will get the bombs
			-- (we still do the shuffle first in case of ties)
			if gGlobalSyncTable.round ~= 1 then
				table.sort(aliveTable, function(a, b)
					local aHeldTime = (gPlayerSyncTable[a].roundScore or 0)
					local bHeldTime = (gPlayerSyncTable[b].roundScore or 0)
					return aHeldTime < bHeldTime
				end)
			end

			while bombsToAssign ~= 0 and #aliveTable ~= 0 do
				local index = aliveTable[1]
				gPlayerSyncTable[index].holdingBomb = true
				table.remove(aliveTable, 1)
				bombsToAssign = bombsToAssign - 1
			end
		end,
		startingSetup = function()
			-- spawn visible bombs for all players
			for i = 0, MAX_PLAYERS - 1 do
				local m = gMarioStates[i]
				spawn_object_no_rotate(id_bhvBTBomb, E_MODEL_BLACK_BOBOMB, m.pos.x, m.pos.y + 250, m.pos.z, function(o)
					o.oBehParams = i
				end, false)
			end
		end,
		descFunc = function(index)
			if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then
				return
			end
			local sMario = gPlayerSyncTable[index]
			if sMario.eliminated then
				return
			end
			if not sMario.holdingBomb then
				return
			end

			return "Bomb", false, true -- desc, highlight, yellow
		end,
		onPvpFunc = function(attacker, victim, interaction)
			victim.hurtCounter = 0
			local sVictim = gPlayerSyncTable[victim.playerIndex]
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			if sAttacker.holdingBomb and not sVictim.holdingBomb then
				sAttacker.holdingBomb = false
				sVictim.holdingBomb = true
			end
		end,
		rejoinFunc = function(sMario)
			-- If we rejoin mid-round, we automatically get a bomb
			if not sMario.eliminated then
				sMario.holdingBomb = true
			end
		end,
		beforePhysStepFunc = function(m, stepType)
			-- Speed boost for bomb players; don't affect custom or knockback actions
			if
				gPlayerSyncTable[m.playerIndex].holdingBomb
				and m.action & (ACT_FLAG_INVULNERABLE | ACT_FLAG_CUSTOM_ACTION) == 0
			then
				m.vel.x = m.vel.x * 1.1
				m.vel.z = m.vel.z * 1.1
			end
		end,
	},
	[GAME_MODE_KOTH] = {
		name = "King Of The Hill",
		desc = "Get to the top of the hill! Stand in the circle to increase your score. You'll earn more points if you're alone in the circle. If your score is too low when time runs out, you'll be eliminated! Stand your ground!",
		descTeams = "Get to the top of the hill! Stand in the circle to increase your score. You'll earn more points if only your team is in the circle. If your score is too low when time runs out, you'll be eliminated! Stand your ground!",
		level = LEVEL_KOTH,
		interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
		kbStrength = 25,
		firstRoundTime = 60 * 30, -- 1 minute
		roundTime = 30 * 30, -- 30 seconds
		maxRounds = 5,
		autoElimination = true,
		doEliminationPoints = true,
		fasterActions = true,
		mercyRuleScale = 20, -- Max points we can gain in 1 second, used to calculate mercy rule
		marioUpdateFunc = function(m) -- full health, and that's it
			m.health = 0x880
			sonic_set_full_rings(m.playerIndex)
		end,
	},
	[GAME_MODE_DUEL] = {
		name = "Duel",
		desc = "Defeat your opponent(s)! Have the most health or be the last one standing to earn a point. Get 2 points to win the minigame! It's time to LOCK IN.",
		descElim = "Defeat your opponent(s)! Have the most health or be the last one standing to earn a point. Get 2 points to win it ALL. It's time to LOCK IN.",
		descTeams = "It's team versus team! Have the most health or be the last one standing to earn your team a point. Get 2 points to win the minigame! It's time to LOCK IN.",
		descTeamsElim = "It's team versus team! Have the most health or be the last one standing to earn your team a point. Get 2 points to win it ALL. It's time to LOCK IN.",
		level = LEVEL_DUEL,
		interact = PLAYER_INTERACTIONS_PVP,
		maxTime = -1, -- NO max time
		roundTime = 63 * 30, -- 1:03 (3 is for the countdown)
		music = "final",
		kbStrength = 25,
		showHealth = true,
		victoryFunc = function(m)
			return false -- prevent elimination end
		end,
		hostUpdateFunc = function()
			if gGlobalSyncTable.duelState == DUEL_STATE_WAIT then
				if gGlobalSyncTable.roundTimer >= 90 or gGlobalSyncTable.round == 1 then
					gGlobalSyncTable.roundTimer = 90
					gGlobalSyncTable.duelState = DUEL_STATE_ACTIVE
				end
			elseif gGlobalSyncTable.duelState == DUEL_STATE_ACTIVE then
				-- sudden death bombs
				if gGlobalSyncTable.freezeRoundTimer then
					duelBombSpawnTimer = duelBombSpawnTimer + 1
					if duelBombSpawnTimer >= 10 * 30 and duelBombSpawnTimer % duelTimeUntilBomb == 0 then
						local x, y, z = math.random(-2500, 2500), 2000, math.random(-2500, 2500)
						spawn_object_no_rotate(id_bhvFallingBomb, E_MODEL_BLACK_BOBOMB, x, y, z, function(o)
							o.oVelY = -50
							o.oMoveAngleYaw = math.random(0, 0xFFFF)
						end, true)
						if duelBombSpawnTimer == 10 * 30 then
							create_warning_popup("Bombs are falling in the sky!")
						end
						if duelTimeUntilBomb > 5 then
							duelTimeUntilBomb = duelTimeUntilBomb - 1
						end
					end
				else
					duelBombSpawnTimer = 0
					duelTimeUntilBomb = 30
				end

				local alivePlayers = 0
				local aliveTeams = 0
				local teamCounted = {}
				local duelers = 0
				local aliveIndex = -1
				local maxScore = 0
				for_each_connected_player(function(index)
					local sMario = gPlayerSyncTable[index]
					if sMario.validForDuel then
						duelers = duelers + 1
						if maxScore < sMario.roundScore then
							maxScore = sMario.roundScore
						end
						if sMario.victory then
							-- skip to end
							duelers = 1
							alivePlayers = 1
							aliveIndex = index
							return true
						elseif not sMario.eliminated then
							alivePlayers = alivePlayers + 1
							aliveIndex = index
							-- count alive teams
							if sMario.team and sMario.team ~= 0 then
								if not teamCounted[sMario.team] then
									teamCounted[sMario.team] = 1
									aliveTeams = aliveTeams + 1
								end
							else
								aliveTeams = aliveTeams + 1
							end

							if alivePlayers >= 2 and gGlobalSyncTable.teamCount == 0 then
								return true
							end
						end
					end
				end)
				if aliveTeams <= 1 and ((not do_solo_debug()) or aliveTeams <= 0) then
					gGlobalSyncTable.roundTimer = 0
					gGlobalSyncTable.round = gGlobalSyncTable.round + 1
					gGlobalSyncTable.duelState = DUEL_STATE_END

					local toWin = 2
					if aliveIndex ~= -1 then
						local sMario = gPlayerSyncTable[aliveIndex]
						if duelers <= 1 then
							sMario.roundScore = toWin -- end immediately
						else
							sMario.roundScore = sMario.roundScore + 1
						end
						if maxScore < sMario.roundScore then
							maxScore = sMario.roundScore
							if gGlobalSyncTable.round > 5 then
								sMario.roundScore = toWin -- end immediately
							end
						end
						if sMario.roundScore >= toWin then
							sMario.victory = true
							-- make sure all teammates also win
							if sMario.team and sMario.team ~= 0 then
								for_each_connected_player(function(i)
									local sMario2 = gPlayerSyncTable[i]
									if sMario2.team == sMario.team then
										sMario2.victory = true
									end
								end)
							end
							return true -- end game
						end
					end

					-- if past round five, run tiebreaker round
					if gGlobalSyncTable.round > 5 then
						for_each_connected_player(function(i)
							local sMario = gPlayerSyncTable[i]
							if sMario.roundScore == maxScore then
								sMario.roundScore = toWin - 1
							end
						end)
					end
				end
			elseif gGlobalSyncTable.duelState == DUEL_STATE_END then
				gGlobalSyncTable.freezeRoundTimer = false
				if gGlobalSyncTable.roundTimer >= 150 then
					gGlobalSyncTable.roundTimer = 0
					gGlobalSyncTable.duelState = DUEL_STATE_WAIT
				end
			end
			return false -- prevent game end
		end,
		eliminateFunc = function()
			-- when the round ends, the one with greater health wins
			-- on tie, HP is set to 1
			gGlobalSyncTable.round = gGlobalSyncTable.round - 1
			gGlobalSyncTable.freezeRoundTimer = true
			local aliveTable = {}
			local maxHealth = 0xFF
			for_each_connected_player(function(index)
				local sMario = gPlayerSyncTable[index]
				if sMario.validForDuel and not sMario.eliminated then
					table.insert(aliveTable, index)
					local health = gMarioStates[index].health
					if maxHealth < health then
						maxHealth = health
					end
				end
			end)
			for i, index in ipairs(aliveTable) do
				local m = gMarioStates[index]
				if m.health < maxHealth then
					eliminate_mario(m)
				end
			end
			return 0
		end,
		globalUpdateFunc = function()
			local toWin = 2
			local m0 = gMarioStates[0]
			local sMario0 = gPlayerSyncTable[0]
			if gGlobalSyncTable.duelState == DUEL_STATE_WAIT then
				duelEnding = false
				local valid = sMario0.validForDuel and not sMario0.spectator
				if gGlobalSyncTable.round > 5 and (duelLastState ~= DUEL_STATE_WAIT) then
					djui_chat_message_create("Tiebreaker round!")
					if sMario0.roundScore < toWin - 1 then
						valid = false
					end
				end
				if valid then
					sMario0.eliminated = false
					m0.health = 0x880
					sonic_set_full_rings(0)
					if m0.action == ACT_SPECTATE then
						m0.action = ACT_FREEFALL
					end
					set_to_spawn_pos(m0, (duelLastState ~= DUEL_STATE_WAIT))
					if gGlobalSyncTable.roundTimer > 90 then
						desyncTimer = desyncTimer + 1
						if desyncTimer >= 30 then
							desyncTimer = 0
							if not network_is_server() then
								network_send_to(1, true, {
									id = PACKET_REQUEST_DESYNC_FIX,
									from = network_global_index_from_local(0),
								})
							end
						end
					else
						desyncTimer = 0
					end
				end
			end
			duelLastState = gGlobalSyncTable.duelState

			-- slow down time on KO
			local aliveIndex = -1
			local alivePlayers = 0
			local someoneDying = false
			for_each_connected_player(function(index)
				local m = gMarioStates[index]
				local sMario = gPlayerSyncTable[index]
				if not sMario.eliminated then
					if m.health > 0xFF then
						alivePlayers = alivePlayers + 1
						aliveIndex = index
						if alivePlayers >= 2 then
							return true
						end
					else
						someoneDying = true
					end
				end
			end)
			if alivePlayers < 2 and someoneDying and m0.area and m0.area.localAreaTimer % 2 == 0 then
				if alivePlayers == 1 then
					local sMario = gPlayerSyncTable[aliveIndex]
					duelEnding = (sMario.roundScore >= toWin - 1)
				else
					duelEnding = false
				end
				enable_time_stop_including_mario()
			else
				disable_time_stop()
			end
		end,
		marioUpdateFunc = function(m)
			local sMario = gPlayerSyncTable[0]
			if m.health == 0x880 and sMario.validForDuel and m.action ~= ACT_SPECTATE then
				set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
			end
			if m.playerIndex ~= 0 then
				return
			end

			if not sMario.validForDuel then
				sMario.eliminated = true
				localWasEliminated = true
				return
			end

			-- make sure we have the same score as our teammates
			if gGlobalSyncTable.teamMode ~= 0 then
				for_each_connected_player(function(i)
					local sMario2 = gPlayerSyncTable[i]
					if sMario2.team ~= 0 and sMario2.team == sMario.team and sMario2.roundScore > sMario.roundScore then
						sMario.roundScore = sMario2.roundScore
					end
				end)
			end

			-- one health in sudden death
			if m.health > 0x100 and gGlobalSyncTable.freezeRoundTimer then
				m.health = 0x100
			end

			if m.health <= 0xFF and not sMario.eliminated then
				duelDeathTimer = duelDeathTimer + 1
				if duelDeathTimer >= 20 then
					eliminate_mario(m)
				end
			else
				duelDeathTimer = 0
			end
		end,
		descFunc = function(index)
			local sMario = gPlayerSyncTable[index]
			return tostring(sMario.roundScore or 0), not sMario.eliminated -- desc, highlight
		end,
		onPvpFunc = function(attacker, victim, interaction)
			local sVictim = gPlayerSyncTable[victim.playerIndex]
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			if sVictim.team == 0 or sAttacker.team ~= sVictim.team then
				duelLastAttacker = attacker.playerIndex
			end
		end,
		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit, roundTime, roundTimeLeft)
			if gGlobalSyncTable.duelState == DUEL_STATE_WAIT then
				duelSideTimer = 30

				-- center countdown
				local number = (90 - gGlobalSyncTable.roundTimer) // 30 + 1
				if number <= 3 and number >= 1 then
					if lastCountdownNumber ~= number then
						lastCountdownNumber = number
						countdownTimer = 0
						play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
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
				return true, true -- no side bar
			elseif gGlobalSyncTable.duelState == DUEL_STATE_ACTIVE then
				duelSideTimer = 30
				if roundTime ~= 0 then
					add_line_to_table(sideBarLines, get_time_string(roundTimeLeft) .. " until round ends", lengthLimit)
					if roundTimeLeft <= 300 then
						local num = math.ceil(roundTimeLeft / 30)
						if lastCountdownNumber ~= num then
							lastCountdownNumber = num
							play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
						end
					else
						lastCountdownNumber = 0
					end
				else
					add_line_to_table(sideBarLines, "\\#ff5050\\Sudden Death!", lengthLimit)
				end
			elseif gGlobalSyncTable.duelState == DUEL_STATE_END then
				lastCountdownNumber = 0
				duel_hud()
				return true, true -- no side bar
			end
			return true
		end,
		losePointCalcFunc = function(index)
			-- Earn 10 points if you get one win
			local sMario = gPlayerSyncTable[index]
			return math.min(sMario.roundScore * 10, 20)
		end,
	},
	[GAME_MODE_DICE] = {
		name = "Dice Block Battle",
		desc = "Ready to test your luck? You have a 5% chance to kill a player when you hit them, but each failed roll will increase your odds by 10%! Also, getting hit will increase your odds by 5%. Be the last one standing to win!",
		descElim = "Ready to test your luck? You have a 5% chance to kill a player when you hit them, but each failed roll will increase your odds by 10%! Also, getting hit will increase your odds by 5%. Who will survive?",
		level = { LEVEL_TOAD_TOWN, LEVEL_KOOPA_KEEP }, -- selects toad town or koopa keep
		interact = PLAYER_INTERACTIONS_PVP, -- so invulnerability frames exist
		kbStrength = 25,
		doPlacementPoints = true,
		music = "sliderCasino",
		nerfSonic = true,
		marioUpdateFunc = function(m) -- full health and lava respawn
			if m.action == ACT_LAVA_BOOST then
				set_to_spawn_pos(m, true)
			end
			m.health = 0x880
		end,
		hostUpdateFunc = function() -- end early in elimination mode once enough players have been eliminated
			if not gGlobalSyncTable.eliminationMode then
				return
			end
			-- check if any players have been eliminated this game
			local foundEliminated = false
			for_each_connected_player(function(i)
				local sMario = gPlayerSyncTable[i]
				if sMario.eliminated and sMario.roundEliminated ~= 0 then
					foundEliminated = true
					return true
				end
			end)
			if not foundEliminated then
				return
			end

			local toEliminate, hitMinimum = calculate_players_to_eliminate(false, true)
			if hitMinimum then
				return true
			end
		end,
		onPvpFunc = function(attacker, victim, interaction)
			-- dice calculations
			local sVictim = gPlayerSyncTable[victim.playerIndex]
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			if sVictim.team == 0 or sAttacker.team ~= sVictim.team then
				local dieMax = 20
				local chance = dieMax - math.min(sAttacker.roundScore, dieMax - 1)
				local roll = math.random(1, dieMax)
				local name = network_get_player_text_color_string(attacker.playerIndex)
					.. gNetworkPlayers[attacker.playerIndex].name
				local text = string.format("%s\\#ffff50\\ rolled %d (needed %d+). ", name, roll, chance)
				spawn_orange_number_at_pos(roll, victim.pos.x, victim.pos.y + 25, victim.pos.z, true)
				if roll >= chance then
					eliminate_mario(victim)
					text = text .. "RIP..."
					djui_chat_message_create(text)
				else
					text = text .. "You survived!"
					djui_chat_message_create(text)
					sVictim.roundScore = sVictim.roundScore + 1
					--sAttacker.roundScore = sAttacker.roundScore + 2 -- Done in dice roll packet
				end

				network_send_to(attacker.playerIndex, false, {
					id = PACKET_DICE_ROLL,
					roll = roll,
					chance = chance,
				})
			end
		end,
		nametagFunc = function(index, pos, name)
			-- Add chance to kill on the nametag
			name = cap_color_text(name, 25)
			local dieMax = 20
			local chance = math.min(gPlayerSyncTable[index].roundScore + 1, dieMax)
			local percent = math.round(chance / dieMax * 100)
			return name .. "\\#ff5\\ (" .. percent .. "%)"
		end,
		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit)
			local dieMax = 20
			local chance = math.min(gPlayerSyncTable[0].roundScore + 1, dieMax)
			local percent = math.round(chance / dieMax * 100)
			add_line_to_table(sideBarLines, string.format("\\#ff5050\\Chance to kill: (%d%%)", percent), lengthLimit)
		end,
		beforePhysStepFunc = function(m, stepType)
			local alivePlayers = 0
			local maxScore = 0
			for_each_connected_player(function(i)
				local sMario = gPlayerSyncTable[i]
				if not sMario.eliminated then
					alivePlayers = alivePlayers + 1
					if maxScore < sMario.roundScore then
						maxScore = sMario.roundScore
					elseif maxScore == sMario.roundScore then
						maxScore = 9999 -- No speed boost for anyone
						return true
					end
				end
				if alivePlayers >= 3 then
					return true
				end
			end)

			local sMario = gPlayerSyncTable[m.playerIndex]
			if alivePlayers == 2 and sMario.roundScore >= maxScore and not sMario.eliminated then
				m.vel.x = m.vel.x * 1.1
				m.vel.z = m.vel.z * 1.1
				if m.playerIndex == 0 and not prevDiceSpeedBoost then
					prevDiceSpeedBoost = true
					djui_chat_message_create("\\#ffff50\\You now have a slight speed boost!")
				end
			elseif m.playerIndex == 0 then
				prevDiceSpeedBoost = false
			end
		end,
	},
	[GAME_MODE_COIN_RAIN] = {
		name = "Coin Rain",
		desc = "Coins fall from the sky! Collect Yellow Coins for 1 point. Collect Blue Coins for 5 points. Credits to @naoki544 for the idea.",

		level = { LEVEL_TOAD_TOWN, LEVEL_LIGHTS_OUT },
		-- keeping this
		-- LEVEL_TOAD_TOWN, LEVEL_KOOPA_KEEP, LEVEL_DUEL, LEVEL_LIGHTS_OUT
		interact = PLAYER_INTERACTIONS_SOLID,
		music = "thatguy",
		firstRoundTime = 60 * 30, -- 1 minute and 30 seconds
		roundTime = 30 * 30, -- 30 seconds
		maxRounds = 5,
		autoElimination = true,
		doEliminationPoints = true,
		removeDecimal = true,
		fasterActions = true,

		hostUpdateFunc = function()
			coinRainSpawnTimer = coinRainSpawnTimer + 1

			if coinRainSpawnTimer >= coinRainInterval then
				coinRainSpawnTimer = 0

				local x = math.random(-3000, 3000)
				local z = math.random(-3000, 3000)

				local isBlue = math.random(1, 100) <= 25

				spawn_object_no_rotate(
					id_bhvMovingYellowCoin,
					isBlue and E_MODEL_BLUE_COIN or E_MODEL_YELLOW_COIN,
					x,
					2500,
					z,
					function(o)
						o.oVelY = -10
						o.oGravity = -4
						o.oCoinUnk1B0 = 1
						o.oBehParams2ndByte = isBlue and 2 or 1
					end,
					true
				)
			end
		end,

		marioUpdateFunc = function(m)
			m.health = 0x880
		end,

		descFunc = function(index)
			local sMario = gPlayerSyncTable[index]
			return tostring(math.floor(sMario.roundScore / 10) or 0), not sMario.eliminated
		end,
	},
	[GAME_MODE_DEATH_HIT] = {
		name = "Death Hit",
		desc = "Last player standing wins! It's self explanatory. If you get hit, you are ABSOLUTELY cooked. So don't get hit.",
		level = { LEVEL_TOAD_TOWN, LEVEL_KOOPA_KEEP, LEVEL_LIGHTS_OUT },
		interact = PLAYER_INTERACTIONS_PVP,
		kbStrength = 999,
		music = "sliderintense",
		maxTime = 300 * 30,

		hostUpdateFunc = function()
			local alivePlayers = 0

			for_each_connected_player(function(index)
				local sMario = gPlayerSyncTable[index]

				if not sMario.eliminated then
					alivePlayers = alivePlayers + 1
				end
			end)

			if alivePlayers <= 1 then
				return true
			end
		end,
		onPvpFunc = function(attacker, victim, interaction)
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			local sVictim = gPlayerSyncTable[victim.playerIndex]

			victim.hurtCounter = 0
			attacker.hurtCounter = 0
			eliminate_mario(gMarioStates[victim.playerIndex])
			sVictim.eliminated = true
		end,
	},
	[GAME_MODE_BROKEN_LAMP] = {
		name = "Broken Lamp",
		desc = "Only 1 player has the lamp. Hit them to steal it. Without it, the darkness drains your health... It's pretty dark. Credit to @RetroGames",

		level = { LEVEL_TOAD_TOWN, LEVEL_KOOPA_KEEP, LEVEL_LIGHTS_OUT },
		interact = PLAYER_INTERACTIONS_PVP,
		kbStrength = 25,
		music = "dark",
		maxTime = 2 * 60 * 30,
		showHealth = true,
		fasterActions = true,

		hostUpdateFunc = function()
			if gGlobalSyncTable.gameTimer == 1 then
				local alive = {}

				for_each_connected_player(function(i)
					local sMario = gPlayerSyncTable[i]
					sMario.hasLamp = false

					if not sMario.eliminated then
						table.insert(alive, i)
					end
				end)

				if #alive > 0 then
					local chosen = alive[math.random(#alive)]
					gGlobalSyncTable.lampOwner = network_global_index_from_local(chosen)
				end
			end
		end,

		marioUpdateFunc = function(m)
			local gIndex = network_global_index_from_local(m.playerIndex)
			local sMario = gPlayerSyncTable[m.playerIndex]

			local isLampOwner = (gGlobalSyncTable.lampOwner == gIndex)

			if isLampOwner then
				m.health = 0x880
				sonic_set_full_rings(m.playerIndex)
				m.particleFlags = m.particleFlags | PARTICLE_SPARKLES

				sMario.hasLamp = true
				return
			end

			sMario.hasLamp = false

			m.health = m.health - 2

			if m.health <= 0xFF then
				eliminate_mario(m)
			end
		end,

		onPvpFunc = function(attacker, victim, interaction)
			local aIndex = attacker.playerIndex
			local vIndex = victim.playerIndex

			local attackerG = network_global_index_from_local(aIndex)
			local victimG = network_global_index_from_local(vIndex)

			victim.hurtCounter = 0
			attacker.hurtCounter = 0

			if gGlobalSyncTable.lampOwner == victimG then
				gGlobalSyncTable.lampOwner = attackerG
			end
		end,

		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit)
			local lampOwnerIndex = gGlobalSyncTable.lampOwner

			if lampOwnerIndex ~= nil then
				local ownerName = "None"

				for i = 0, MAX_PLAYERS - 1 do
					if network_global_index_from_local(i) == lampOwnerIndex then
						ownerName = gNetworkPlayers[i].name
						break
					end
				end

				add_line_to_table(sideBarLines, ownerName .. " has the lamp", lengthLimit)
			end

			local gIndex = network_global_index_from_local(0)
			local isLampOwner = (gIndex == gGlobalSyncTable.lampOwner)

			if not isLampOwner then
				djui_hud_set_color(0, 0, 0, 100)
				djui_hud_render_rect(0, 0, screenWidth, screenHeight)
			end

			return true
		end,

		descFunc = function(index)
			local gIndex = network_global_index_from_local(index)
			if gGlobalSyncTable.lampOwner == gIndex then
				return "Lamp", true, true
			end
			return "Dark", false
		end,
	},
	[GAME_MODE_MURDER] = {
		name = "Murder Mystery",
		desc = get_translated_desc_murder(),
		level = {
			LEVEL_TOAD_TOWN,
			LEVEL_KOOPA_KEEP,
			LEVEL_LIGHTS_OUT,
			LEVEL_DS_FORT,
		},
		interact = PLAYER_INTERACTIONS_PVP,
		kbStrength = 1,
		music = "dark",
		roundTime = 900,
		maxRounds = 3,
		doEliminationPoints = true,
		marioUpdateFunc = function(m)
			m.health = 2176
			sonic_set_full_rings(m.playerIndex)
			if m.action == ACT_LAVA_BOOST then
				set_to_spawn_pos(m, true)
			end
			if gGlobalSyncTable.roundTimer == 1 and gGlobalSyncTable.round == 1 then
				m.invincTimer = 300
			end
			if gPlayerSyncTable[m.playerIndex].murderIsSheriff == true then
				m.marioBodyState.modelState = m.marioBodyState.modelState | MODEL_STATE_METAL
			end
		end,
		hostUpdateFunc = function()
			if gGlobalSyncTable.murdererDied == true then
				local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
				if gGlobalSyncTable.gameTimer < gData.roundTime * gData.maxRounds - 60 then
					gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 15
				end
			end
			if gGlobalSyncTable.roundTimer ~= 1 then
				return
			end
			if gGlobalSyncTable.round ~= 1 then
				return
			end
			local aliveTable = {}
			for_each_connected_player(function(i)
				local sMario = gPlayerSyncTable[i]
				if not sMario.eliminated then
					sMario.murderIsMurderer = false
					sMario.murderIsSheriff = false
					table.insert(aliveTable, i)
				end
			end)
			local murdererToAssign = 1
			local sheriffToAssign = 1
			for i = #aliveTable, 2, -1 do
				local j = math.random(i)
				aliveTable[i], aliveTable[j] = aliveTable[j], aliveTable[i]
			end
			while murdererToAssign ~= 0 and #aliveTable ~= 0 do
				local index = aliveTable[1]
				gPlayerSyncTable[index].murderIsMurderer = true
				table.remove(aliveTable, 1)
				murdererToAssign = 0
			end
			while sheriffToAssign ~= 0 and murdererToAssign == 0 and #aliveTable ~= 0 do
				local index = aliveTable[1]
				gPlayerSyncTable[index].murderIsSheriff = true
				table.remove(aliveTable, 1)
				sheriffToAssign = 0
			end
			spawn_sync_object(id_bhvSheriffSuit, E_MODEL_HEART, 0, 250, 0, nil)
		end,
		allowPvpFunc = function(attacker, victim, interaction)
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			local sVictim = gPlayerSyncTable[victim.playerIndex]
			if sAttacker.murderIsSheriff == false and sAttacker.murderIsMurderer == false then
				return false
			elseif
				sAttacker.murderIsSheriff == true
				and sVictim.murderIsSheriff == false
				and sVictim.murderIsMurderer == false
			then
				eliminate_mario(attacker)
				gGlobalSyncTable.sheriffDied = true
				gGlobalSyncTable.sheriffDPosX = attacker.pos.x
				gGlobalSyncTable.sheriffDPosY = attacker.pos.y
				gGlobalSyncTable.sheriffDPosZ = attacker.pos.z
				sAttacker.earnedPoints = 0
				return false
			elseif sAttacker.murderIsSheriff == true and sVictim.murderIsMurderer == true then
				gGlobalSyncTable.murdererDied = true
				eliminate_mario(victim)
			elseif
				sAttacker.murderIsMurderer == true
				and sVictim.murderIsMurderer == false
				and sVictim.murderIsSheriff == false
			then
				eliminate_mario(victim)
			elseif sAttacker.murderIsMurderer == true and sVictim.murderIsSheriff == true then
				eliminate_mario(victim)
				gGlobalSyncTable.sheriffDied = true
				gGlobalSyncTable.sheriffDPosX = victim.pos.x
				gGlobalSyncTable.sheriffDPosY = victim.pos.y
				gGlobalSyncTable.sheriffDPosZ = victim.pos.z
			end
		end,
		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit)
			local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
			local roundsLeft = math.max(gData.maxRounds - gGlobalSyncTable.round + 1, 1)
			add_line_to_table(sideBarLines, "" .. translate_roundsleft() .. roundsLeft, lengthLimit)
			local sMario = gPlayerSyncTable[gMarioStates[0].playerIndex]
			add_line_to_table(
				sideBarLines,
				"" .. translate_role() .. murder_role_calc(sMario.murderIsSheriff, sMario.murderIsMurderer),
				lengthLimit
			)
			add_line_to_table(
				sideBarLines,
				"" .. murder_instructions_calc(sMario.murderIsSheriff, sMario.murderIsMurderer),
				lengthLimit
			)
			if gGlobalSyncTable.sheriffDied == true then
				add_line_to_table(sideBarLines, "" .. translate_sheriffdied(), lengthLimit)
			end
			if gGlobalSyncTable.murdererDied == true then
				add_line_to_table(sideBarLines, "" .. translate_murdererdied(), lengthLimit)
			end
			if gPlayerSyncTable[gMarioStates[0].playerIndex].eliminated then
				add_line_to_table(sideBarLines, "\\#7a7aff\\You died. Good game.", lengthLimit)
			end
		end,
		nametagFunc = function(index)
			if index ~= 0 and gMarioStates[0].action ~= ACT_SPECTATE then
				return ""
			end
		end,
		descFunc = function(index)
			if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then
				return
			end
			local sMario = gPlayerSyncTable[index]
			if sMario.eliminated then
				return
			end
			if not sMario.murderIsSheriff then
				return
			end
			return "Sheriff", false, true
		end,
	},
	[GAME_MODE_RUSSIAN_ROULETTE] = {
		name = "Russian Roulette",
		desc = get_translated_desc_russian_roulette(),
		level = LEVEL_LIGHTS_OUT,
		interact = PLAYER_INTERACTIONS_SOLID,
		kbStrength = 30,
		music = "slider",
		roundTime = 150,
		maxRounds = 15,
		doEliminationPoints = true,
		marioUpdateFunc = function(m)
			if m.playerIndex ~= 0 then
				return
			end
			local sMario = gPlayerSyncTable[m.playerIndex]
			m.health = 2176
			sonic_set_full_rings(m.playerIndex)
			if m.controller.buttonPressed == m.controller.buttonPressed | L_TRIG then
				if sMario.rSelectedNumber == 6 then
					sMario.rSelectedNumber = 1
				elseif sMario.rSelectedNumber < 6 then
					sMario.rSelectedNumber = sMario.rSelectedNumber + 1
				end
				play_sound_rbutton_changed()
				spawn_orange_number_at_pos(sMario.rSelectedNumber, m.pos.x, m.pos.y + 100, m.pos.z, true)
			end
			if gGlobalSyncTable.roundTimer == 149 then
				djui_popup_create("" .. translate_deadlynumber() .. gGlobalSyncTable.rDeadlyNum, 1)
				if sMario.rSelectedNumber == gGlobalSyncTable.rDeadlyNum then
					eliminate_mario(m)
				end
			end
		end,
		hostUpdateFunc = function()
			if gGlobalSyncTable.roundTimer == 150 then
				gGlobalSyncTable.rDeadlyNum = math.random(1, 6)
			end
		end,
		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit)
			local sMario = gPlayerSyncTable[gMarioStates[0].playerIndex]
			local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
			local roundsLeft = math.max(gData.maxRounds - gGlobalSyncTable.round + 1, 1)
			add_line_to_table(sideBarLines, "" .. translate_roundsleft() .. roundsLeft, lengthLimit)
			add_line_to_table(
				sideBarLines,
				string.format("\\#7a7aff\\Picked number:\\#dcdcdc\\ %d", sMario.rSelectedNumber),
				lengthLimit
			)
			add_line_to_table(sideBarLines, "Change with L button", lengthLimit)
		end,
	},
	[GAME_MODE_ROPE] = {
		name = "Tug of War",
		desc = get_translated_desc_rope(),
		level = LEVEL_DUEL,
		interact = PLAYER_INTERACTIONS_NONE,
		music = "intense",
		firstRoundTime = 600,
		roundTime = 450,
		maxRounds = 5,
		autoElimination = true,
		doEliminationPoints = true,
		beforeMarioFunc = function(m)
			local centerY = 80
			for var = 1, 60 do
				if gGlobalSyncTable.roundTimer == 1 * var * 10 then
					spawn_sync_object(id_bhvSparkle, E_MODEL_SPARKLES, m.pos.x * 0.9, centerY, m.pos.z * 0.9, nil)
					spawn_sync_object(id_bhvSparkle, E_MODEL_SPARKLES, m.pos.x * 0.25, centerY, m.pos.z * 0.25, nil)
					spawn_sync_object(id_bhvSparkle, E_MODEL_SPARKLES, m.pos.x * 0.5, centerY, m.pos.z * 0.5, nil)
					spawn_sync_object(id_bhvSparkle, E_MODEL_SPARKLES, m.pos.x * 0.75, centerY, m.pos.z * 0.75, nil)
					spawn_non_sync_object(id_bhvSparkle, E_MODEL_SPARKLES, 0, centerY, 0, nil)
				end
			end
			if m.playerIndex ~= 0 then
				return
			end
			m.action = ACT_HOLDING_BOWSER
			m.controller.buttonPressed = m.controller.buttonPressed & ~B_BUTTON
			m.controller.buttonDown = m.controller.buttonDown & ~B_BUTTON
			m.controller.buttonReleased = m.controller.buttonReleased & ~B_BUTTON
			m.controller.stickX = 0
			m.controller.stickY = 0
			m.controller.rawStickX = 0
			m.controller.rawStickY = 0
			m.controller.extStickX = 0
			m.controller.extStickY = 0
			local sMario = gPlayerSyncTable[m.playerIndex]
			if
				m.controller.buttonPressed == m.controller.buttonPressed | A_BUTTON
				or m.controller.buttonPressed == m.controller.buttonPressed | Z_TRIG
			then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_ACTION_CLIMB_UP_TREE, gGlobalSoundSource)
			end
		end,
		onPhysicalStepFunc = function(m)
			m.vel.x = 0
			m.vel.z = 0
		end,
	},
	[GAME_MODE_FIERY] = {
		name = "Fiery Meteor Falls",
		desc = get_translated_desc_fiery(),
		level = LEVEL_BOWSER_2,
		interact = PLAYER_INTERACTIONS_SOLID,
		kbStrength = 8,
		music = "slider",
		roundTime = 900,
		maxRounds = 3,
		doEliminationPoints = true,
		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit)
			local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
			local roundsLeft = math.max(gData.maxRounds - gGlobalSyncTable.round + 1, 1)
			add_line_to_table(sideBarLines, "" .. translate_roundsleft() .. roundsLeft, lengthLimit)
		end,
		marioUpdateFunc = function(m)
			if m.playerIndex ~= 0 then
				return
			end
			if m.action == ACT_LAVA_BOOST then
				set_to_spawn_pos(m, true)
				m.health = m.health - 512
			end
			for var = 1, 30 do
				local x, y, z = m.pos.x + math.random(-500, 500), 3000, m.pos.z + math.random(-500, 500)
				local x2, z2 = m.pos.x + math.random(-500, 500), m.pos.z + math.random(-500, 500)
				local x3, z3 = math.random(-500, 500), math.random(-500, 500)
				local x4, z4 = math.random(-500, 500), math.random(-500, 500)
				if gGlobalSyncTable.roundTimer == 1 * var * 30 + 15 then
					spawn_non_sync_object(id_bhvBouncingFireball, E_MODEL_NONE, x, y, z, function(o)
						o.oMoveAngleYaw = math.random(0, 65535)
					end)
					spawn_non_sync_object(id_bhvBouncingFireball, E_MODEL_NONE, x2, y, z2, function(o)
						o.oMoveAngleYaw = math.random(0, 65535)
					end)
					spawn_non_sync_object(id_bhvFlameFloatingLanding, E_MODEL_RED_FLAME, x, y, z, nil)
					spawn_non_sync_object(id_bhvFlameFloatingLanding, E_MODEL_RED_FLAME, x2, y, z2, nil)
				elseif gGlobalSyncTable.roundTimer == 10 * var * 30 - 1 then
					spawn_non_sync_object(id_bhvFlame, E_MODEL_BLUE_FLAME, x3, 1350, z3, nil)
					spawn_non_sync_object(id_bhvFlame, E_MODEL_BLUE_FLAME, x4, 1350, z4, nil)
				end
			end
		end,
	},
	[GAME_MODE_RUN] = {
		name = "Coin Run",
		desc = "placeholder",
		level = LEVEL_STAIR,
		music = "thatguy",
		firstRoundTime = 2100,
		roundTime = 750,
		maxRounds = 5,
		kbStrength = 40,
		doEliminationPoints = true,
		autoElimination = true,
		interact = PLAYER_INTERACTIONS_SOLID,
		marioUpdateFunc = function(m)
			if m.playerIndex ~= 0 then
				return
			end
			m.health = 2176
			if m.pos.y < -3000 or 0 < m.hurtCounter then
				set_to_spawn_pos(m, true)
				play_sound_button_change_blocked()
				m.squishTimer = 0
				m.invincTimer = 90
				m.hurtCounter = 0
			end
			if gGlobalSyncTable.roundTimer ~= 1 then
				return
			end
			if gGlobalSyncTable.round ~= 1 then
				return
			end
			m.invincTimer = 150
		end,
		hostUpdateFunc = function()
			for var = 1, 70 do
				if gGlobalSyncTable.roundTimer == 5 * var * 30 - 1 then
					spawn_sync_object(id_bhvTenCoinsSpawn, E_MODEL_NONE, 0, 2000, -7100, nil)
				end
			end
			if gGlobalSyncTable.roundTimer ~= 1 then
				return
			end
			if gGlobalSyncTable.round ~= 1 then
				return
			end
			local x, y = 0, -8000
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, 14884, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, 11738, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, 8594, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, 5436, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, 2292, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, -1068, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, -3900, nil)
			spawn_sync_object(id_bhvTiltingBowserLavaPlatform, E_MODEL_NONE, x, y, -7189, nil)
		end,
		onInteractFunc = function(m, o, t, v)
			local sMario = gPlayerSyncTable[m.playerIndex]
			if o.oInteractType == INTERACT_COIN then
				sMario.roundScore = sMario.roundScore + 1
				spawn_sync_object(
					id_bhvFallingBomb,
					E_MODEL_BLACK_BOBOMB,
					math.random(-1242, 1122),
					1200,
					math.random(-4270, 11040),
					nil
				)
			end
		end,
	},
	[GAME_MODE_VIRUS] = {
		name = "The Virus",
		desc = "placeholder",
		level = {
			LEVEL_TOAD_TOWN,
			LEVEL_KOOPA_KEEP,
			LEVEL_LIGHTS_OUT,
			LEVEL_DS_FORT,
		},
		music = "slider",
		interact = PLAYER_INTERACTIONS_PVP,
		firstRoundTime = 1500,
		roundTime = 900,
		maxRounds = 3,
		kbStrength = 20,
		fasterActions = true,
		doEliminationPoints = true,
		hostUpdateFunc = function()
			if gGlobalSyncTable.roundTimer ~= 1 then
				return
			end
			local aliveTable = {}
			for_each_connected_player(function(i)
				local sMario = gPlayerSyncTable[i]
				if not sMario.eliminated then
					sMario.virus = false
					table.insert(aliveTable, i)
				end
			end)
			local virusToAssign = 1
			for i = #aliveTable, 2, -1 do
				local j = math.random(i)
				aliveTable[i], aliveTable[j] = aliveTable[j], aliveTable[i]
			end
			while virusToAssign ~= 0 and #aliveTable ~= 0 do
				local index = aliveTable[1]
				gPlayerSyncTable[index].virus = true
				table.remove(aliveTable, 1)
				virusToAssign = 0
			end
		end,
		marioUpdateFunc = function(m)
			if gPlayerSyncTable[m.playerIndex].virus == true then
				m.health = m.health - 2
				m.marioBodyState.modelState = m.marioBodyState.modelState | MODEL_STATE_METAL
			end
			if gGlobalSyncTable.roundTimer == 1 and gGlobalSyncTable.round == 1 then
				m.invincTimer = 150
			end
			if m.playerIndex ~= 0 then
				return
			end
			if m.action == ACT_LAVA_BOOST then
				set_to_spawn_pos(m, true)
				m.hurtCounter = 4
				m.invincTimer = 90
			end
		end,
		onPvpFunc = function(attacker, victim, interaction)
			local sAttacker = gPlayerSyncTable[attacker.playerIndex]
			local sVictim = gPlayerSyncTable[victim.playerIndex]
			if sAttacker.virus == true then
				sVictim.virus = true
				sAttacker.virus = false
				victim.invincTimer = 120
			end
		end,
		hudRenderFunc = function(screenWidth, screenHeight, sideBarLines, lengthLimit)
			local gData = GAME_MODE_DATA[gGlobalSyncTable.gameMode or 0]
			local roundsLeft = math.max(gData.maxRounds - gGlobalSyncTable.round + 1, 1)
			add_line_to_table(sideBarLines, "" .. translate_roundsleft() .. roundsLeft, lengthLimit)
			if gPlayerSyncTable[gMarioStates[0].playerIndex].virus == true then
				add_line_to_table(sideBarLines, "" .. translate_you_are_infected(), lengthLimit)
			end
		end,
		descFunc = function(index)
			if gGlobalSyncTable.gameState ~= GAME_STATE_ACTIVE then
				return
			end
			local sMario = gPlayerSyncTable[index]
			if sMario.eliminated then
				return
			end
			if not sMario.virus then
				return
			end
			return "Infected", false, true
		end,
	},
	[GAME_MODE_SIMON] = {
		name = "Simon Says",
		desc = "Race against your friends to nail every command dropped in chat before time expires. Keep your focus sharp, follow the rules, and grab the most points to get the most points.",
		level = LEVEL_KOOPA_KEEP,
		music = "slider",
		interact = PLAYER_INTERACTIONS_NONE,
		firstRoundTime = 1350,
		roundTime = 900,
		maxRounds = 5,
		doEliminationPoints = true,
		autoElimination = true,
		fasterActions = true,
		marioUpdateFunc = function(m)
			if m.playerIndex ~= 0 then
				return
			end
			m.health = 2176
			m.hurtCounter = 0
			sonic_set_full_rings(m.playerIndex)
			local sMario = gPlayerSyncTable[m.playerIndex]
			local GSC = gGlobalSyncTable
			if GSC.simonSays == 1 and m.pos.y > m.floorHeight then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 2 and m.action == m.action | ACT_FLAG_ATTACKING then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 3 and m.action == ACT_IDLE then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 4 and m.action == ACT_WALKING then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 5 and m.action == ACT_LAVA_BOOST then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 6 and m.action == ACT_LEDGE_GRAB then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 7 and m.forwardVel > 35 then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			elseif GSC.simonSays == 8 and m.action == ACT_BACKFLIP then
				sMario.roundScore = sMario.roundScore + 1
				play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
			end
			for var = 1, 35 do
				if GSC.roundTimer == 6 * var * 30 then
					play_sound(SOUND_ACTION_CLIMB_UP_TREE, gGlobalSoundSource)
					djui_chat_message_create("" .. translate_simon_says() .. translate_simon_do())
				end
			end
			if GSC.round == 1 and GSC.roundTimer == 1 then
				djui_popup_create("" .. translate_simon_connected(), 1)
				djui_chat_message_create("" .. translate_simon_says() .. translate_simon_do())
			end
		end,
		hostUpdateFunc = function()
			for var = 1, 35 do
				if gGlobalSyncTable.roundTimer == 6 * var * 30 - 5 then
					gGlobalSyncTable.simonSays = math.random(1, 8)
				end
			end
		end,
	},
}

LEVEL_SYNC_SETUP = {
	[LEVEL_GLASS] = function()
		local toEliminate = calculate_players_to_eliminate(not gGlobalSyncTable.eliminationMode, true)

		-- assign each pane its break status
		local glass = obj_get_first_with_behavior_id_and_field_s32(id_bhvGlass, 0x2F, 0)
		-- the amount of panes can't exceed half we intend to eliminate plus 2, to ensure elimination games don't end really easily
		local totalPanes = math.max(math.ceil(toEliminate / 2) + 2, 3)
		local row = 0
		while glass do
			if row >= totalPanes then
				glass.oBobombFuseTimer = 2
				local otherGlass = obj_get_next_with_same_behavior_id_and_field_s32(glass, 0x2F, row)
				if otherGlass then
					otherGlass.oBobombFuseTimer = 2
				end
				network_send_object(glass, true)
				if otherGlass then
					network_send_object(otherGlass, true)
				end
			else
				local otherGlass = obj_get_next_with_same_behavior_id_and_field_s32(glass, 0x2F, row)
				local glassBreak = math.random(0, 1)
				if glassBreak == 0 then
					glass.oBobombFuseTimer = 0
					if otherGlass then
						otherGlass.oBobombFuseTimer = 1
					end
				else
					glass.oBobombFuseTimer = 1
					if otherGlass then
						otherGlass.oBobombFuseTimer = 0
					end
				end
				if DEBUG_MODE then
					log_to_console(tostring(row) .. ": " .. tostring(glassBreak))
				end
				network_send_object(glass, true)
				if otherGlass then
					network_send_object(otherGlass, true)
				end
			end

			row = row + 1
			glass = obj_get_first_with_behavior_id_and_field_s32(id_bhvGlass, 0x2F, row)
		end
	end,
}

LEVEL_SPAWN_DATA = {
	[LEVEL_LOBBY] = {
		spawnPos = {
			x = 0,
			y = 1000,
			z = 0,
		},
		spawnAngle = 32768,
		spawnLine = true,
	},
	[LEVEL_GLASS] = {
		spawnPos = {
			x = 0,
			y = 1000,
			z = -8000,
		},
	},
	[LEVEL_LIGHTS_OUT] = {
		spawnPos = {
			x = 0,
			y = 1000,
			z = 0,
		},
		spawnDist = 1000,
		spawnAngle = 32768,
	},
	[LEVEL_RGLIGHT] = {
		spawnPos = {
			x = 0,
			y = 1000,
			z = 0,
		},
		spawnAngle = 32768,
		spawnLine = true,
	},
	[LEVEL_KOTH] = {
		spawnPos = {
			x = -2400,
			y = 1000,
			z = 1486,
		},
		spawnAngle = 17698,
	},
	[LEVEL_MINGLE] = {
		spawnPos = {
			x = 0,
			y = 500,
			z = 0,
		},
		spawnDist = 750,
	},
	[LEVEL_DUEL] = {
		spawnPos = {
			x = 0,
			y = 500,
			z = 0,
		},
		spawnDist = 2000,
	},
	[LEVEL_TOAD_TOWN] = {
		spawnPos = {
			x = 0,
			y = 500,
			z = 0,
		},
		spawnDist = 1100,
	},
	[LEVEL_KOOPA_KEEP] = {
		spawnPos = {
			x = 1210,
			y = -737,
			z = -2088,
		},
		spawnDist = 400,
	},
	[LEVEL_DS_FORT] = {
		spawnPos = {
			x = 2345,
			y = 0,
			z = 1100,
		},
		spawnDist = 400,
	},
	[LEVEL_STAIR] = {
		spawnPos = {
			x = 0,
			y = -2000,
			z = 13400,
		},
		spawnDist = 400,
	},
	[LEVEL_BOWSER_1] = {
		spawnPos = {
			x = 0,
			y = 2000,
			z = 0,
		},
		spawnDist = 2500,
	},
	[LEVEL_BOWSER_2] = {
		spawnPos = {
			x = 0,
			y = 2000,
			z = 0,
		},
		spawnDist = 2500,
	},
	[LEVEL_BOWSER_3] = {
		spawnPos = {
			x = 0,
			y = 2000,
			z = 0,
		},
		spawnDist = 2500,
	},
	[LEVEL_SA] = {
		spawnPos = {
			x = 0,
			y = -4000,
			z = 0,
		},
		spawnDist = 2000,
	},
}

-- hud for between duel state, ported from the original Duels mod (with modifications to support more players)
function duel_hud()
	local screenWidth, screenHeight = djui_hud_get_screen_width(), djui_hud_get_screen_height()
	width = screenWidth * 0.4
	height = screenHeight * 0.2
	local dist = duelSideTimer * duelSideTimer * (width / 900)
	local scale = 0.5
	local toWin = 2

	local comps = {}
	local teamCounted = {}
	for_each_connected_player(function(index)
		local sMario = gPlayerSyncTable[index]
		if sMario.validForDuel then
			if sMario.team == nil or sMario.team == 0 or sMario.team > #TEAM_DATA then
				local playerColor = network_get_player_text_color_string(index)
				local name = playerColor .. gNetworkPlayers[index].name
				local r, g, b = convert_color(playerColor)
				table.insert(comps, { name, (sMario.roundScore or 0), { r = r, g = g, b = b } })
			elseif not teamCounted[sMario.team] then
				teamCounted[sMario.team] = #comps + 1 -- index for our team data
				local name = TEAM_DATA[sMario.team][3]
				local color = TEAM_DATA[sMario.team][1]
				table.insert(comps, { name, (sMario.roundScore or 0), color })
			elseif sMario.roundScore > comps[teamCounted[sMario.team]][2] then
				comps[teamCounted[sMario.team]][2] = sMario.roundScore
			end
		end
	end)
	if do_solo_debug() then
		for i = 1, MAX_PLAYERS - 1 do
			table.insert(comps, { tostring(i), math.random(0, toWin - 1), { r = 255, g = 255, b = 255 } })
		end
	end

	while ((#comps + 1) // 2) * (height + 20 * scale) >= screenHeight do
		scale = scale / 2
		height = height / 2
	end
	for i, compData in ipairs(comps) do
		local name = compData[1]
		local score = compData[2]
		local r, g, b = compData[3].r, compData[3].g, compData[3].b
		r = math.max(r - 50, 0)
		g = math.max(g - 50, 0)
		b = math.max(b - 50, 0)

		local x = -dist
		if i % 2 == 0 then
			x = screenWidth - width + dist
		end
		local y = (screenHeight - height) / 2
		local panelsOnThisSide = (#comps + (i % 2)) // 2
		if panelsOnThisSide > 1 then
			local panelNum = ((i + 1) // 2)
			y = y + (height + 20 * scale) * (-0.5 * (panelsOnThisSide + 1) + panelNum)
		end
		djui_hud_set_color(r, g, b, 180)
		djui_hud_render_rect(x, y, width, height)
		if i % 2 == 1 then
			x = x + 10
		else
			x = x + width - (djui_hud_measure_text(remove_color(name)) * scale) - 10
		end
		djui_hud_print_text_with_color_and_outline(name, x, y + 2, scale, 255, 2)
		y = y + 35 * scale
		if i % 2 == 0 then
			x = screenWidth - 36 * scale + dist - 10
		end
		for a = 1, toWin do
			if score >= a then
				djui_hud_set_color(255, 255, 255, 255)
			else
				djui_hud_set_color(0, 0, 0, 180)
			end
			djui_hud_render_texture(gTextures.star, x, y, scale * 2, scale * 2)

			if i % 2 == 1 then
				x = x + 35 * scale
			else
				x = x - 35 * scale
			end
		end
		y = y - 35 * scale
	end

	if duelSideTimer > 0 then
		duelSideTimer = duelSideTimer - 1
	end
end
