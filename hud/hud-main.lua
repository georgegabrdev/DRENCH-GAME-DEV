local M = {}

if unsupported then
	return
end

---------------
--- REQUIRE ---
---------------
local hud_playerlist = require("hud-playerlist")
local hud_popups = require("hud-popups")

------------
--- FUNC ---
------------

local render_playerlist = hud_playerlist.render_playerlist
local render_warning_popups = hud_popups.render_warning_popups

---------------
--- WRAPPER ---
---------------

local function on_hud_render()
	render_playerlist()
	render_warning_popups()
end

-------------
--- HOOKS ---
-------------

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

return M
