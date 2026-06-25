local font_names = { "Normal", "Menu", "HUD", "Aliased" }
local font_enums = { FONT_NORMAL, FONT_MENU, FONT_HUD, FONT_ALIASED }
local part_names = { "PANTS", "SHIRT", "GLOVES", "SHOES", "HAIR", "CAP", "SKIN", "EMBLEM" }
local part_enums = { PANTS, SHIRT, GLOVES, SHOES, HAIR, CAP, SKIN, EMBLEM }
local part_to_idx = { PANTS = 1, SHIRT = 2, GLOVES = 3, SHOES = 4, HAIR = 5, CAP = 6, SKIN = 7, EMBLEM = 8 }

local presets = {
	["Mario"] = {
		[1] = { 0, 0, 255 },
		[2] = { 255, 0, 0 },
		[3] = { 255, 255, 255 },
		[4] = { 114, 28, 14 },
		[5] = { 115, 6, 0 },
		[6] = { 255, 0, 0 },
		[7] = { 254, 193, 121 },
		[8] = { 255, 0, 0 },
	},
	["Luigi"] = {
		[1] = { 0, 0, 255 },
		[2] = { 0, 255, 0 },
		[3] = { 255, 255, 255 },
		[4] = { 114, 28, 14 },
		[5] = { 115, 6, 0 },
		[6] = { 0, 255, 0 },
		[7] = { 254, 193, 121 },
		[8] = { 0, 255, 0 },
	},
	["Toad"] = {
		[1] = { 255, 255, 255 },
		[2] = { 0, 0, 255 },
		[3] = { 255, 255, 255 },
		[4] = { 114, 28, 14 },
		[5] = { 115, 6, 0 },
		[6] = { 255, 255, 255 },
		[7] = { 254, 193, 121 },
		[8] = { 255, 0, 0 },
	},
	["Wario"] = {
		[1] = { 128, 0, 128 },
		[2] = { 255, 255, 0 },
		[3] = { 255, 255, 255 },
		[4] = { 0, 128, 0 },
		[5] = { 115, 6, 0 },
		[6] = { 255, 255, 0 },
		[7] = { 254, 193, 121 },
		[8] = { 0, 0, 255 },
	},
	["Waluigi"] = {
		[1] = { 40, 40, 40 },
		[2] = { 100, 0, 150 },
		[3] = { 255, 255, 255 },
		[4] = { 200, 100, 0 },
		[5] = { 115, 6, 0 },
		[6] = { 100, 0, 150 },
		[7] = { 254, 193, 121 },
		[8] = { 255, 255, 0 },
	},
	["Retro 1"] = {
		[1] = { 216, 40, 0 },
		[2] = { 156, 74, 0 },
		[3] = { 255, 204, 153 },
		[4] = { 156, 74, 0 },
		[5] = { 156, 74, 0 },
		[6] = { 216, 40, 0 },
		[7] = { 255, 204, 153 },
		[8] = { 216, 40, 0 },
	},
	["Retro 2"] = {
		[1] = { 32, 56, 236 },
		[2] = { 216, 40, 0 },
		[3] = { 255, 255, 255 },
		[4] = { 156, 74, 0 },
		[5] = { 156, 74, 0 },
		[6] = { 216, 40, 0 },
		[7] = { 255, 204, 153 },
		[8] = { 216, 40, 0 },
	},
	["Retro 3"] = {
		[1] = { 0, 0, 0 },
		[2] = { 216, 40, 0 },
		[3] = { 255, 255, 255 },
		[4] = { 0, 0, 0 },
		[5] = { 0, 0, 0 },
		[6] = { 216, 40, 0 },
		[7] = { 255, 204, 153 },
		[8] = { 216, 40, 0 },
	},
	["World"] = {
		[1] = { 40, 112, 200 },
		[2] = { 232, 48, 48 },
		[3] = { 255, 255, 255 },
		[4] = { 136, 72, 0 },
		[5] = { 136, 72, 0 },
		[6] = { 232, 48, 48 },
		[7] = { 248, 208, 152 },
		[8] = { 232, 48, 48 },
	},
	["Land"] = {
		[1] = { 15, 56, 15 },
		[2] = { 139, 172, 15 },
		[3] = { 155, 188, 15 },
		[4] = { 15, 56, 15 },
		[5] = { 15, 56, 15 },
		[6] = { 139, 172, 15 },
		[7] = { 155, 188, 15 },
		[8] = { 15, 56, 15 },
	},
	["Land 2"] = {
		[1] = { 85, 85, 85 },
		[2] = { 170, 170, 170 },
		[3] = { 255, 255, 255 },
		[4] = { 0, 0, 0 },
		[5] = { 0, 0, 0 },
		[6] = { 170, 170, 170 },
		[7] = { 255, 255, 255 },
		[8] = { 0, 0, 0 },
	},
}

local palette_names =
	{ "Mario", "Luigi", "Toad", "Wario", "Waluigi", "Retro 1", "Retro 2", "Retro 3", "World", "Land", "Land 2" }

