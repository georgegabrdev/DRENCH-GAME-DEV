-- spectate action
ACT_SPECTATE = ACT_BUBBLED -- replace bubbled action so it doesn't do syncing
ACT_FREECAM = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_INVULNERABLE)
ACT_GHOST = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_INVULNERABLE)

spectatedPlayer = 0
local lastDir = 0
local lastDirTime = 0

sPlayerFirstPerson = {
	pos = { x = 0, y = 0, z = 0 },
	freecam = camera_config_is_free_cam_enabled(),
	pitch = 0,
	yaw = 0,
	fov = 70,
	currentFov = 45,
	dist = 1000,
}

local function update_fp_camera(m)
	gLakituState.mode = CAMERA_MODE_FREE_ROAM
	gLakituState.defMode = CAMERA_MODE_FREE_ROAM

	if not _G.is_game_paused() then
		local sensX = 0.3 * camera_config_get_x_sensitivity()
		local sensY = 0.3 * camera_config_get_y_sensitivity()

		local baseInvX = if_then_else(camera_config_is_x_inverted(), 1, -1)
		local baseInvY = if_then_else(camera_config_is_y_inverted(), 1, -1)

		local specInvX = -1 or 1
		local specInvY = -1 or 1

		local inputY = (baseInvY * m.controller.extStickY - 1.5 * djui_hud_get_raw_mouse_y()) * specInvY
		local inputX = (baseInvX * m.controller.extStickX - 1.5 * djui_hud_get_raw_mouse_x()) * specInvX

		sPlayerFirstPerson.pitch = math.clamp(sPlayerFirstPerson.pitch - sensY * inputY, -0x3F00, 0x3F00)

		if (m.controller.buttonPressed & L_TRIG) ~= 0 then
			sPlayerFirstPerson.yaw = m.faceAngle.y + 0x8000
		else
			sPlayerFirstPerson.yaw = (sPlayerFirstPerson.yaw + sensX * inputX + 0x10000) % 0x10000
		end

		local camYaw = sPlayerFirstPerson.yaw + 0x8000
		local forward = { x = sins(camYaw), y = 0, z = coss(camYaw) }
		local right = { x = sins(camYaw - 0x4000), y = 0, z = coss(camYaw - 0x4000) }

		local stickY, stickX = m.controller.stickY, m.controller.stickX
		local dir = { x = forward.x * stickY + right.x * stickX, y = 0, z = forward.z * stickY + right.z * stickX }

		local speed = if_then_else((m.controller.buttonDown & B_BUTTON) ~= 0, 2, 1)
		dir = vec3f_mul(dir, speed)

		sPlayerFirstPerson.pos.x = sPlayerFirstPerson.pos.x + dir.x
		sPlayerFirstPerson.pos.z = sPlayerFirstPerson.pos.z + dir.z

		if (m.input & INPUT_A_DOWN) ~= 0 then
			sPlayerFirstPerson.pos.y = sPlayerFirstPerson.pos.y + (50 * speed)
		end
		if (m.input & INPUT_Z_DOWN) ~= 0 then
			sPlayerFirstPerson.pos.y = sPlayerFirstPerson.pos.y - (50 * speed)
		end
	end

	gLakituState.yaw = sPlayerFirstPerson.yaw
	m.area.camera.yaw = sPlayerFirstPerson.yaw

	local pitch, yaw = sPlayerFirstPerson.pitch, sPlayerFirstPerson.yaw
	local pos = sPlayerFirstPerson.pos
	local xOff = coss(pitch) * sins(yaw)
	local yOff = sins(pitch)
	local zOff = coss(pitch) * coss(yaw)

	gLakituState.pos.x = pos.x + xOff
	gLakituState.pos.y = pos.y + yOff
	gLakituState.pos.z = pos.z + zOff
	gLakituState.focus.x = pos.x - 100 * xOff
	gLakituState.focus.y = pos.y - 100 * yOff
	gLakituState.focus.z = pos.z - 100 * zOff

	vec3f_copy(m.area.camera.pos, gLakituState.pos)
	vec3f_copy(gLakituState.curPos, gLakituState.pos)
	vec3f_copy(gLakituState.goalPos, gLakituState.pos)
	vec3f_copy(m.area.camera.focus, gLakituState.focus)
	vec3f_copy(gLakituState.curFocus, gLakituState.focus)
	vec3f_copy(gLakituState.goalFocus, gLakituState.focus)

	sPlayerFirstPerson.currentFov = approach_f32_asymptotic(sPlayerFirstPerson.currentFov, sPlayerFirstPerson.fov, 0.15)
	set_override_fov(sPlayerFirstPerson.currentFov)

	gLakituState.posHSpeed, gLakituState.posVSpeed = 0, 0
	gLakituState.focHSpeed, gLakituState.focVSpeed = 0, 0
