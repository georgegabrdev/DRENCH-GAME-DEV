--Nuclear Bomb

function bomb_init(o)
	o.oFlags = OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
	o.header.gfx.skipInViewCheck = true
end

function bomb_loop(o)
	local m = gMarioStates[0]
	if o.oTimer == 1 then
		play_stream_sfx("nuclearbomb", m.pos, 1)
		seq_player_fade_out(0, 60)
	end
	if o.oTimer == 85 then
		play_transition(WARP_TRANSITION_FADE_FROM_COLOR, 10, 255, 0, 0)
		set_override_skybox(BACKGROUND_FLAMING_SKY)
		set_lighting_color(0, 255)
		set_lighting_color(1, 150)
		set_lighting_color(2, 150)
		set_lighting_dir(1, -128)
		set_vertex_color(0, 255)
		set_vertex_color(1, 150)
		set_vertex_color(2, 150)
		set_fog_color(0, 255)
		set_fog_color(1, 150)
		set_fog_color(2, 150)
		nuke = true
	end
	if o.oTimer > 85 and o.oTimer < 190 then
		cur_obj_shake_screen(SHAKE_POS_LARGE)
		set_camera_shake_from_hit(SHAKE_POS_LARGE)
	end
	if o.oTimer == 190 then
		local behaviorsToDestroy = {
			id_bhvThwomp,
			id_bhvThwomp2,
			id_bhvWhompKingBoss,
			id_bhvWhompKingBoss,
			id_bhvWaterBombCannon,
			id_bhvTree,
			id_bhvWoodenPost,
			id_bhvPlatformOnTrack,
			id_bhvBowlingBall,
			id_bhvBobBowlingBallSpawner,
			id_bhvPitBowlingBall,
			id_bhvMessagePanel,
			id_bhvGoomba,
			id_bhvBobomb,
			id_bhvBobombBuddy,
			id_bhvBobombBuddyOpensCannon,
			id_bhvChainChomp,
			id_bhvKingBobomb,
			id_bhvKoopa,
			id_bhvSpindrift,
			id_bhvPenguinBaby,
			id_bhvSmallPenguin,
			id_bhvBird,
			id_bhvButterfly,
			id_bhvTripletButterfly,
		}

		for _, behavior in ipairs(behaviorsToDestroy) do
			local objectToDestroy = obj_get_first_with_behavior_id(behavior)
			while objectToDestroy ~= nil do
				spawn_non_sync_object(
					id_bhvExplosion,
					E_MODEL_EXPLOSION,
					objectToDestroy.oPosX,
					objectToDestroy.oPosY + 100,
					objectToDestroy.oPosZ,
					function(exp)
						obj_scale(exp, 10)
					end
				)
				spawn_non_sync_object(
					id_bhvFlame,
					E_MODEL_RED_FLAME,
					objectToDestroy.oPosX,
					objectToDestroy.oPosY,
					objectToDestroy.oPosZ,
					function(flame)
						obj_scale(flame, math.random(1, 3))
					end
				)
				obj_mark_for_deletion(objectToDestroy)
				objectToDestroy = obj_get_next_with_same_behavior_id(objectToDestroy)
			end
		end

		play_stream_sfx("explosion", m.pos, 1)
		cur_obj_shake_screen(SHAKE_POS_LARGE)
		spawn_non_sync_object(
			id_bhvBowserBombExplosion,
			E_MODEL_BOWSER_FLAMES,
			o.oPosX,
			o.oPosY,
			o.oPosZ,
			function(explosion)
				obj_scale(explosion, 2)
			end
		)
		play_character_sound(m, CHAR_SOUND_ATTACKED)
		m.pos.y = m.pos.y + 4
		m.vel.y = 400
		set_mario_action(m, ACT_RAGDOLL, 0)
		m.health = m.health - 1800
	end
	if o.oTimer == 260 then
		play_music(0, SEQ_LEVEL_HOT, 0)
		obj_mark_for_deletion(o)
	end
end

id_bhvNuclearBomb = hook_behavior(nil, OBJ_LIST_GENACTOR, false, bomb_init, bomb_loop)
