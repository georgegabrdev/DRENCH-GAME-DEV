local HU = {}

HU.TEXTURE_ROUND_CORNER = get_texture_info("round_corner")
HU.WING_HUD = get_texture_info("hud_wing")

local FEATURE = -1
local NONE = -2

---@param x number
---@param y number
---@param width number
---@param height number
---@param cornerRadius number
function HU.djui_hud_render_rect_rounded(x, y, width, height, cornerRadius)
	if cornerRadius > width then
		cornerRadius = width
	end

	if cornerRadius > height then
		cornerRadius = height
	end

	-- center/body
	djui_hud_render_rect(x + (cornerRadius / 2), y, width - cornerRadius, height)

	-- left side
	djui_hud_render_rect(x, y + (cornerRadius / 2), cornerRadius / 2, height - cornerRadius)

	-- right side
	djui_hud_render_rect(x + width - cornerRadius / 2, y + (cornerRadius / 2), cornerRadius / 2, height - cornerRadius)

	-- corner texture scale
	local circleDimensions = (1 / 64) * cornerRadius / 2

	-- top left
	djui_hud_render_texture(HU.TEXTURE_ROUND_CORNER, x, y, circleDimensions, circleDimensions)

	-- bottom left
	djui_hud_set_rotation(0x4000, 0, 0)
	djui_hud_render_texture(HU.TEXTURE_ROUND_CORNER, x, y + height, circleDimensions, circleDimensions)

	-- top right
	djui_hud_set_rotation(-0x4000, 0, 0)
	djui_hud_render_texture(HU.TEXTURE_ROUND_CORNER, x + width, y, circleDimensions, circleDimensions)

	-- bottom right
	djui_hud_set_rotation(0x8000, 0, 0)
	djui_hud_render_texture(HU.TEXTURE_ROUND_CORNER, x + width, y + height, circleDimensions, circleDimensions)

	djui_hud_set_rotation(0, 0, 0)
end

function HU.djui_hud_render_rect_rounded_interpolated(
	prevX,
	prevY,
	prevW,
	prevH,
	currX,
	currY,
	currW,
	currH,
	cornerRadius
)
	if cornerRadius > currW then
		cornerRadius = currW
	end
	if cornerRadius > currH then
		cornerRadius = currH
	end

	djui_hud_render_rect_interpolated(
		prevX + (cornerRadius / 2),
		prevY,
		prevW - cornerRadius,
		prevH,
		currX + (cornerRadius / 2),
		currY,
		currW - cornerRadius,
		currH
	)
	djui_hud_render_rect_interpolated(
		prevX,
		prevY + (cornerRadius / 2),
		cornerRadius / 2,
		prevH - cornerRadius,
		currX,
		currY + (cornerRadius / 2),
		cornerRadius / 2,
		currH - cornerRadius
	)

	djui_hud_render_rect_interpolated(
		prevX + prevW - cornerRadius / 2,
		prevY + (cornerRadius / 2),
		cornerRadius / 2,
		prevH - cornerRadius,
		currX + currW - cornerRadius / 2,
		currY + (cornerRadius / 2),
		cornerRadius / 2,
		currH - cornerRadius
	)

	local circleDim = (1 / 64) * cornerRadius / 2

	djui_hud_render_texture_interpolated(
		HU.TEXTURE_ROUND_CORNER,
		prevX,
		prevY,
		circleDim,
		circleDim,
		currX,
		currY,
		circleDim,
		circleDim
	)

	djui_hud_set_rotation(0x4000, 0, 0)
	djui_hud_render_texture_interpolated(
		HU.TEXTURE_ROUND_CORNER,
		prevX,
		prevY + prevH,
		circleDim,
		circleDim,
		currX,
		currY + currH,
		circleDim,
		circleDim
	)

	djui_hud_set_rotation(-0x4000, 0, 0)
	djui_hud_render_texture_interpolated(
		HU.TEXTURE_ROUND_CORNER,
		prevX + prevW,
		prevY,
		circleDim,
		circleDim,
		currX + currW,
		currY,
		circleDim,
		circleDim
	)

	djui_hud_set_rotation(0x8000, 0, 0)
	djui_hud_render_texture_interpolated(
		HU.TEXTURE_ROUND_CORNER,
		prevX + prevW,
		prevY + prevH,
		circleDim,
		circleDim,
		currX + currW,
		currY + currH,
		circleDim,
		circleDim
	)

	djui_hud_set_rotation(0, 0, 0)