end

function act_ghost(m)
	m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE

	m.health = 0x880

	m.marioObj.oIntangibleTimer = -1
	m.marioObj.oInteractType = 0

	if m.playerIndex ~= 0 then
		return
	end

	-- X returns to spectate
	if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
		set_mario_action(m, ACT_FREECAM, 0)

		m.flags = m.flags & ~MARIO_VANISH_CAP

		return
	end

	local speed = ((m.controller.buttonDown & B_BUTTON) ~= 0) and 200 or 100

	if m.intendedMag > 0 then
		m.vel.x = (m.intendedMag / 32) * speed * sins(m.intendedYaw)
		m.vel.z = (m.intendedMag / 32) * speed * coss(m.intendedYaw)
		m.faceAngle.y = m.intendedYaw
	else
		m.vel.x = 0
		m.vel.z = 0
	end

	m.vel.y = 0

	if (m.controller.buttonDown & A_BUTTON) ~= 0 then
		m.vel.y = speed * 0.6
	end

	if (m.controller.buttonDown & Z_TRIG) ~= 0 then
		m.vel.y = -speed * 0.6
	end

	perform_air_step(m, 0)

	m.forwardVel = math.sqrt(m.vel.x * m.vel.x + m.vel.z * m.vel.z)

	vec3s_set(m.marioObj.header.gfx.angle, m.faceAngle.x, m.faceAngle.y, m.faceAngle.z)
end

function act_freecam(m)
	m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE

	m.health = 0x880

	if m.playerIndex ~= 0 then
		return
	end

	-- press X to return to spectating
	if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
		set_mario_action(m, ACT_SPECTATE, 0)

		camera_unfreeze()
		set_override_near(0)
		set_override_fov(0)

		return
	end

	update_fp_camera(m)
	camera_freeze()
end

function act_spectate(m)
	m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
	m.health = 0x880
	sonic_set_full_rings(m.playerIndex)
	if m.actionTimer < 15 then
		m.actionTimer = m.actionTimer + 1
	end

	if m.playerIndex ~= 0 then
		m.pos.x, m.pos.y, m.pos.z = 0, -10000, 0
		return
	end

	local sMario = gPlayerSyncTable[0]
	if not (sMario.spectator or sMario.eliminated or sMario.victory) then
		set_to_spawn_pos(m, true)
		return
	end

	if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
		set_mario_action(m, ACT_GHOST, 0)

		m.flags = m.flags | MARIO_VANISH_CAP

		m.vel.x = 0
		m.vel.y = 0
		m.vel.z = 0

		return
	end

	-- allow switching; auto switch if our player is invalid
	local specM = gMarioStates[spectatedPlayer]
	local change = 0
	if spectatedPlayer == 0 or is_player_active(specM) == 0 then
		change = 1
		lastDirTime = 15
		m.actionTimer = 15
	elseif m.controller.buttonPressed & L_JPAD ~= 0 or m.controller.stickX < -32 then
		change = -1
	elseif m.controller.buttonPressed & R_JPAD ~= 0 or m.controller.stickX > 32 then
		change = 1
	end
	if m.actionTimer < 15 or (lastDir == change and lastDirTime < 15) then
		change = 0
	else
		lastDir = change
		lastDirTime = 0
	end
	lastDirTime = lastDirTime + 1

	if change ~= 0 then
		-- get first spectatable player after change
		local limit = 0
		while limit < MAX_PLAYERS do
			spectatedPlayer = (spectatedPlayer + change) % MAX_PLAYERS
			limit = limit + 1
			specM = gMarioStates[spectatedPlayer]
			if spectatedPlayer ~= 0 and is_player_active(specM) ~= 0 then
				break
			elseif limit >= MAX_PLAYERS then
				return
			end
		end
	end

	-- go to this player's position
	m.pos.x = specM.pos.x
	m.pos.y = specM.pos.y
	m.pos.z = specM.pos.z
end

hook_mario_action(ACT_SPECTATE, act_spectate)

hook_mario_action(ACT_FREECAM, act_freecam)

hook_mario_action(ACT_GHOST, act_ghost)
