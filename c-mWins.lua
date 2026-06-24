-- b-wins.lua

if unsupported then
	return
end

local MWI = {}

gPlayerSyncTable[0].minigameWins = 0

local SECRET = 0x2A4B6C8D
local CHECK = 0x7F1E3D5A
local FILE = "mwins.bin"

local function save_m_wins()
	local modFs = mod_fs_get() or mod_fs_create()
	local file = modFs:get_file(FILE) or modFs:create_file(FILE, false)

	file:erase(file.size)
	file:rewind()

	local wins = gPlayerSyncTable[0].minigameWins

	local obfuscated = wins ~ SECRET
	local checksum = (wins + CHECK) ~ SECRET

	file:write_integer(obfuscated, INT_TYPE_S32)
	file:write_integer(checksum, INT_TYPE_S32)

	modFs:save()
end

function MWI.load_m_wins()
	local modFs = mod_fs_get() or mod_fs_create()
	local file = modFs:get_file(FILE) or modFs:create_file(FILE, false)

	file:rewind()

	if not file:is_eof() then
		local val1 = file:read_integer(INT_TYPE_S32)
		local val2 = nil

		if not file:is_eof() then
			val2 = file:read_integer(INT_TYPE_S32)
		end

		if val2 == nil then
			gPlayerSyncTable[0].minigameWins = val1
			save_m_wins()
		else
			local wins = val1 ~ SECRET
			local expectedChecksum = ((wins + CHECK) % 0x7FFFFFFF) ~ SECRET

			if val2 == expectedChecksum then
				gPlayerSyncTable[0].minigameWins = wins
				print("Loaded wins:", gPlayerSyncTable[0].minigameWins)
			else
				gPlayerSyncTable[0].minigameWins = 0
				save_m_wins()
			end
		end
	else
		gPlayerSyncTable[0].minigameWins = 0
	end
end

function MWI.add_m_win()
	gPlayerSyncTable[0].minigameWins = (gPlayerSyncTable[0].minigameWins or 0) + 1
	print("Added win, total wins:", gPlayerSyncTable[0].minigameWins)

	save_m_wins()
end

function MWI.reset_m_wins()
	gPlayerSyncTable[0].minigameWins = 0
	save_m_wins()
end

return MWI