end

---------------------
--- RECT OUTLINED ---
---------------------

---@param x number|integer
---@param y number|integer
---@param width number|integer
---@param height number|integer
---@param oR number|integer
---@param oG number|integer
---@param oB number|integer
---@param thickness number|integer
---@param opacity number|integer|nil
function HU.djui_hud_render_rect_outlined(x, y, width, height, oR, oG, oB, thickness, opacity)
	if opacity == nil then
		opacity = 255
	end
	-- render main rect
	djui_hud_render_rect(x, y, width, height)
	-- set outline color to, well, outline color
	djui_hud_set_color(oR, oG, oB, opacity)
	-- render rect outside of each side
	djui_hud_render_rect(x - thickness, y - thickness, thickness, height + thickness * 2)
	djui_hud_render_rect(x + (width - thickness) + thickness, y, thickness, height + thickness)
	djui_hud_render_rect(x, y - thickness, width + thickness, thickness)
	djui_hud_render_rect(x, y + (height - thickness) + thickness, width, thickness)
end

-----------------------------
--- RECT ROUNDED OUTLINED ---
-----------------------------

---@param x number|integer
---@param y number|integer
---@param width number|integer
---@param height number|integer
---@param oR number|integer
---@param oG number|integer
---@param oB number|integer
---@param thickness number|integer
---@param opacity number|integer|nil
function HU.djui_hud_render_rect_rounded_outlined(x, y, width, height, oR, oG, oB, thickness, opacity)
	if opacity == nil then
		opacity = 255
	end
	local cornerRadius = thickness
	-- render rounded rect using those saved colors
	djui_hud_render_rect(x, y, width, height)
	-- render rect outside of each side
	djui_hud_set_color(oR, oG, oB, opacity)
	djui_hud_render_rect(x - thickness, y, thickness, height)
	djui_hud_render_rect(x + (width - thickness) + thickness, y, thickness, height)
	djui_hud_render_rect(x, y - thickness, width, thickness)
	djui_hud_render_rect(x, y + (height - thickness) + thickness, width, thickness)
	-- render outline corners
	local circleDimensions = (1 / 64) * cornerRadius
	-- top left corner
	djui_hud_render_texture(HU.TEXTURE_ROUND_CORNER, x - thickness, y - thickness, circleDimensions, circleDimensions)
	-- bottom left corner
	djui_hud_set_rotation(0x4000, 0, 0)
	djui_hud_render_texture(
		HU.TEXTURE_ROUND_CORNER,
		x - thickness,
		y + height + thickness,
		circleDimensions,
		circleDimensions
	)
	-- top right corner
	djui_hud_set_rotation(-0x4000, 0, 0)
	djui_hud_render_texture(
		HU.TEXTURE_ROUND_CORNER,
		x + width + thickness,
		y - thickness,
		circleDimensions,
		circleDimensions
	)
	-- bottom right corner
	djui_hud_set_rotation(0x8000, 0, 0)
	djui_hud_render_texture(
		HU.TEXTURE_ROUND_CORNER,
		x + width + thickness,
		y + height + thickness,
		circleDimensions,
		circleDimensions
	)
	djui_hud_set_rotation(0, 0, 0)
end

