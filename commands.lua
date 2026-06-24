local WI = require("./b-wins")
local MWI = require("./c-mWins")

function on_chat_message(msg)
	WI.reset_wins()
	MWI.reset_m_wins()
end

hook_chat_command("reset_wins", "Resets your wins and minigame wins. (DONT DO THIS)", on_chat_message)
