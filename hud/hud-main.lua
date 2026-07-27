local M = {}

---------------
--- REQUIRE ---
---------------
local hud_playerlist = require("hud-playerlist")
local hud_popups = require("hud-popups")
local hud_main_hud = require("hud-main_hud")

------------
--- FUNC ---
------------

local render_playerlist = hud_playerlist.render_playerlist
local render_warning_popups = hud_popups.render_warning_popups
local render_main_hud = hud_main_hud.render_main_hud

---------------
--- WRAPPER ---
---------------

local function on_hud_render()
	render_playerlist()
	render_warning_popups()
	render_main_hud()
end

-------------
--- HOOKS ---
-------------

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

return M