local defaultColorData = {
	[CT_MARIO] = {
		tex = get_texture_info("mario_head_recolor"),
		order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
		order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
		metal_sheet_x = 5,
		metal_capless_sheet_x = 7,
	},
	[CT_LUIGI] = {
		tex = get_texture_info("luigi_head_recolor"),
		order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
		order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
		metal_sheet_x = 5,
		metal_capless_sheet_x = 7,
	},
	[CT_TOAD] = {
		tex = get_texture_info("toad_head_recolor"),
		order = { SKIN, GLOVES, CAP, FEATURE, NONE, NONE },
		order_capless = { SKIN, NONE, NONE, FEATURE, NONE, HAIR },
		metal_sheet_x = 5,
		metal_capless_sheet_x = 7,
	},
	[CT_WARIO] = {
		tex = get_texture_info("wario_head_recolor"),
		order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
		order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
		metal_sheet_x = 5,
		metal_capless_sheet_x = 7,
	},
	[CT_WALUIGI] = {
		tex = get_texture_info("waluigi_head_recolor"),
		order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
		order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
		metal_sheet_x = 5,
		metal_capless_sheet_x = 7,
	},
}

function HU.render_player_head(index, x, y, scale)
	local m = gMarioStates[index]
	local np = gNetworkPlayers[index]

	local data = defaultColorData[m.character.type]

	if not data then
		djui_hud_set_color(255, 255, 255, 255)
		djui_hud_render_texture(m.character.hudHeadTexture, x, y, scale, scale)
		return
	end

	local tex = data.tex
	local order = data.order

	for i = 0, #order - 1 do
		local part = order[i + 1]

		if part ~= NONE then
			local color = { r = 255, g = 255, b = 255 }

			if part ~= FEATURE then
				color = network_player_get_override_palette_color(np, part)
			end

			djui_hud_set_color(color.r, color.g, color.b, 255)

			djui_hud_render_texture_tile(tex, x, y, scale, scale, i * 16, 0, 16, 16)
		end
	end
end

