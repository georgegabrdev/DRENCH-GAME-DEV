local M = {}

if unsupported then
	return
end

---------------
--- REQUIRE ---
---------------
local hud_playerlist = require("hud-playerlist")

------------
--- FUNC ---
------------

local render_playerlist = hud_playerlist.render_playerlist

---------------
--- WRAPPER ---
---------------

local function on_hud_render()
	render_playerlist()
end

-------------
--- HOOKS ---
-------------

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

return M
