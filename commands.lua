local WI = require("./b-wins")
local MWI = require("./c-mWins")

function on_chat_message(msg)
	WI.reset_wins()
	MWI.reset_m_wins()
end

hook_chat_command("reset_wins", "Resets your wins and minigame wins. (DONT DO THIS)", on_chat_message)

function on_chat_message_again(msg)
	local m = gMarioStates[0]
	if not network_is_server() and not network_is_moderator() then
		djui_chat_message_create(
			"\\#ff5050\\You have permission to perform this command... or DO you?\n(No, you don't have moderator)"
		)
		return
	end
	create_warning_popup("!!! NUCLEAR LAUNCH DETECTED !!!")
	spawn_sync_object(id_bhvNuclearBomb, E_MODEL_NONE, m.pos.x, m.pos.y, m.pos.z, nil)
end

hook_chat_command("nuclearbomb", "No.", on_chat_message_again)