--- @param index integer
--- @param prevX number
--- @param prevY number
--- @param x number
--- @param y number
--- @param scaleX number
--- @param scaleY number
function HU.render_player_head_interpolated(index, prevX, prevY, x, y, scaleX, scaleY, noSpecial, alwaysCap, alpha_)
	local m = gMarioStates[index]
	local np = gNetworkPlayers[index]

	local alpha = alpha_ or 255

	-- vanish effect (engine-based only)
	if
		not noSpecial
		and (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0
		and (index == 0 or np.fadeOpacity >= 32)
	then
		alpha = math.max(alpha - 155, 0)
	end

	local thisIconColorData = defaultColorData[m.character.type]
	local noColorHead = false

	-- fallback: render raw head texture
	if not thisIconColorData then
		noColorHead = true
		djui_hud_set_color(255, 255, 255, alpha)
		djui_hud_render_texture_interpolated(
			m.character.hudHeadTexture,
			prevX,
			prevY,
			scaleX,
			scaleY,
			x,
			y,
			scaleX,
			scaleY
		)
	end

	local isMetal = false
	local capless = false

	if not noColorHead then
		local tex = thisIconColorData.tex
		local headWidth = thisIconColorData.headWidth or 16
		local headHeight = thisIconColorData.headHeight or 16

		local totalX = tex.width // headWidth - 1
		local order = thisIconColorData.order or { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE }

		if
			not (noSpecial or alwaysCap)
			and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF
			and thisIconColorData.order_capless
		then
			capless = true
			order = thisIconColorData.order_capless
		end

		-- METAL CAP RENDER
		if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then
			local color = network_player_get_override_palette_color(np, METAL)
			djui_hud_set_color(color.r, color.g, color.b, alpha)
			isMetal = true

			local sheetX = thisIconColorData.metal_sheet_x or #order
			if capless then
				sheetX = thisIconColorData.metal_capless_sheet_x or (#order + 1)
			end

			djui_hud_render_texture_tile_interpolated(
				tex,
				prevX,
				prevY,
				scaleX,
				scaleY,
				x,
				y,
				scaleX,
				scaleY,
				sheetX * headWidth,
				0,
				headWidth,
				headHeight
			)
		else
			-- NORMAL COLORED HEAD RENDER
			local orderX = 0
			local sheetX = 0

			while sheetX < totalX do
				local metalSheetX = thisIconColorData.metal_sheet_x or #order
				local metalCaplessSheetX = thisIconColorData.metal_capless_sheet_x or (#order + 1)

				if sheetX ~= metalSheetX and sheetX ~= metalCaplessSheetX then
					orderX = orderX + 1
					local part = order[orderX]

					if part == nil then
						break
					end

					if part ~= NONE then
						local color = { r = 255, g = 255, b = 255 }

						if part ~= FEATURE then
							color = network_player_get_override_palette_color(np, part)
						end

						djui_hud_set_color(color.r, color.g, color.b, alpha)
						djui_hud_render_texture_tile_interpolated(
							tex,
							prevX,
							prevY,
							scaleX,
							scaleY,
							x,
							y,
							scaleX,
							scaleY,
							sheetX * headWidth,
							0,
							headWidth,
							headHeight
						)
					end
				end

				sheetX = sheetX + 1
			end
		end
	end

	-- WING CAP (engine-only)
	if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
		djui_hud_set_color(255, 255, 255, alpha)

		if (not noColorHead) and isMetal then
			djui_hud_set_color(109, 170, 173, alpha)
		end

		djui_hud_render_texture_interpolated(HU.WING_HUD, prevX, prevY, scaleX, scaleY, x, y, scaleX, scaleY)
	end
end

function HU.render_wave_text_interpolated(
	text,
	xPrev,
	yPrev,
	xCurr,
	yCurr,
	scale,
	timer,
	timeEnter,
	timeStay,
	waveSpeed,
	colorBase,
	colorWave
)
	local charOffset = 0
	local startOfExitPhase = timeEnter + timeStay
	local isInWavePhase = (timer > timeEnter and timer < startOfExitPhase)
	local wavePos = isInWavePhase and ((timer - timeEnter) * waveSpeed) or -100

	local charIndex = 0
	for _, codepoint in utf8.codes(text) do
		charIndex = charIndex + 1
		local char = utf8.char(codepoint)
		local baseW = djui_hud_measure_text(char) * scale

		local charScale = scale
		local yBounce = 0
		local r, g, b = colorBase.r, colorBase.g, colorBase.b

		if isInWavePhase then
			local dist = math.abs(wavePos - charIndex)
			if dist < 2.5 then
				local power = 1.0 - (dist / 2.5)
				charScale = scale + (0.07 * power)
				yBounce = 2.0 * power
				r, g, b = colorWave.r, colorWave.g, colorWave.b
			end
		end

		djui_hud_set_color(r, g, b, 255)
		djui_hud_print_text_interpolated(
			char,
			xPrev + charOffset,
			yPrev - yBounce,
			charScale,
			xCurr + charOffset,
			yCurr - yBounce,
			charScale
		)

		charOffset = charOffset + baseW
	end
end

function HU.calc_anim_value(t, animObj)
	local totalTime = animObj.timeEnter + animObj.timeStay + animObj.timeExit

	if t <= 0 then
		return animObj.startVal
	end

	if t <= animObj.timeEnter then
		local p = t / animObj.timeEnter
		local slide = math.sin(p * (math.pi / 2))
		return animObj.startVal + (animObj.targetVal - animObj.startVal) * slide
	elseif t <= (animObj.timeEnter + animObj.timeStay) then
		return animObj.targetVal
	elseif t <= totalTime then
		local timeInExit = t - (animObj.timeEnter + animObj.timeStay)
		local p = timeInExit / animObj.timeExit
		local slide = math.sin(p * (math.pi / 2))
		return animObj.targetVal + (animObj.startVal - animObj.targetVal) * slide
	else
		return animObj.startVal
	end
end

local function utf8_chars(str)
	local i = 1
	return function()
		if i > #str then
			return nil
		end
		local c = str:sub(i, i)
		i = i + 1
		return i, c
	end
end

local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")

	return tonumber(hex:sub(1, 2), 16) or 255, tonumber(hex:sub(3, 4), 16) or 255, tonumber(hex:sub(5, 6), 16) or 255
end

---@param text string
---@param x integer
---@param y integer
---@param scale integer
---@param opacity integer|nil
function HU.djui_hud_print_colored_text(text, x, y, scale, opacity)
	-- failsafe
	text = tostring(text)
	local inSlash = false
	local hex = ""
	opacity = opacity or 255

	-- get old color for restoration later
	local c = djui_hud_get_color()

	-- loop thru each character in the string and render that char
	for i = 1, #text do
		-- get character
		local char = text:sub(i, i)

		-- if character is a backslash, then switch inslash
		if char == "\\" then
			-- we are now in (or out) of the slash, set variable accordingly
			inSlash = not inSlash
			-- reset hex if needed
			if inSlash then
				hex = ""
			end
		elseif inSlash then
			-- set hex var
			hex = hex .. char
		elseif not inSlash then
			if hex:len() == 7 then
				-- get rgb
				local r, g, b = hex_to_rgb(hex)
				-- set color to rgb
				djui_hud_set_color(r, g, b, opacity)
			end
			-- print character
			djui_hud_print_text(char, x, y, scale)
			-- increase position
			x = x + (djui_hud_measure_text(char) * scale)
		end
	end
	djui_hud_set_color(c.r, c.g, c.b, c.a)
end

---------------------------------------
--- PRINT COLORED TEXT INTERPOLATED ---
---------------------------------------

function HU.print_colored_text_interpolated(text, prevX, prevY, currX, currY, scale, opacity)
	text = tostring(text)
	local inSlash = false
	local hex = ""
	opacity = opacity or 255
	local c = djui_hud_get_color()

	local pX, cX = prevX, currX

	for _, char in utf8_chars(text) do
		if char == "\\" then
			inSlash = not inSlash
			if inSlash then
				hex = ""
			end
		elseif inSlash then
			hex = hex .. char
		else
			if hex:len() == 7 then
				local r, g, b = hex_to_rgb(hex)
				djui_hud_set_color(r, g, b, opacity)
			end
			djui_hud_print_text_interpolated(char, pX, prevY, scale, cX, currY, scale)
			local w = djui_hud_measure_text(char) * scale
			pX = pX + w
			cX = cX + w
		end
	end
	djui_hud_set_color(c.r, c.g, c.b, c.a)
end

function HU.normalize_text(str)
	str = tostring(str or "")
	str = HU.three_value_hex(str)
	return str
end

function HU.get_truncated_name(rawName, maxChars, addEllipsis)
	rawName = tostring(rawName or "")
	local visibleCount = 0
	local inHex = false
	local coloredResult = ""
	local plainResult = ""
	local wasTruncated = false

	local status, len = pcall(utf8.len, rawName)
	if not status or not len then
		for i = 1, #rawName do
			local char = rawName:sub(i, i)
			if char == "\\" then
				inHex = not inHex
				coloredResult = coloredResult .. char
			elseif inHex then
				coloredResult = coloredResult .. char
			else
				if visibleCount >= maxChars then
					wasTruncated = true
					break
				end
				visibleCount = visibleCount + 1
				coloredResult = coloredResult .. char
				plainResult = plainResult .. char
			end
		end
	else
		for _, codepoint in utf8.codes(rawName) do
			local char = utf8.char(codepoint)
			if char == "\\" then
				inHex = not inHex
				coloredResult = coloredResult .. char
			elseif inHex then
				coloredResult = coloredResult .. char
			else
				if visibleCount >= maxChars then
					wasTruncated = true
					break
				end
				visibleCount = visibleCount + 1
				coloredResult = coloredResult .. char
				plainResult = plainResult .. char
			end
		end
	end

	if wasTruncated and addEllipsis then
		coloredResult = coloredResult .. "..."
		plainResult = plainResult .. "..."
	end

	return coloredResult, plainResult
end

return HU