-- ==========================================
-- CUSTOM HUD COLOR & RAINBOW PARSER
-- ==========================================
local function rainbow_rgb(lightness)
	local hue = (timer * 2) % 360
	local h = hue / 60
	local i = math.floor(h)
	local f = h - i
	local p = 0
	local q = lightness * (1 - f)
	local t = lightness * f
	local r, g, b = 0, 0, 0
	if i == 0 then
		r, g, b = lightness, t, p
	elseif i == 1 then
		r, g, b = q, lightness, p
	elseif i == 2 then
		r, g, b = p, lightness, t
	elseif i == 3 then
		r, g, b = p, q, lightness
	elseif i == 4 then
		r, g, b = t, p, lightness
	elseif i == 5 then
		r, g, b = lightness, p, q
	end
	return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function measure_colored_text(text, scale)
	local w, i = 0, 1
	while i <= #text do
		local s, e = string.find(text, "\\#[0-9a-fA-F]+\\", i)
		if s == i then
			i = e + 1
		else
			local next_tag = string.find(text, "\\#[0-9a-fA-F]+\\", i)
			local chunk = next_tag and string.sub(text, i, next_tag - 1) or string.sub(text, i)
			w = w + (djui_hud_measure_text(chunk) * scale)
			i = next_tag or (#text + 1)
		end
	end
	return w
end

local function djui_hud_print_colored_text(text, x, y, scale, base_r, base_g, base_b, alpha)
	local current_x, i = x, 1
	djui_hud_set_color(base_r, base_g, base_b, alpha)
	while i <= #text do
		local s, e = string.find(text, "\\#[0-9a-fA-F]+\\", i)
		if s == i then
			local hex = string.sub(text, s + 2, e - 1)
			djui_hud_set_color(
				tonumber(string.sub(hex, 1, 2), 16) or base_r,
				tonumber(string.sub(hex, 3, 4), 16) or base_g,
				tonumber(string.sub(hex, 5, 6), 16) or base_b,
				alpha
			)
			i = e + 1
		else
			local next_tag = string.find(text, "\\#[0-9a-fA-F]+\\", i)
			local chunk = next_tag and string.sub(text, i, next_tag - 1) or string.sub(text, i)
			djui_hud_print_text(chunk, current_x, y, scale)
			current_x = current_x + (djui_hud_measure_text(chunk) * scale)
			i = next_tag or (#text + 1)
		end
	end
end

-- ==========================================
-- ANIMATION EASING FUNCTIONS
-- ==========================================
local function ease_out_bounce(x)
	local n1, d1 = 7.5625, 2.75
	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		x = x - 1.5 / d1
		return n1 * x * x + 0.75
	elseif x < 2.5 / d1 then
		x = x - 2.25 / d1
		return n1 * x * x + 0.9375
	else
		x = x - 2.625 / d1
		return n1 * x * x + 0.984375
	end
end
local function ease_out_back(x)
	local c1 = 1.70158
	return 1 + (c1 + 1) * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
end
local function ease_out_elastic(x)
	local c4 = (2 * math.pi) / 3
	if x == 0 then
		return 0
	end
	if x == 1 then
		return 1
	end
	return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
end

-- ==========================================
-- STATES & GLOBAL VARIABLES
-- ==========================================
local local_frozen = false
local local_silenced = false

local editor_open, admin_open = false, false
local has_seen_startup = false
local startup_tab = 1
local startup_tabs = { "Rules", "Updates", "Others" }

local rules_text = {
	"1. No cheating or using external mods to gain an unfair advantage.",
	"2. Respect all players and avoid toxic behavior in the chat.",
	"3. Do not exploit glitches to bypass map boundaries.",
	"4. Listen to the server Admins and Owners at all times.",
}
local updates_text = {
	"v1.6: MOD RELEASE! You can Download \\#03fcc6\\Drench Game\\#F0AC3F\\ DX\\#ffffff\\ (v1.6) in:",
	"https://drive.google.com/file/d/1Nmajt2OXlAAUlJTJJelkbNncboLSuLFF/view",
	"v1.5: NEW 6 MINIGAMES! Hot Ring, Russian Roulette, Coin Fever, The Glitch...",
	"v1.4: Fixed Lamp In Broken Lamp, added Bob Ombs in Falling Explosives.",
	"v1.3: NEW 3 MINIGAMES!",
	"v1.2: Gravity Madness Bugfixes.",
	"v1.1: NEW MINIGAME! Gravity Madness.",
	"v1.0: NEW MINIGAME! Last Pillar Standing.",
}
local others_text = {
	"COMMUNITY MINIGAMES IDEAS",
	"Nothing here for now...",
	"Credits: All users who helped or gave ideas for the development of Drench Game Deluxe",
	"Creator: \\#db740c\\ ~\\#242f02\\Retro\\#481300\\Games\\#db740c\\~ ",
	"Collabs: \\#ff0058\\Naoki455\\#ffffff\\, \\#ffff4e\\HarinaPAN\\#ffffff\\(Helper)",
}

-- Voting System State (Synced globally via gPlayerSyncTable & gGlobalSyncTable)
gGlobalSyncTable.vote_reset_count = 0
local local_reset_count = 0
local vote_sel = 1
local vote_options = {
	"Glass",
	"Red Green Light",
	"Star Steal",
	"King Of The Hill",
	"Bomb Tag",
	"Mingle",
	"Lights Out",
	"Dice",
	"Coin Rain",
	"Death Hit",
	"Broken Lamp",
	"Duel",
}

timer = 0
local msg_preview = "Text"

local active_title = nil
local active_title_timer = 0
local custom_gravities, custom_colors = {}, {}

-- Text Editor State (/a)
local cur_tab, cur_opt = 1, 0
local pos_names = { "Center", "Up", "Down", "Left", "Right" }
local anim_names = {
	"None",
	"Fade",
	"Slide Y",
	"Slide X",
	"Bounce",
	"Back",
	"Elastic",
	"Zoom",
	"Shake",
	"Rotate 3D",
	"Drop",
	"Fly In",
	"Wipe",
}
local msg_types = { "Normal", "Chat", "Notification" }
local val = {
	size = 1.00,
	font_idx = 1,
	rainbow_text = false,
	lightness_text = 1.00,
	opacity = 1.00,
	color = { 255, 255, 255 },
	bg_size = 1.00,
	rainbow_bg = false,
	lightness_bg = 1.00,
	bg_opacity = 1.00,
	bg_color = { 0, 0, 0 },
	time = 10.00,
	pos_idx = 1,
	target_idx = 1,
	msg_type = 1,
	anim_in = 5,
	anim_in_dur = 1.0,
	anim_out = 5,
	anim_out_dur = 1.0,
	custom_amt = 1,
	custom_players = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
}
local tabs = { "TEXT", "BACKGROUND", "ANIMATIONS", "GENERAL" }

-- Admin Menu State (/menu)
local adm_tab, adm_opt = 1, 0
local adm_tabs = { "Spawn", "Teleport", "Health", "Moderation", "Power Ups", "Gravity", "Colors" }
local adm_val = {
	obj_idx = 1,
	amt = 1,
	tgt = 1,
	tp_a = 1,
	tp_b = 1,
	health = 8,
	freeze = false,
	chat = false,
	kill = false,
	pw_w1 = true,
	pw_m = false,
	pw_v = true,
	pw_sh = false,
	gravity = 100,
	palette_idx = 1,
	color_r = 255,
	color_g = 255,
	color_b = 255,
	parts_toggles = { true, true, true, true, true, true, true, true },
	custom_amt = 1,
	custom_players = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	custom_amt_a = 1,
	custom_players_a = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
}

local obj_list = {
	"\\#00ffff\\Coin \\#ffffff\\(Moving)",
	"\\#00ffff\\Coin \\#ffffff\\(Static)",
	"\\#00ffff\\Red Coin",
	"\\#00ffff\\Blue Coin \\#ffffff\\(Moving)",
	"\\#00ffff\\Blue Coin \\#ffffff\\(Jumping)",
	"\\#00ffff\\Goomba",
	"\\#00ffff\\Bob Omb",
	"\\#00ffff\\Koopa Troopa",
	"\\#00ffff\\Whomp",
	"\\#00ffff\\Heave ho",
	"\\#00ffff\\Star",
	"\\#00ffff\\Fire",
	"\\#00ffff\\Breakable Box",
	"\\#00ffff\\Pushable Metal Box",
}
local obj_bhvs = {
	id_bhvMovingYellowCoin,
	id_bhvYellowCoin,
	id_bhvRedCoin,
	id_bhvMovingBlueCoin,
	id_bhvBlueCoinJumping,
	id_bhvGoomba,
	id_bhvBobomb,
	id_bhvKoopa,
	id_bhvSmallWhomp,
	id_bhvHeaveHo,
	id_bhvStar,
	id_bhvFlame,
	id_bhvBreakableBox,
	id_bhvPushableMetalBox,
}
local obj_models = {
	E_MODEL_YELLOW_COIN,
	E_MODEL_YELLOW_COIN,
	E_MODEL_RED_COIN,
	E_MODEL_BLUE_COIN,
	E_MODEL_BLUE_COIN,
	E_MODEL_GOOMBA,
	E_MODEL_BLACK_BOBOMB,
	E_MODEL_KOOPA_WITH_SHELL,
	E_MODEL_WHOMP,
	E_MODEL_HEAVE_HO,
	E_MODEL_STAR,
	E_MODEL_RED_FLAME,
	E_MODEL_BREAKABLE_BOX,
	E_MODEL_METAL_BOX,
}

-- ==========================================
-- DYNAMIC ENGINE OPTS ASSEMBLERS
-- ==========================================
local function build_editor_opts()
	local dyn = {}
	if cur_tab == 1 then
		table.insert(dyn, "Size")
		table.insert(dyn, "Font")
		table.insert(dyn, "Rainbow")
		if val.rainbow_text then
			table.insert(dyn, "Lightness")
		else
			table.insert(dyn, "Red")
			table.insert(dyn, "Green")
			table.insert(dyn, "Blue")
		end
		table.insert(dyn, "Opacity")
	elseif cur_tab == 2 then
		table.insert(dyn, "BG Size")
		table.insert(dyn, "Rainbow BG")
		if val.rainbow_bg then
			table.insert(dyn, "Lightness BG")
		else
			table.insert(dyn, "BG Red")
			table.insert(dyn, "BG Green")
			table.insert(dyn, "BG Blue")
		end
		table.insert(dyn, "BG Opacity")
	elseif cur_tab == 3 then
		dyn = { "Enter", "Enter Duration", "Exit", "Exit Duration" }
	elseif cur_tab == 4 then
		local all_t = get_targets(true)
		dyn = { "Type", "Target" }
		if all_t[val.target_idx] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		table.insert(dyn, "Time")
		table.insert(dyn, "Position")
		table.insert(dyn, "SEND MESSAGE")
	end
	return dyn
end

local function build_admin_opts()
	local dyn = {}
	local all_t = get_targets(true)
	if adm_tab == 1 then
		dyn = { "Object", "Amount", "Target" }
		if all_t[adm_val.tgt] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, adm_val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		table.insert(dyn, "ACTION")
	elseif adm_tab == 2 then
		dyn = { "A" }
		if all_t[adm_val.tp_a] == "Choose Players..." then
			table.insert(dyn, "Custom Amt A")
			for j = 1, adm_val.custom_amt_a do
				table.insert(dyn, "Teleport " .. j)
			end
		end
		dyn[#dyn + 1] = "B"
		dyn[#dyn + 1] = "ACTION"
	elseif adm_tab == 3 then
		dyn = { "Health", "Target" }
		if all_t[adm_val.tgt] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, adm_val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		table.insert(dyn, "ACTION")
	elseif adm_tab == 4 then
		dyn = { "Target" }
		if all_t[adm_val.tgt] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, adm_val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		dyn[#dyn + 1] = "Freeze"
		dyn[#dyn + 1] = "Chat Silence"
		dyn[#dyn + 1] = "Kill Target"
		dyn[#dyn + 1] = "APPLY MOD"
	elseif adm_tab == 5 then
		dyn = { "WING CAP", "METAL CAP", "VANISH CAP", "KOOPA SHELL", "Target" }
		if all_t[adm_val.tgt] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, adm_val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		table.insert(dyn, "ACTION")
	elseif adm_tab == 6 then
		dyn = { "Gravity", "Target" }
		if all_t[adm_val.tgt] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, adm_val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		dyn[#dyn + 1] = "SET DEFAULT"
		dyn[#dyn + 1] = "ACTION"
	elseif adm_tab == 7 then
		dyn = { "Target" }
		if all_t[adm_val.tgt] == "Choose Players..." then
			table.insert(dyn, "Custom Amt")
			for j = 1, adm_val.custom_amt do
				table.insert(dyn, "Player " .. j)
			end
		end
		table.insert(dyn, "Palette")
		for _, name in ipairs(part_names) do
			table.insert(dyn, name)
		end
		dyn[#dyn + 1] = "Red"
		dyn[#dyn + 1] = "Green"
		dyn[#dyn + 1] = "Blue"
		dyn[#dyn + 1] = "ACTION"
		dyn[#dyn + 1] = "DEFAULT"
	end
	return dyn
end

function get_targets(include_everyone)
	local list = {}
	if include_everyone then
		table.insert(list, "Everyone")
		table.insert(list, "All (Except Me)")
		table.insert(list, "Choose Players...")
	end
	for i = 0, MAX_PLAYERS - 1 do
		if gNetworkPlayers[i].connected then
			table.insert(list, gNetworkPlayers[i].name)
		end
	end
	if #list == 0 then
		table.insert(list, "None")
	end
	return list
end

local function is_valid_target(target_name, sender_name, my_name, custom_names)
	if target_name == "Everyone" then
		return true
	end
	if target_name == "All (Except Me)" and my_name ~= sender_name then
		return true
	end
	if target_name == "Choose Players..." then
		if custom_names then
			for _, c_name in ipairs(custom_names) do
				if c_name == my_name then
					return true
				end
			end
		end
		return false
	end
	if target_name == my_name then
		return true
	end
	return false
end

local function get_title_coords(sw, sh, t_size, bg_size, pos_idx, txt_w, anim_off_y)
	local box_h = 80 * bg_size
	local x_pos, y_pos, t_x = 0, sh / 2 - (box_h / 2), (sw - txt_w) / 2
	if pos_idx == 2 then
		y_pos = 10
	end
	if pos_idx == 3 then
		y_pos = sh - box_h - 10
	end
	if pos_idx == 4 then
		t_x = 10
	end
	if pos_idx == 5 then
		t_x = sw - txt_w - 10
	end
	y_pos = y_pos + anim_off_y
	return x_pos, y_pos, t_x, y_pos + (box_h / 2) - (10 * t_size), sw, box_h
end

local function parse_custom_names(str)
	local res = {}
	if str and str ~= "" then
		for name in string.gmatch(str, "([^,]+)") do
			table.insert(res, name)
		end
	end
	return res
end

-- ==========================================
-- NETWORK & ACTION PIPELINES
-- ==========================================
local function execute_admin_action(data)
	local m = gMarioStates[0]
	local np = gNetworkPlayers[0]
	local c_names = parse_custom_names(data.c)
	local is_target = is_valid_target(data.t, data.s, np.name, c_names)

	if data.a == 8 and is_target then -- Spawn objects
		for _ = 1, data.amt do
			spawn_sync_object(
				obj_bhvs[data.obj],
				obj_models[data.obj],
				m.pos.x,
				m.pos.y + 200,
				m.pos.z,
				function(o) end
			)
		end
		return
	end

	if data.a == 7 and is_target then -- moderation
		if data.fr ~= nil then
			local_frozen = data.fr
		end
		if data.ch ~= nil then
			local_silenced = data.ch
		end
		if data.k then
			m.health = 0
			m.hurtCounter = 8
		end
		return
	end

	if data.a == 4 then -- gravity
		local function apply_grav(name)
			custom_gravities[name] = data.gr / 100
		end
		if data.t == "Everyone" then
			for i = 0, MAX_PLAYERS - 1 do
				if gNetworkPlayers[i].connected then
					apply_grav(gNetworkPlayers[i].name)
				end
			end
		elseif data.t == "All (Except Me)" then
			for i = 0, MAX_PLAYERS - 1 do
				if gNetworkPlayers[i].connected and gNetworkPlayers[i].name ~= data.s then
					apply_grav(gNetworkPlayers[i].name)
				end
			end
		elseif data.t == "Choose Players..." then
			for _, c in ipairs(c_names) do
				apply_grav(c)
			end
		else
			apply_grav(data.t)
		end
		return
	end

	if data.a == 5 or data.a == 6 then -- color and color_default
		local function apply_color(name)
			if data.a == 6 then
				for idx = 1, 8 do
					if (data.mk & (1 << (idx - 1))) ~= 0 then
						if custom_colors[name] then
							custom_colors[name][idx] = nil
						end
					end
				end
			else
				if not custom_colors[name] then
					custom_colors[name] = {}
				end
				if data.pl and data.pl > 1 then
					local p_name = palette_names[data.pl]
					local pre = presets[p_name]
					if pre then
						for idx = 1, 8 do
							if pre[idx] then
								custom_colors[name][idx] = { r = pre[idx][1], g = pre[idx][2], b = pre[idx][3] }
							end
						end
					end
				else
					for idx = 1, 8 do
						if (data.mk & (1 << (idx - 1))) ~= 0 then
							custom_colors[name][idx] = { r = data.r, g = data.g, b = data.b }
						end
					end
				end
			end
		end
		if data.t == "Everyone" then
			for i = 0, MAX_PLAYERS - 1 do
				if gNetworkPlayers[i].connected then
					apply_color(gNetworkPlayers[i].name)
				end
			end
		elseif data.t == "All (Except Me)" then
			for i = 0, MAX_PLAYERS - 1 do
				if gNetworkPlayers[i].connected and gNetworkPlayers[i].name ~= data.s then
					apply_color(gNetworkPlayers[i].name)
				end
			end
		elseif data.t == "Choose Players..." then
			for _, c in ipairs(c_names) do
				apply_color(c)
			end
		else
			apply_color(data.t)
		end
		return
	end

	if data.a == 1 then -- teleport
		local c_names_a = parse_custom_names(data.ca)
		if is_valid_target(data.ta, data.s, np.name, c_names_a) then
			local dest_x, dest_y, dest_z = m.pos.x, m.pos.y, m.pos.z
			local dest_lvl, dest_area, dest_act
			local found = false
			for i = 0, MAX_PLAYERS - 1 do
				if gNetworkPlayers[i].connected and gNetworkPlayers[i].name == data.tb then
					dest_x, dest_y, dest_z = gMarioStates[i].pos.x, gMarioStates[i].pos.y, gMarioStates[i].pos.z
					dest_lvl = gNetworkPlayers[i].currLevelNum
					dest_area = gNetworkPlayers[i].currAreaIndex
					dest_act = gNetworkPlayers[i].currActNum
					found = true
					break
				end
			end
			if found then
				if gNetworkPlayers[0].currLevelNum ~= dest_lvl or gNetworkPlayers[0].currAreaIndex ~= dest_area then
					warp_to_level(dest_lvl, dest_area, dest_act)
				else
					m.pos.x, m.pos.y, m.pos.z = dest_x, dest_y, dest_z
				end
			end
		end
		return
	end

	if is_target then
		if data.a == 2 then
			m.health = (data.h * 256) -- health
		elseif data.a == 3 then -- powerups
			if data.w then
				m.flags = m.flags | MARIO_WING_CAP
				m.capTimer = 600
			end
			if data.m then
				m.flags = m.flags | MARIO_METAL_CAP
				m.capTimer = 600
			end
			if data.v then
				m.flags = m.flags | MARIO_VANISH_CAP
				m.capTimer = 600
			end
			if data.sh then
				spawn_sync_object(
					id_bhvKoopaShell,
					E_MODEL_KOOPA_SHELL,
					m.pos.x,
					m.pos.y + 150,
					m.pos.z,
					function(o) end
				)
			end
			play_sound(SOUND_MENU_STAR_SOUND, m.marioObj.header.gfx.cameraToObject)
		end
	end
end

function on_packet_receive(data)
	if type(data) ~= "table" then
		return
	end
	local np = gNetworkPlayers[0]

	if data.req_id == "dt" then
		local c_names = parse_custom_names(data.cn)
		if is_valid_target(data.t, data.s, np.name, c_names) then
			if data.mt == 2 then
				djui_chat_message_create(data.m)
			elseif data.mt == 3 then
				djui_popup_create(data.m, 1)
			else
				active_title = {
					size = data.sz,
					opacity = data.op,
					color = { data.cr, data.cg, data.cb },
					bg_size = data.bs,
					bg_opacity = data.bo,
					bg_color = { data.bcr, data.bcg, data.bcb },
					time = data.tm,
					msg = data.m,
					pos = data.p,
					font = data.f or 1,
					anim_in = data.ai,
					anim_in_dur = data.ad,
					anim_out = data.ao,
					anim_out_dur = data.aod,
					rainbow_text = data.rt == 1,
					lightness_text = data.lt or 1.0,
					rainbow_bg = data.rb == 1,
					lightness_bg = data.lb or 1.0,
				}
				active_title_timer = 0
			end
		end
	elseif data.req_id == "da" then
		execute_admin_action(data)
	end
end

-- ==========================================
-- HUD CORE RENDERING PIPELINE
-- ==========================================
function on_hud_render()
	local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()
	timer = timer + 1

	if active_title then
		active_title_timer = active_title_timer + 1
		local elapsed = active_title_timer / 30
		if active_title.time > 0 and elapsed > active_title.time then
			active_title = nil
		else
			local mult_alpha, off_x, off_y, scale_mult = 1.0, 0, 0, 1.0
			local function apply_anim(type_anim, p, is_enter)
				local dir, dist_y, dist_x =
					is_enter and -1 or 1, sh * (is_enter and -1 or 1), sw * (is_enter and -1 or 1)
				if type_anim == 2 then
					mult_alpha = p
				elseif type_anim == 3 then
					off_y = dist_y * (1 - p)
				elseif type_anim == 4 then
					off_x = dist_x * (1 - p)
				elseif type_anim == 5 then
					off_y = dist_y * (1 - ease_out_bounce(p))
				elseif type_anim == 6 then
					off_y = dist_y * (1 - ease_out_back(p))
				elseif type_anim == 7 then
					off_y = dist_y * (1 - ease_out_elastic(p))
				elseif type_anim == 8 then
					scale_mult = p
				elseif type_anim == 9 then
					off_x = math.sin(p * math.pi * 10) * (20 * (1 - p))
					off_y = math.cos(p * math.pi * 12) * (20 * (1 - p))
				elseif type_anim == 10 then
					scale_mult = p
					off_x = math.cos(p * math.pi * 6) * (150 * (1 - p))
					off_y = math.sin(p * math.pi * 6) * (150 * (1 - p))
				elseif type_anim == 11 then
					off_y = (dist_y * 1.5) * (1 - math.pow(p, 0.2))
				elseif type_anim == 12 then
					off_x = (dist_x * 1.5) * (1 - math.pow(p, 0.2))
				elseif type_anim == 13 then
					scale_mult = p
					mult_alpha = p
				end
			end
			if elapsed < active_title.anim_in_dur and active_title.anim_in_dur > 0 then
				apply_anim(active_title.anim_in, elapsed / active_title.anim_in_dur, true)
			end
			if
				active_title.time > 0
				and elapsed > (active_title.time - active_title.anim_out_dur)
				and active_title.anim_out_dur > 0
			then
				apply_anim(
					active_title.anim_out,
					math.max(0, (active_title.time - elapsed) / active_title.anim_out_dur),
					false
				)
			end

			local final_size = active_title.size * scale_mult
			if final_size > 0 then
				djui_hud_set_font(font_enums[active_title.font or 1] or FONT_NORMAL)
				local txt_w = measure_colored_text(active_title.msg, final_size)
				local x_pos, y_pos, t_x, t_y, box_w, box_h =
					get_title_coords(sw, sh, final_size, active_title.bg_size, active_title.pos, txt_w, off_y)

				local br, bg, bb = active_title.bg_color[1], active_title.bg_color[2], active_title.bg_color[3]
				if active_title.rainbow_bg then
					br, bg, bb = rainbow_rgb(active_title.lightness_bg)
				end
				djui_hud_set_color(br, bg, bb, math.floor((active_title.bg_opacity * mult_alpha) * 255))
				djui_hud_render_rect(x_pos + off_x, y_pos, box_w, box_h)

				local tr, tg, tb = active_title.color[1], active_title.color[2], active_title.color[3]
				if active_title.rainbow_text then
					tr, tg, tb = rainbow_rgb(active_title.lightness_text)
				end
				djui_hud_print_colored_text(
					active_title.msg,
					t_x + off_x,
					t_y,
					final_size,
					tr,
					tg,
					tb,
					math.floor((active_title.opacity * mult_alpha) * 255)
				)
			end
		end
	end

	if not editor_open and not admin_open then
		return
	end
	local all_t = get_targets(true)
	local p_t = get_targets(false)

	if editor_open then
		djui_hud_set_font(font_enums[val.font_idx] or FONT_NORMAL)
		local pr, pg, pb = val.color[1], val.color[2], val.color[3]
		if val.rainbow_text then
			pr, pg, pb = rainbow_rgb(val.lightness_text)
		end
		local pbr, pbg, pbb = val.bg_color[1], val.bg_color[2], val.bg_color[3]
		if val.rainbow_bg then
			pbr, pbg, pbb = rainbow_rgb(val.lightness_bg)
		end

		local p_txt_w = measure_colored_text(msg_preview, val.size)
		local p_x, p_y, p_tx, p_ty, p_w, p_h = get_title_coords(sw, sh, val.size, val.bg_size, val.pos_idx, p_txt_w, 0)
		djui_hud_set_color(pbr, pbg, pbb, math.floor(val.bg_opacity * 255))
		djui_hud_render_rect(p_x, p_y, p_w, p_h)
		djui_hud_print_colored_text(msg_preview, p_tx, p_ty, val.size, pr, pg, pb, math.floor(val.opacity * 255))

		djui_hud_set_font(FONT_NORMAL)
		djui_hud_set_color(15, 15, 20, 230)
		djui_hud_render_rect(20, 20, 380, sh - 40)
		local t_color = (cur_opt == 0) and 255 or 150
		djui_hud_set_color(t_color, t_color, t_color, 255)
		djui_hud_print_text((cur_opt == 0 and "> < " or "  < ") .. tabs[cur_tab] .. " >", 50, 40, 1.0)

		local dyn_opts = build_editor_opts()
		if cur_opt > #dyn_opts then
			cur_opt = #dyn_opts
		end
		local is_locked = (val.msg_type == 2 or val.msg_type == 3)

		for i, label in ipairs(dyn_opts) do
			local is_hover = (cur_opt == i)
			local y_pos = 90 + (i * 26)
			local t_label, t_val, t_val_color = label .. ":", "", { 50, 150, 255 }
			local option_locked = is_locked
				and not (
					label == "Type"
					or label == "Target"
					or label == "SEND MESSAGE"
					or string.match(label, "Custom")
					or string.match(label, "Player")
				)

			if label == "SEND MESSAGE" then
				t_label = (is_hover and "[ SEND MESSAGE ]" or "  SEND MESSAGE")
				t_val_color = { is_hover and 0 or 100, is_hover and 255 or 100, is_hover and 0 or 100 }
			end
			if not is_hover and label ~= "SEND MESSAGE" then
				t_val_color[1] = t_val_color[1] - 50
				t_val_color[2] = t_val_color[2] - 50
				t_val_color[3] = t_val_color[3] - 50
			end

			if label == "Size" then
				t_val = string.format(" %.2f", val.size)
			end
			if label == "Font" then
				t_val = " " .. font_names[val.font_idx]
			end
			if label == "Rainbow" then
				t_val = " " .. (val.rainbow_text and "On" or "Off")
			end
			if label == "Lightness" then
				t_val = string.format(" %.2f", val.lightness_text)
			end
			if label == "Opacity" then
				t_val = string.format(" %.2f", val.opacity)
			end
			if label == "Red" then
				t_val = " " .. val.color[1]
				t_val_color = { 255, 50, 50 }
			end
			if label == "Green" then
				t_val = " " .. val.color[2]
				t_val_color = { 50, 255, 50 }
			end
			if label == "Blue" then
				t_val = " " .. val.color[3]
			end
			if label == "BG Size" then
				t_val = string.format(" %.2f", val.bg_size)
			end
			if label == "Rainbow BG" then
				t_val = " " .. (val.rainbow_bg and "On" or "Off")
			end
			if label == "Lightness BG" then
				t_val = string.format(" %.2f", val.lightness_bg)
			end
			if label == "BG Opacity" then
				t_val = string.format(" %.2f", val.bg_opacity)
			end
			if label == "BG Red" then
				t_val = " " .. val.bg_color[1]
				t_val_color = { 255, 50, 50 }
			end
			if label == "BG Green" then
				t_val = " " .. val.bg_color[2]
				t_val_color = { 50, 255, 50 }
			end
			if label == "BG Blue" then
				t_val = " " .. val.bg_color[3]
			end

			if label == "Type" then
				t_val = " " .. msg_types[val.msg_type]
			end
			if label == "Time" then
				t_val = (val.time < 1.0) and " Infinite" or string.format(" %.1f", val.time)
			end
			if label == "Position" then
				t_val = " " .. pos_names[val.pos_idx]
			end
			if label == "Target" then
				t_val = " " .. all_t[val.target_idx]
				t_val_color = { 255, 255, 50 }
			end
			if label == "Custom Amt" then
				t_val = " " .. val.custom_amt
				t_val_color = { 200, 200, 50 }
			end
			if string.match(label, "Player %d+") then
				local id = tonumber(string.match(label, "Player (%d+)"))
				t_val = " " .. (p_t[val.custom_players[id]] or "None")
				t_val_color = { 200, 200, 200 }
			end
			if label == "Enter" then
				t_val = " " .. anim_names[val.anim_in]
			end
			if label == "Enter Duration" then
				t_val = string.format(" %.1f", val.anim_in_dur)
			end
			if label == "Exit" then
				t_val = " " .. anim_names[val.anim_out]
			end
			if label == "Exit Duration" then
				t_val = string.format(" %.1f", val.anim_out_dur)
			end

			local prefix = (is_hover and "-> " or "   ")
			if label == "SEND MESSAGE" then
				prefix = ""
			end

			if option_locked then
				djui_hud_set_color(80, 80, 80, 255)
				djui_hud_print_text(prefix .. t_label, 40, y_pos, 1.0)
				if t_val ~= "" then
					djui_hud_print_text(t_val, 40 + djui_hud_measure_text(prefix .. t_label), y_pos, 1.0)
				end
			else
				djui_hud_set_color(255, 255, 0, 255)
				if label == "SEND MESSAGE" then
					djui_hud_set_color(t_val_color[1], t_val_color[2], t_val_color[3], 255)
				end
				djui_hud_print_text(prefix .. t_label, 40, y_pos, 1.0)
				if t_val ~= "" then
					djui_hud_set_color(t_val_color[1], t_val_color[2], t_val_color[3], 255)
					djui_hud_print_text(t_val, 40 + djui_hud_measure_text(prefix .. t_label), y_pos, 1.0)
				end
			end
		end
	end

	if admin_open then
		djui_hud_set_font(FONT_NORMAL)
		djui_hud_set_color(15, 15, 20, 245)
		djui_hud_render_rect(20, 20, sw - 40, sh - 40)
		djui_hud_set_color(255, 215, 0, 255)
		djui_hud_print_text("OWNERS MENU!", sw / 2 - 100, 30, 1.2)
		local t_color = (adm_opt == 0) and 255 or 150
		djui_hud_set_color(255, 0, 0, t_color)
		djui_hud_print_text((adm_opt == 0 and "> < " or "  < ") .. adm_tabs[adm_tab] .. " >", sw / 2 - 80, 70, 1.0)

		local dyn_opts = build_admin_opts()
		if adm_opt > #dyn_opts then
			adm_opt = #dyn_opts
		end

		for i, label in ipairs(dyn_opts) do
			local y_pos = 110 + (i * 24)
			local is_hover = (adm_opt == i)
			local prefix = (is_hover and "> " or "  ")
			local t_label, t_val, is_action, t_val_color = label .. ":", "", false, { 50, 150, 255 }
			local lbl_r, lbl_g, lbl_b = 255, 255, 0

			if label == "ACTION" or label == "DEFAULT" or label == "SET DEFAULT" or label == "APPLY MOD" then
				is_action = true
				t_label = is_hover and ">> " .. label .. " <<" or "[" .. label .. "]"
				t_val_color = (label == "DEFAULT" or label == "SET DEFAULT") and { 200, 200, 50 } or { 50, 200, 50 }
			else
				if label == "Object" then
					t_val = " " .. obj_list[adm_val.obj_idx]
				end
				if label == "Amount" then
					t_val = " " .. adm_val.amt
				end
				if label == "Target" then
					t_val = " " .. (all_t[adm_val.tgt] or "None")
				end
				if label == "A" then
					t_val = " " .. (all_t[adm_val.tp_a] or "None")
				end
				if label == "B" then
					t_val = " " .. (p_t[adm_val.tp_b] or "None")
				end
				if label == "Custom Amt" or label == "Custom Amt A" then
					t_val = " " .. (label == "Custom Amt" and adm_val.custom_amt or adm_val.custom_amt_a)
					t_val_color = { 200, 200, 50 }
				end
				if string.match(label, "Player %d+") then
					local id = tonumber(string.match(label, "Player (%d+)"))
					t_val = " " .. (p_t[adm_val.custom_players[id]] or "None")
					t_val_color = { 200, 200, 200 }
				end
				if string.match(label, "Teleport %d+") then
					local id = tonumber(string.match(label, "Teleport (%d+)"))
					t_val = " " .. (p_t[adm_val.custom_players_a[id]] or "None")
					t_val_color = { 200, 200, 200 }
				end

				if label == "Red" then
					t_val_color = { 255, 50, 50 }
					t_val = " " .. adm_val.color_r
				end
				if label == "Green" then
					t_val_color = { 50, 255, 50 }
					t_val = " " .. adm_val.color_g
				end
				if label == "Blue" then
					t_val_color = { 50, 150, 255 }
					t_val = " " .. adm_val.color_b
				end
				if label == "Palette" then
					t_val = " " .. palette_names[adm_val.palette_idx]
					t_val_color = { 255, 200, 255 }
				end

				if label == "Freeze" then
					t_val_color = { adm_val.freeze and 50 or 255, adm_val.freeze and 255 or 50, 50 }
					t_val = " " .. (adm_val.freeze and "On" or "Off")
				end
				if label == "Chat Silence" then
					t_val_color = { adm_val.chat and 50 or 255, adm_val.chat and 255 or 50, 50 }
					t_val = " " .. (adm_val.chat and "On" or "Off")
				end
				if label == "Kill Target" then
					t_val_color = { adm_val.kill and 50 or 255, adm_val.kill and 255 or 50, 50 }
					t_val = " " .. (adm_val.kill and "Yes" or "No")
				end
				if label == "Gravity" then
					t_val = " " .. adm_val.gravity .. "%"
				end

				if label == "Health" then
					if adm_val.health >= 7 then
						t_val_color = { 135, 206, 250 }
					elseif adm_val.health >= 5 then
						t_val_color = { 50, 255, 50 }
					elseif adm_val.health >= 3 then
						t_val_color = { 255, 255, 50 }
					elseif adm_val.health >= 1 then
						t_val_color = { 255, 50, 50 }
					else
						t_val_color = { 150, 150, 150 }
					end
					t_val = " " .. adm_val.health
				end

				if label == "WING CAP" then
					lbl_r, lbl_g, lbl_b = 255, 50, 50
					t_val = " " .. (adm_val.pw_w1 and "Yes" or "No")
					t_val_color = adm_val.pw_w1 and { 50, 255, 50 } or { 255, 50, 50 }
				end
				if label == "METAL CAP" then
					lbl_r, lbl_g, lbl_b = 50, 255, 50
					t_val = " " .. (adm_val.pw_m and "Yes" or "No")
					t_val_color = adm_val.pw_m and { 50, 255, 50 } or { 255, 50, 50 }
				end
				if label == "VANISH CAP" then
					lbl_r, lbl_g, lbl_b = 100, 150, 255
					t_val = " " .. (adm_val.pw_v and "Yes" or "No")
					t_val_color = adm_val.pw_v and { 50, 255, 50 } or { 255, 50, 50 }
				end
				if label == "KOOPA SHELL" then
					lbl_r, lbl_g, lbl_b = 255, 255, 50
					t_val = " " .. (adm_val.pw_sh and "Yes" or "No")
					t_val_color = adm_val.pw_sh and { 50, 255, 50 } or { 255, 50, 50 }
				end

				local p_idx = part_to_idx[opt_name]
				if p_idx then
					t_val = " " .. (adm_val.parts_toggles[p_idx] and "On" or "Off")
					t_val_color = adm_val.parts_toggles[p_idx] and { 50, 255, 50 } or { 255, 50, 50 }
				end
			end

			if is_action then
				djui_hud_set_color(t_val_color[1], t_val_color[2], t_val_color[3], is_hover and 255 or 150)
				djui_hud_print_text(t_label, sw / 2 - 60, y_pos + 10, 1.0)
			else
				djui_hud_set_color(lbl_r, lbl_g, lbl_b, 255)
				djui_hud_print_text(prefix .. t_label, sw / 2 - 120, y_pos, 1.0)
				local offset_w = djui_hud_measure_text(prefix .. t_label)
				djui_hud_print_colored_text(
					t_val,
					sw / 2 - 120 + offset_w,
					y_pos,
					1.0,
					t_val_color[1],
					t_val_color[2],
					t_val_color[3],
					255
				)
			end
		end

		if adm_tab == 7 then
			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_render_rect(sw / 2 + 220, 150, 54, 54)
			djui_hud_set_color(adm_val.color_r, adm_val.color_g, adm_val.color_b, 255)
			djui_hud_render_rect(sw / 2 + 222, 152, 50, 50)
		end
	end
end

-- ==========================================
-- ENGINE CORE CONTROLS & TIMING REFRESH
-- ==========================================
function close_menus(m)
	if editor_open or admin_open then
		editor_open = false
		admin_open = false
		if m then
			set_mario_action(m, ACT_IDLE, 0)
			m.invincTimer = 150 -- 5 Seconds of invincibility ONLY when closing the menu (150 frames)
			djui_chat_message_create("\\#00ffff\\Menu Closed.")
		end
	end
end

hook_event(HOOK_BEFORE_PHYS_STEP, function(m)
	if m.playerIndex ~= 0 then
		return
	end
	if local_frozen then
		m.forwardVel = 0
		m.vel.x = 0
		m.vel.z = 0
		m.controller.stickX = 0
		m.controller.stickY = 0
	end
end)

function on_mario_update(m)
	local np_col = gNetworkPlayers[m.playerIndex]

	if np_col and np_col.connected and custom_colors[np_col.name] then
		for part_idx, col in pairs(custom_colors[np_col.name]) do
			if col and col.r and col.g and col.b then
				network_player_set_override_palette_color(
					np_col,
					part_enums[part_idx],
					{ r = col.r, g = col.g, b = col.b }
				)
			end
		end
	end

	if m.playerIndex ~= 0 then
		return
	end

	-- Sync vote resets globally
	if local_reset_count ~= gGlobalSyncTable.vote_reset_count then
		gPlayerSyncTable[0].vote = 0
		local_reset_count = gGlobalSyncTable.vote_reset_count
	end

	if not has_seen_startup then
		has_seen_startup = true
	end

	local np0_name = gNetworkPlayers[0].name

	if custom_gravities[np0_name] and custom_gravities[np0_name] ~= 1.0 then
		if (m.action & ACT_FLAG_AIR) ~= 0 then
			m.vel.y = m.vel.y + (4.0 * (1.0 - custom_gravities[np0_name]))
		end
	end

	local in_any_menu = editor_open or admin_open

	-- ONLY freezes movement if admin_open, editor_open, or vote_open are opened
	if editor_open or admin_open then
		if m.action ~= ACT_WAITING_FOR_DIALOG then
			set_mario_action(m, ACT_WAITING_FOR_DIALOG, 0)
		end
	end

	local btn, btn_d = m.controller.buttonPressed, m.controller.buttonDown
	if not in_any_menu then
		return
	end

	local all_t, p_t = get_targets(true), get_targets(false)

	-- ------------------------------------------
	-- /a ENGINE CONTROLS
	-- ------------------------------------------
	if editor_open then
		local dyn_opts = build_editor_opts()
		local is_locked = (val.msg_type == 2 or val.msg_type == 3)

		if (btn_d & U_JPAD) ~= 0 then
			if timer % 2 == 0 then
				cur_opt = math.max(0, cur_opt - 1)
			end
		end
		if (btn_d & D_JPAD) ~= 0 then
			if timer % 2 == 0 then
				cur_opt = math.min(#dyn_opts, cur_opt + 1)
			end
		end

		if cur_opt == 0 then
			if (btn & L_JPAD) ~= 0 then
				cur_tab = math.max(1, cur_tab - 1)
				cur_opt = 0
			end
			if (btn & R_JPAD) ~= 0 then
				cur_tab = math.min(#tabs, cur_tab + 1)
				cur_opt = 0
			end
		else
			local opt_name = dyn_opts[cur_opt]
			local option_locked = is_locked
				and not (
					opt_name == "Type"
					or opt_name == "Target"
					or opt_name == "SEND MESSAGE"
					or string.match(opt_name, "Custom")
					or string.match(opt_name, "Player")
				)

			if not option_locked then
				if (btn_d & L_JPAD) ~= 0 then
					if timer % 2 == 0 then
						if opt_name == "Position" then
							val.pos_idx = math.max(1, val.pos_idx - 1)
						end
						if opt_name == "Target" then
							val.target_idx = math.max(1, val.target_idx - 1)
						end
						if opt_name == "Type" then
							val.msg_type = math.max(1, val.msg_type - 1)
						end
						if opt_name == "Enter" then
							val.anim_in = math.max(1, val.anim_in - 1)
						end
						if opt_name == "Exit" then
							val.anim_out = math.max(1, val.anim_out - 1)
						end
						if opt_name == "Font" then
							val.font_idx = math.max(1, val.font_idx - 1)
						end
						if opt_name == "Rainbow" then
							val.rainbow_text = not val.rainbow_text
						end
						if opt_name == "Rainbow BG" then
							val.rainbow_bg = not val.rainbow_bg
						end

						if opt_name == "Size" then
							val.size = math.max(0.1, val.size - 0.1)
						end
						if opt_name == "Opacity" then
							val.opacity = math.max(0.0, val.opacity - 0.1)
						end
						if opt_name == "BG Size" then
							val.bg_size = math.max(0.1, val.bg_size - 0.1)
						end
						if opt_name == "BG Opacity" then
							val.bg_opacity = math.max(0.0, val.bg_opacity - 0.1)
						end
						if opt_name == "Lightness" then
							val.lightness_text = math.max(0.0, val.lightness_text - 0.05)
						end
						if opt_name == "Lightness BG" then
							val.lightness_bg = math.max(0.0, val.lightness_bg - 0.05)
						end

						if opt_name == "Time" then
							val.time = math.max(0, val.time - 0.1)
						end
						if opt_name == "Enter Duration" then
							val.anim_in_dur = math.max(0.1, val.anim_in_dur - 0.1)
						end
						if opt_name == "Exit Duration" then
							val.anim_out_dur = math.max(0.1, val.anim_out_dur - 0.1)
						end
						if opt_name == "Red" then
							val.color[1] = math.max(0, val.color[1] - 5)
						end
						if opt_name == "Green" then
							val.color[2] = math.max(0, val.color[2] - 5)
						end
						if opt_name == "Blue" then
							val.color[3] = math.max(0, val.color[3] - 5)
						end
						if opt_name == "BG Red" then
							val.bg_color[1] = math.max(0, val.bg_color[1] - 5)
						end
						if opt_name == "BG Green" then
							val.bg_color[2] = math.max(0, val.bg_color[2] - 5)
						end
						if opt_name == "BG Blue" then
							val.bg_color[3] = math.max(0, val.bg_color[3] - 5)
						end
						if opt_name == "Custom Amt" then
							val.custom_amt = math.max(1, val.custom_amt - 1)
						end
						if string.match(opt_name, "Player %d+") then
							local id = tonumber(string.match(opt_name, "Player (%d+)"))
							val.custom_players[id] = math.max(1, val.custom_players[id] - 1)
						end
					end
				end
				if (btn_d & R_JPAD) ~= 0 then
					if timer % 2 == 0 then
						if opt_name == "Position" then
							val.pos_idx = math.min(#pos_names, val.pos_idx + 1)
						end
						if opt_name == "Target" then
							val.target_idx = math.min(#all_t, val.target_idx + 1)
						end
						if opt_name == "Type" then
							val.msg_type = math.min(#msg_types, val.msg_type + 1)
						end
						if opt_name == "Enter" then
							val.anim_in = math.min(#anim_names, val.anim_in + 1)
						end
						if opt_name == "Exit" then
							val.anim_out = math.min(#anim_names, val.anim_out + 1)
						end
						if opt_name == "Font" then
							val.font_idx = math.min(#font_names, val.font_idx + 1)
						end
						if opt_name == "Rainbow" then
							val.rainbow_text = not val.rainbow_text
						end
						if opt_name == "Rainbow BG" then
							val.rainbow_bg = not val.rainbow_bg
						end

						if opt_name == "Size" then
							val.size = val.size + 0.1
						end
						if opt_name == "Opacity" then
							val.opacity = math.min(1.0, val.opacity + 0.1)
						end
						if opt_name == "BG Size" then
							val.bg_size = val.bg_size + 0.1
						end
						if opt_name == "BG Opacity" then
							val.bg_opacity = math.min(1.0, val.bg_opacity + 0.1)
						end
						if opt_name == "Lightness" then
							val.lightness_text = math.min(1.0, val.lightness_text + 0.05)
						end
						if opt_name == "Lightness BG" then
							val.lightness_bg = math.min(1.0, val.lightness_bg + 0.05)
						end

						if opt_name == "Time" then
							val.time = val.time + 0.1
						end
						if opt_name == "Enter Duration" then
							val.anim_in_dur = val.anim_in_dur + 0.1
						end
						if opt_name == "Exit Duration" then
							val.anim_out_dur = val.anim_out_dur + 0.1
						end
						if opt_name == "Red" then
							val.color[1] = math.min(255, val.color[1] + 5)
						end
						if opt_name == "Green" then
							val.color[2] = math.min(255, val.color[2] + 5)
						end
						if opt_name == "Blue" then
							val.color[3] = math.min(255, val.color[3] + 5)
						end
						if opt_name == "BG Red" then
							val.bg_color[1] = math.min(255, val.bg_color[1] + 5)
						end
						if opt_name == "BG Green" then
							val.bg_color[2] = math.min(255, val.bg_color[2] + 5)
						end
						if opt_name == "BG Blue" then
							val.bg_color[3] = math.min(255, val.bg_color[3] + 5)
						end
						if opt_name == "Custom Amt" then
							val.custom_amt = math.min(16, val.custom_amt + 1)
						end
						if string.match(opt_name, "Player %d+") then
							local id = tonumber(string.match(opt_name, "Player (%d+)"))
							val.custom_players[id] = math.min(#p_t, val.custom_players[id] + 1)
						end
					end
				end

				if (btn & A_BUTTON) ~= 0 and opt_name == "SEND MESSAGE" then
					local c_names = {}
					if all_t[val.target_idx] == "Choose Players..." then
						for i = 1, val.custom_amt do
							table.insert(c_names, p_t[val.custom_players[i]])
						end
					end

					local pkt = {
						req_id = "dt",
						m = msg_preview,
						s = np0_name,
						t = all_t[val.target_idx],
						cn = table.concat(c_names, ","),
						mt = val.msg_type,
						sz = val.size,
						op = val.opacity,
						cr = val.color[1],
						cg = val.color[2],
						cb = val.color[3],
						bs = val.bg_size,
						bo = val.bg_opacity,
						bcr = val.bg_color[1],
						bcg = val.bg_color[2],
						bcb = val.bg_color[3],
						tm = (val.time < 1.0) and -1 or val.time,
						p = val.pos_idx,
						ai = val.anim_in,
						ad = val.anim_in_dur,
						ao = val.anim_out,
						aod = val.anim_out_dur,
						f = val.font_idx,
						rt = val.rainbow_text and 1 or 0,
						lt = val.lightness_text,
						rb = val.rainbow_bg and 1 or 0,
						lb = val.lightness_bg,
					}

					network_send(true, pkt)
					on_packet_receive(pkt)
					close_menus(m)
				end
			end
		end
		if (btn & B_BUTTON) ~= 0 then
			close_menus(m)
		end
		return
	end

	-- ------------------------------------------
	-- /menu ENGINE CONTROLS
	-- ------------------------------------------
	if admin_open then
		local dyn_opts = build_admin_opts()

		local is_x = (btn_d & X_BUTTON) ~= 0
		local step_int = is_x and 5 or 1
		local step_dec = is_x and 1.0 or 0.1

		if (btn_d & U_JPAD) ~= 0 then
			if timer % 4 == 0 then
				adm_opt = math.max(0, adm_opt - 1)
			end
		end
		if (btn_d & D_JPAD) ~= 0 then
			if timer % 4 == 0 then
				adm_opt = math.min(#dyn_opts, adm_opt + 1)
			end
		end

		if adm_opt == 0 then
			if (btn & L_JPAD) ~= 0 then
				adm_tab = math.max(1, adm_tab - 1)
				adm_opt = 0
			end
			if (btn & R_JPAD) ~= 0 then
				adm_tab = math.min(#adm_tabs, adm_tab + 1)
				adm_opt = 0
			end
		else
			local opt_name = dyn_opts[adm_opt]
			if (btn_d & L_JPAD) ~= 0 then
				if timer % 4 == 0 then
					if opt_name == "Object" then
						adm_val.obj_idx = math.max(1, adm_val.obj_idx - 1)
					end
					if opt_name == "Target" then
						adm_val.tgt = math.max(1, adm_val.tgt - 1)
					end
					if opt_name == "A" then
						adm_val.tp_a = math.max(1, adm_val.tp_a - 1)
					end
					if opt_name == "B" then
						adm_val.tp_b = math.max(1, adm_val.tp_b - 1)
					end
					if opt_name == "Freeze" then
						adm_val.freeze = not adm_val.freeze
					end
					if opt_name == "Chat Silence" then
						adm_val.chat = not adm_val.chat
					end
					if opt_name == "Kill Target" then
						adm_val.kill = not adm_val.kill
					end
					if opt_name == "WING CAP" then
						adm_val.pw_w1 = not adm_val.pw_w1
					end
					if opt_name == "METAL CAP" then
						adm_val.pw_m = not adm_val.pw_m
					end
					if opt_name == "VANISH CAP" then
						adm_val.pw_v = not adm_val.pw_v
					end
					if opt_name == "KOOPA SHELL" then
						adm_val.pw_sh = not adm_val.pw_sh
					end
					if opt_name == "Palette" then
						adm_val.palette_idx = math.max(1, adm_val.palette_idx - 1)
					end

					if opt_name == "Amount" then
						adm_val.amt = math.max(1, adm_val.amt - step_int)
					end
					if opt_name == "Gravity" then
						adm_val.gravity = math.max(0, adm_val.gravity - step_int)
					end
					if opt_name == "Red" then
						adm_val.color_r = math.max(0, adm_val.color_r - step_int)
					end
					if opt_name == "Green" then
						adm_val.color_g = math.max(0, adm_val.color_g - step_int)
					end
					if opt_name == "Blue" then
						adm_val.color_b = math.max(0, adm_val.color_b - step_int)
					end
					if opt_name == "Health" then
						adm_val.health = math.max(0, adm_val.health - math.floor(step_dec * 10))
					end
					if opt_name == "Custom Amt" then
						adm_val.custom_amt = math.max(1, adm_val.custom_amt - 1)
					end
					if opt_name == "Custom Amt A" then
						adm_val.custom_amt_a = math.max(1, adm_val.custom_amt_a - 1)
					end

					local p_idx = part_to_idx[opt_name]
					if p_idx then
						adm_val.parts_toggles[p_idx] = not adm_val.parts_toggles[p_idx]
					end

					if string.match(opt_name, "Player %d+") then
						local id = tonumber(string.match(opt_name, "Player (%d+)"))
						adm_val.custom_players[id] = math.max(1, adm_val.custom_players[id] - 1)
					end
					if string.match(opt_name, "Teleport %d+") then
						local id = tonumber(string.match(opt_name, "Teleport (%d+)"))
						adm_val.custom_players_a[id] = math.max(1, adm_val.custom_players_a[id] - 1)
					end
				end
			end
			if (btn_d & R_JPAD) ~= 0 then
				if timer % 4 == 0 then
					if opt_name == "Object" then
						adm_val.obj_idx = math.min(#obj_list, adm_val.obj_idx + 1)
					end
					if opt_name == "Target" then
						adm_val.tgt = math.min(#all_t, adm_val.tgt + 1)
					end
					if opt_name == "A" then
						adm_val.tp_a = math.min(#all_t, adm_val.tp_a + 1)
					end
					if opt_name == "B" then
						adm_val.tp_b = math.min(#p_t, adm_val.tp_b + 1)
					end
					if opt_name == "Freeze" then
						adm_val.freeze = not adm_val.freeze
					end
					if opt_name == "Chat Silence" then
						adm_val.chat = not adm_val.chat
					end
					if opt_name == "Kill Target" then
						adm_val.kill = not adm_val.kill
					end
					if opt_name == "WING CAP" then
						adm_val.pw_w1 = not adm_val.pw_w1
					end
					if opt_name == "METAL CAP" then
						adm_val.pw_m = not adm_val.pw_m
					end
					if opt_name == "VANISH CAP" then
						adm_val.pw_v = not adm_val.pw_v
					end
					if opt_name == "KOOPA SHELL" then
						adm_val.pw_sh = not adm_val.pw_sh
					end
					if opt_name == "Palette" then
						adm_val.palette_idx = math.min(#palette_names, adm_val.palette_idx + 1)
					end

					if opt_name == "Amount" then
						adm_val.amt = math.min(999, adm_val.amt + step_int)
					end
					if opt_name == "Gravity" then
						adm_val.gravity = math.min(300, adm_val.gravity + step_int)
					end
					if opt_name == "Red" then
						adm_val.color_r = math.min(255, adm_val.color_r + step_int)
					end
					if opt_name == "Green" then
						adm_val.color_g = math.min(255, adm_val.color_g + step_int)
					end
					if opt_name == "Blue" then
						adm_val.color_b = math.min(255, adm_val.color_b + step_int)
					end
					if opt_name == "Health" then
						adm_val.health = math.min(8, adm_val.health + math.floor(step_dec * 10))
					end
					if opt_name == "Custom Amt" then
						adm_val.custom_amt = math.min(16, adm_val.custom_amt + 1)
					end
					if opt_name == "Custom Amt A" then
						adm_val.custom_amt_a = math.min(16, adm_val.custom_amt_a + 1)
					end

					local p_idx = part_to_idx[opt_name]
					if p_idx then
						adm_val.parts_toggles[p_idx] = not adm_val.parts_toggles[p_idx]
					end

					if string.match(opt_name, "Player %d+") then
						local id = tonumber(string.match(opt_name, "Player (%d+)"))
						adm_val.custom_players[id] = math.min(#p_t, adm_val.custom_players[id] + 1)
					end
					if string.match(opt_name, "Teleport %d+") then
						local id = tonumber(string.match(opt_name, "Teleport (%d+)"))
						adm_val.custom_players_a[id] = math.min(#p_t, adm_val.custom_players_a[id] + 1)
					end
				end
			end

			if (btn & A_BUTTON) ~= 0 then
				local target_name = all_t[adm_val.tgt]
				local c_names, c_names_a = {}, {}
				if target_name == "Choose Players..." then
					for i = 1, adm_val.custom_amt do
						table.insert(c_names, p_t[adm_val.custom_players[i]])
					end
				end
				if all_t[adm_val.tp_a] == "Choose Players..." then
					for i = 1, adm_val.custom_amt_a do
						table.insert(c_names_a, p_t[adm_val.custom_players_a[i]])
					end
				end

				local pkt = { req_id = "da", s = np0_name, t = target_name, c = table.concat(c_names, ",") }

				if
					opt_name == "ACTION"
					or opt_name == "DEFAULT"
					or opt_name == "APPLY MOD"
					or opt_name == "SET DEFAULT"
				then
					local p_mask = 0
					for idx = 1, 8 do
						if adm_val.parts_toggles[idx] then
							p_mask = p_mask | (1 << (idx - 1))
						end
					end

					if adm_tab == 1 and opt_name == "ACTION" then
						pkt.a = 8
						pkt.obj = adm_val.obj_idx
						pkt.amt = adm_val.amt
					elseif adm_tab == 2 and opt_name == "ACTION" then
						pkt.a = 1
						pkt.ta = all_t[adm_val.tp_a]
						pkt.tb = p_t[adm_val.tp_b]
						pkt.ca = table.concat(c_names_a, ",")
					elseif adm_tab == 3 and opt_name == "ACTION" then
						pkt.a = 2
						pkt.h = adm_val.health
					elseif adm_tab == 4 and opt_name == "APPLY MOD" then
						pkt.a = 7
						pkt.fr = adm_val.freeze
						pkt.ch = adm_val.chat
						pkt.k = adm_val.kill
						adm_val.kill = false
					elseif adm_tab == 5 and opt_name == "ACTION" then
						pkt.a = 3
						pkt.w = adm_val.pw_w1
						pkt.m = adm_val.pw_m
						pkt.v = adm_val.pw_v
						pkt.sh = adm_val.pw_sh
					elseif adm_tab == 6 then
						if opt_name == "SET DEFAULT" then
							adm_val.gravity = 100
							pkt.a = 4
							pkt.gr = 100
						elseif opt_name == "ACTION" then
							pkt.a = 4
							pkt.gr = adm_val.gravity
						end
					elseif adm_tab == 7 then
						pkt.a = (opt_name == "DEFAULT") and 6 or 5
						pkt.mk = p_mask
						pkt.pl = adm_val.palette_idx
						pkt.r = adm_val.color_r
						pkt.g = adm_val.color_g
						pkt.b = adm_val.color_b
					end
				else
					pkt = nil
				end

				if pkt then
					network_send(true, pkt)
					execute_admin_action(pkt)
				end
			end
		end
		if (btn & B_BUTTON) ~= 0 then
			close_menus(m)
		end
		return
	end
end

-- ==========================================
-- COMMAND HOOKS REGISTER
-- ==========================================
hook_chat_command("a", "[Message] Opens Title Editor", function(msg)
	if not (network_is_server() or network_is_moderator()) then
		return true
	end
	if editor_open then
		close_menus(gMarioStates[0])
	else
		msg_preview = (msg ~= "") and msg or "Text"
		editor_open = true
	end
	return true
end)

hook_chat_command("menu", "Opens admin menu (Your literally not admin??)", function(msg)
	if not (network_is_server() or network_is_moderator()) then
		return true
	end
	if admin_open then
		close_menus(gMarioStates[0])
	else
		admin_open = true
	end
	return true
end)

hook_event(HOOK_MARIO_UPDATE, on_mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
