local mod_name = "ChatBlock"
--[[
    Add Defend while in chat:
        When you are typing in the chat the charter will automaticly
        block every attack.
--]]
 
local oi = OptionsInjector
 
ChatBlock = {
	SETTINGS = {
		ACTIVE = "cb_chat_block",
		PUSH = "cb_chat_block_push",
	},

	SETTINGS = {
		ENABLED = {
			["save"] = "cb_chat_block_enabled",
			["widget_type"] = "stepper",
			["text"] = "No Input Auto-Block",
			["tooltip"] = "No Input Auto-Block\n" ..
				"Toggle no input auto-block on / off.\n\n" ..
				"Automatically block in chat box / ESC menu / when window is out of focus.\n" ..
				"Your block will still break if your stamina runs out.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_chat_block_push",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_chat_block_push",
					}
				},
			},
		},
		PUSH = {
			["save"] = "cb_chat_block_push",
			["widget_type"] = "stepper",
			["text"] = "Push on exit",
			["tooltip"] = "Push on exit\n" ..
				"Toggle push on exit on / off.\n\n" ..
				"When on, you will automatically push when exiting the chat.\n" ..
				"Will not happen if your stamina does not allow it.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
		},
		INTERACTION = {
			["save"] = "cb_chat_block_interaction",
			["widget_type"] = "stepper",
			["text"] = "Interaction Auto-Block",
			["tooltip"] = "Interaction Auto-Block\n" ..
				"Toggle interacton auto-block on / off.\n\n" ..
				"Automatically block when reviving / pulling teammate up\n" ..
				"from ledge / releasing teammate from hook.\n" .. 
				"Your block will still break if your stamina runs out.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
		},
	},
}
local me = ChatBlock
local states = {
    NOT_BLOCKING = 0,
    SHOULD_BLOCK = 1,
    BLOCKING = 2,
    SHOULD_PUSH = 3
}
me.state = states.NOT_BLOCKING
 
local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
ChatBlock.create_options = function()
	Mods.option_menu:add_group("chat_block", "Auto-Block")

	Mods.option_menu:add_item("chat_block", me.SETTINGS.ENABLED, true)
	Mods.option_menu:add_item("chat_block", me.SETTINGS.PUSH)
	Mods.option_menu:add_item("chat_block", me.SETTINGS.INTERACTION, true)
end
 
-- ####################################################################################################################
-- ##### Chat manager hook ############################################################################################
-- ####################################################################################################################

local in_option_menu = false
local is_input_blocked = false

--ESC Menu / window out-of-focus auto-block
-- VT2: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/6c69aa3488cf7259b6eae5e66f8100d7895df34b/scripts/unit_extensions/default_player_unit/player_input_extension.lua#L140

CutsceneSystem.is_active = function (self)
	return self.active_camera ~= nil
end

PlayerInputExtension.is_input_blocked = function (self)
	return (self.input_service:is_blocked() or ((PLATFORM == "win32") and not Window.has_focus())) and not (LevelHelper:current_level_settings().level_id == "inn_level") and not Managers.state.entity:system("cutscene_system"):is_active()
end

PlayerBotInput.is_input_blocked = function (self)
	return false
end

Mods.hook.set(mod_name, "PlayerInputExtension.get", function(func, self, input_key, consume)
	local value = self.input_service:get(input_key, consume)

	-- if not self.enabled or not PlayerInputExtension.get_window_is_in_focus() then
	if not self.enabled or self:is_input_blocked() then
		local value_type = type(value)

		if value_type == "userdata" then
			return Vector3.zero()
		end

		return nil
	end

	return value
end)

-- Weapon action update hook
-- And I'm not doing this fancy over the top unnessesary commenting thing, no way
 
Mods.hook.set(mod_name, "CharacterStateHelper.update_weapon_actions", function(func, t, unit, input_extension, inventory_extension, damage_extension)
 
    local player_unit = Managers.player:local_player().player_unit
    local status_extension = player_unit and ScriptUnit.has_extension(player_unit, "status_system") and ScriptUnit.extension(player_unit, "status_system")

    --Check if local player and not in inn
    if not get(me.SETTINGS.ENABLED) or (player_unit ~= unit or LevelHelper:current_level_settings().level_id == "inn_level" or (not status_extension) or (status_extension and status_extension.is_ready_for_assisted_respawn(status_extension))) or Managers.state.entity:system("cutscene_system"):is_active() then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end

--edit--
	if status_extension and not status_extension.is_blocking(status_extension) then
		me.state = states.NOT_BLOCKING
	end

	is_input_blocked = input_extension:is_input_blocked()
	
	if is_input_blocked and me.state == states.NOT_BLOCKING then             
		me.state = states.SHOULD_BLOCK
		-- EchoConsole(tostring(me.state))
	elseif not is_input_blocked and me.state == states.BLOCKING then
		if get(me.SETTINGS.PUSH) then
			me.state = states.SHOULD_PUSH
		else
			me.state = states.NOT_BLOCKING
		end
		-- EchoConsole(tostring(me.state))
	elseif not is_input_blocked and me.state ~= states.NOT_BLOCKING then
		me.state = states.NOT_BLOCKING
		-- EchoConsole(tostring(me.state))
	end
--edit--

    --Get data about weapon
    local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper._get_item_data_and_weapon_extensions(inventory_extension)
    local new_action, new_sub_action, current_action_settings, current_action_extension, current_action_hand = nil
    current_action_settings, current_action_extension, current_action_hand = CharacterStateHelper._get_current_action_data(left_hand_weapon_extension, right_hand_weapon_extension)
    if not(item_data) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
    local item_template = BackendUtils.get_item_template(item_data)
    if not(item_template) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
 
    --Check if weapon can block
    new_action = "action_two"
    new_sub_action = "default"
    local new_action_template = item_template.actions[new_action]
    local template = new_action_template and item_template.actions[new_action][new_sub_action]
    if not(template) or (not right_hand_weapon_extension and not left_hand_weapon_extension) or (template.kind ~= "block") then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
 
    --Block
    if (me.state == states.SHOULD_BLOCK) then
        me.state = states.BLOCKING
        if(left_hand_weapon_extension) then
            left_hand_weapon_extension.start_action(left_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)              
        end
        if(right_hand_weapon_extension) then
            right_hand_weapon_extension.start_action(right_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)
        end
        return
 
    --Push
    elseif(me.state == states.SHOULD_PUSH and not status_extension.fatigued(status_extension)) then
        new_action = "action_one"
        new_sub_action = "push"
--edit--
		local push_action = item_template.actions[new_action][new_sub_action]
        if push_action then
            if push_action.weapon_action_hand == "left" and left_hand_weapon_extension then
                left_hand_weapon_extension.start_action(left_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)              
            elseif right_hand_weapon_extension then
                right_hand_weapon_extension.start_action(right_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)
            end
        end
--edit--
 
        --Reset block state
        me.state = states.NOT_BLOCKING
    end
 
    --Continue blocking
    if not(me.state == states.BLOCKING) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
    end
end)

--Stuff for interaction auto-block

InteractionDefinitions.revive.config.activate_block = true
InteractionDefinitions.pull_up.config.activate_block = true
InteractionDefinitions.release_from_hook.config.activate_block = true
InteractionDefinitions.assisted_respawn.config.activate_block = true

Mods.hook.set(mod_name, "PlayerCharacterStateInteracting.on_enter", function(func, self, unit, input, dt, context, t, previous_state, params)
	func(self, unit, input, dt, context, t, previous_state, params)
	
	if get(me.SETTINGS.INTERACTION) and params.activate_block then
		self.activate_block = params.activate_block
		local status_extension = self.status_extension
		self.deactivate_block_on_exit = not status_extension:is_blocking()

		if not LEVEL_EDITOR_TEST and Managers.state.network:game() then
			local game_object_id = Managers.state.unit_storage:go_id(unit)

			if self.is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", game_object_id, true)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", game_object_id, true)
			end
		end

		status_extension:set_blocking(true)
	end
end)

Mods.hook.set(mod_name, "PlayerCharacterStateInteracting.on_exit", function(func, self, unit, input, dt, context, t, next_state)
	func(self, unit, input, dt, context, t, next_state)
	
	self.activate_block = nil
	
	local status_extension = self.status_extension

	if get(me.SETTINGS.INTERACTION) and self.deactivate_block_on_exit then
		if not LEVEL_EDITOR_TEST and Managers.state.network:game() then
			local game_object_id = Managers.state.unit_storage:go_id(unit)

			if self.is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", game_object_id, false)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", game_object_id, false)
			end
		end

		status_extension:set_blocking(false)
	end
end)

Mods.hook.set(mod_name, "PlayerCharacterStateInteracting.update", function(func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)
	
	local status_extension = self.status_extension
	
	if get(me.SETTINGS.INTERACTION) and self.activate_block then
		if not status_extension:is_blocking() and not LEVEL_EDITOR_TEST and Managers.state.network:game() then
			local game_object_id = Managers.state.unit_storage:go_id(unit)

			if self.is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", game_object_id, true)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", game_object_id, true)
			end
		end

		status_extension:set_blocking(true)
	end
end)

Mods.hook.set(mod_name, "PlayerCharacterStateUsingTransport.update", function(func, self, unit, input, dt, context, t)
	local csm = self.csm
	local unit = self.unit
	local input_extension = self.input_extension
	local status_extension = self.status_extension
	local inventory_extension = self.inventory_extension
	local first_person_extension = self.first_person_extension

	if CharacterStateHelper.do_common_state_transitions(status_extension, csm) then
		return
	end

	if not CharacterStateHelper.is_using_transport(status_extension) then
		csm:change_state("standing")

		return
	end

	local interactor_extension = self.interactor_extension

	if CharacterStateHelper.is_starting_interaction(input_extension, interactor_extension) then
		local config = interactor_extension:interaction_config()

		interactor_extension:start_interaction("interacting")

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
--edit--
			params.show_weapons = config.show_weapons
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	if CharacterStateHelper.is_interacting(interactor_extension) then
		local config = interactor_extension:interaction_config()

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
--edit--
			params.show_weapons = config.show_weapons
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	CharacterStateHelper.look(input_extension, self.player.viewport_name, self.first_person_extension, status_extension, self.inventory_extension)
	CharacterStateHelper.update_weapon_actions(t, unit, input_extension, inventory_extension, self.damage_extension)
	CharacterStateHelper.reload(input_extension, inventory_extension, status_extension)
end)

Mods.hook.set(mod_name, "PlayerCharacterStateJumping.update", function(func, self, unit, input, dt, context, t)
	local csm = self.csm
	local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)
	local input_extension = self.input_extension
	local status_extension = self.status_extension

	if CharacterStateHelper.do_common_state_transitions(status_extension, csm) then
		return
	end

	if CharacterStateHelper.is_overcharge_exploding(status_extension) then
		csm:change_state("overcharge_exploding")

		return
	end

	if CharacterStateHelper.is_pushed(status_extension) then
		status_extension:set_pushed(false)
		csm:change_state("stunned", movement_settings_table.stun_settings.pushed)

		return
	end

	if CharacterStateHelper.is_block_broken(status_extension) then
		status_extension:set_block_broken(false)
		csm:change_state("stunned", movement_settings_table.stun_settings.parry_broken)

		return
	end

	if CharacterStateHelper.is_colliding_down(unit) and Mover.flying_frames(Unit.mover(unit)) == 0 then
		csm:change_state("walking")

		return
	end

	if not csm.state_next and not self.locomotion_extension:is_colliding_down() then
		csm:change_state("falling", self.temp_params)

		return
	end

	local inventory_extension = self.inventory_extension
	local move_speed = math.clamp(movement_settings_table.move_speed, 0, PlayerUnitMovementSettings.move_speed)
	local move_speed_multiplier = status_extension:current_move_speed_multiplier()
	move_speed = move_speed * move_speed_multiplier
	move_speed = move_speed * movement_settings_table.player_speed_scale
	move_speed = move_speed * movement_settings_table.player_air_speed_scale

	CharacterStateHelper.move_in_air(self.first_person_extension, input_extension, self.locomotion_extension, move_speed, unit)
	CharacterStateHelper.look(input_extension, self.player.viewport_name, self.first_person_extension, status_extension, self.inventory_extension)
	CharacterStateHelper.update_weapon_actions(t, unit, input_extension, inventory_extension, self.damage_extension)
	CharacterStateHelper.reload(input_extension, inventory_extension, status_extension)

	local interactor_extension = self.interactor_extension

	if CharacterStateHelper.is_starting_interaction(input_extension, interactor_extension) then
		local config = interactor_extension:interaction_config()

		interactor_extension:start_interaction("interacting")

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
--edit--
			params.show_weapons = config.show_weapons
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	if CharacterStateHelper.is_interacting(interactor_extension) then
		local config = interactor_extension:interaction_config()

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
--edit--
			params.show_weapons = config.show_weapons
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end
end)

Mods.hook.set(mod_name, "PlayerCharacterStateStanding.update", function(func, self, unit, input, dt, context, t)
	local csm = self.csm
	local world = self.world
	local unit = self.unit
	local input_extension = self.input_extension
	local status_extension = self.status_extension
	local CharacterStateHelper = CharacterStateHelper

	ScriptUnit.extension(unit, "whereabouts_system"):set_is_onground()

	if CharacterStateHelper.do_common_state_transitions(status_extension, csm) then
		return
	end

	if CharacterStateHelper.is_waiting_for_assisted_respawn(status_extension) then
		csm:change_state("waiting_for_assisted_respawn")

		return
	end

	if CharacterStateHelper.is_using_transport(status_extension) then
		csm:change_state("using_transport")

		return
	end

	if CharacterStateHelper.is_ledge_hanging(world, unit, self.temp_params) then
		csm:change_state("ledge_hanging", self.temp_params)

		return
	end

	if CharacterStateHelper.is_overcharge_exploding(status_extension) then
		csm:change_state("overcharge_exploding")

		return
	end

	CharacterStateHelper.update_dodge_lock(unit, input_extension, status_extension)

	if CharacterStateHelper.is_pushed(status_extension) then
		status_extension:set_pushed(false)

		local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)

		csm:change_state("stunned", movement_settings_table.stun_settings.pushed)

		return
	end

	if CharacterStateHelper.is_block_broken(status_extension) then
		status_extension:set_block_broken(false)

		local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)

		csm:change_state("stunned", movement_settings_table.stun_settings.parry_broken)

		return
	end

	local start_dodge, dodge_direction = CharacterStateHelper.check_to_start_dodge(unit, input_extension, status_extension, t)

	if start_dodge then
		local params = self.temp_params
		params.dodge_direction = dodge_direction

		csm:change_state("dodging", params)

		return
	end

	if self.locomotion_extension:is_animation_driven() then
		csm:change_state("walking")

		return
	end

	local interactor_extension = self.interactor_extension

	if CharacterStateHelper.is_starting_interaction(input_extension, interactor_extension) then
		local config = interactor_extension:interaction_config()

		interactor_extension:start_interaction("interacting")

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
			params.show_weapons = config.show_weapons
--edit--
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	if CharacterStateHelper.is_interacting(interactor_extension) then
		local config = interactor_extension:interaction_config()

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
			params.show_weapons = config.show_weapons
--edit--
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	if input_extension:get("jump") and not status_extension:is_crouching() and self.locomotion_extension:jump_allowed() then
		csm:change_state("jumping")

		return
	end

	local is_moving = CharacterStateHelper.is_moving(input_extension)

	if is_moving then
		local params = self.temp_params

		csm:change_state("walking", params)

		return
	end

	if not self.locomotion_extension:is_colliding_down() then
		csm:change_state("falling")

		return
	end

	if input_extension:get("character_inspecting") then
		local _, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper._get_item_data_and_weapon_extensions(self.inventory_extension)
		local current_action_settings = CharacterStateHelper._get_current_action_data(left_hand_weapon_extension, right_hand_weapon_extension)

		if not current_action_settings then
			if Managers.input:is_device_active("gamepad") then
				if Managers.state.game_mode:level_key() == "inn_level" then
					csm:change_state("inspecting")

					return
				end
			else
				csm:change_state("inspecting")

				return
			end
		end
	end

	local inventory_extension = self.inventory_extension
	local first_person_extension = self.first_person_extension
	local toggle_crouch = input_extension.toggle_crouch

	if self.time_when_can_be_pushed < t and self.player:is_player_controlled() then
		self.current_animation = CharacterStateHelper.update_soft_collision_movement(first_person_extension, status_extension, self.locomotion_extension, unit, self.world, self.current_animation)
	end

	CharacterStateHelper.crouch(unit, input_extension, status_extension, toggle_crouch, first_person_extension, t)
	CharacterStateHelper.look(input_extension, self.player.viewport_name, self.first_person_extension, status_extension, self.inventory_extension)
	CharacterStateHelper.update_weapon_actions(t, unit, input_extension, inventory_extension, self.damage_extension)
	CharacterStateHelper.reload(input_extension, inventory_extension, status_extension)
end)

local fix = {
	"Double",
	"Triple",
	"Quad",
	"Penta",
	"Hexa",
	"Hepta",
	"Octa",
	"Nona",
	"Deca",
	"Hendeca",
	"Dodeca",
	"Trideca",
	"Tetradeca",
	"Pentadeca",
	"Hexadeca",
	"Heptadeca",
	"Octadeca",
	"Enneadeca",
	"Icosa"
}

local position_lookup = POSITION_LOOKUP

Mods.hook.set(mod_name, "PlayerCharacterStateFalling.update", function(func, self, unit, input, dt, context, t)
	local velocity = self.locomotion_extension:current_velocity()
	local self_pos = POSITION_LOOKUP[unit]
	local world = self.world

	if velocity.z > 0 then
		self.start_fall_height = position_lookup[unit].z
	end

	CharacterStateHelper.update_dodge_lock(unit, self.input_extension, self.status_extension)

	if position_lookup[unit].z < -240 then
		print("Player has fallen outside the world -- kill meeeee", position_lookup[unit].z)

		local go_id = self.unit_storage:go_id(unit)

		self.network_transmit:send_rpc_server("rpc_suicide", go_id)
	end

	local csm = self.csm
	local unit = self.unit
	local input_extension = self.input_extension
	local status_extension = self.status_extension

	if CharacterStateHelper.do_common_state_transitions(status_extension, csm) then
		return
	end

	if CharacterStateHelper.is_overcharge_exploding(status_extension) then
		csm:change_state("overcharge_exploding")

		return
	end

	local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)

	if CharacterStateHelper.is_pushed(status_extension) then
		status_extension:set_pushed(false)
		csm:change_state("stunned", movement_settings_table.stun_settings.pushed)

		return
	end

	if CharacterStateHelper.is_block_broken(status_extension) then
		status_extension:set_block_broken(false)
		csm:change_state("stunned", movement_settings_table.stun_settings.parry_broken)

		return
	end

	if not csm.state_next and CharacterStateHelper.is_colliding_down(unit) then
		if CharacterStateHelper.is_moving(input_extension) then
			csm:change_state("walking")
		else
			csm:change_state("standing")
		end

		return
	end

	local colliding_with_ladder, ladder_unit = CharacterStateHelper.is_colliding_with_gameplay_collision_box(world, unit, "filter_ladder_collision")
	local recently_left_ladder = CharacterStateHelper.recently_left_ladder(status_extension, t)

	if colliding_with_ladder and not recently_left_ladder and not self.ladder_shaking then
		local top_node = Unit.node(ladder_unit, "c_platform")
		local ladder_rot = Unit.local_rotation(ladder_unit, 0)
		local ladder_plane_inv_normal = Quaternion.forward(ladder_rot)
		local ladder_offset = Unit.local_position(ladder_unit, 0) - self_pos
		local distance = Vector3.dot(ladder_plane_inv_normal, ladder_offset)
		local epsilon = 0.02

		if self_pos.z < Vector3.z(Unit.world_position(ladder_unit, top_node)) and distance > 0 and distance < 0.7 + epsilon then
			local params = self.temp_params
			params.ladder_unit = ladder_unit

			csm:change_state("climbing_ladder", params)

			return
		end
	end

	if CharacterStateHelper.is_ledge_hanging(world, unit, self.temp_params) then
		csm:change_state("ledge_hanging", self.temp_params)

		return
	end

	if script_data.use_super_jumps and input_extension:get("jump") then
		self.times_jumped_in_air = math.min(#fix, self.times_jumped_in_air + 1)
		local text = string.format("%sjump!", fix[self.times_jumped_in_air])

		Debug.sticky_text(text)

		local jump_speed = movement_settings_table.jump.stationary_jump.initial_vertical_velocity
		local velocity_current = self.locomotion_extension:current_velocity()
		local velocity_jump = Vector3(velocity_current.x, velocity_current.y, (velocity_current.z < -3 and jump_speed * 0.5) or jump_speed * 1.5)

		self.locomotion_extension:set_forced_velocity(velocity_jump)
		self.locomotion_extension:set_wanted_velocity(velocity_jump)
	end

	local inventory_extension = self.inventory_extension
	local move_speed = movement_settings_table.move_speed
	local move_speed_multiplier = status_extension:current_move_speed_multiplier()
	move_speed = move_speed * move_speed_multiplier
	move_speed = move_speed * movement_settings_table.player_speed_scale
	move_speed = move_speed * movement_settings_table.player_air_speed_scale

	CharacterStateHelper.move_in_air(self.first_person_extension, input_extension, self.locomotion_extension, move_speed, unit)
	CharacterStateHelper.look(input_extension, self.player.viewport_name, self.first_person_extension, status_extension, self.inventory_extension)
	CharacterStateHelper.update_weapon_actions(t, unit, input_extension, inventory_extension, self.damage_extension)
	CharacterStateHelper.reload(input_extension, inventory_extension, status_extension)

	local interactor_extension = self.interactor_extension

	if CharacterStateHelper.is_starting_interaction(input_extension, interactor_extension) then
		local config = interactor_extension:interaction_config()

		interactor_extension:start_interaction("interacting")

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
--edit--
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	if CharacterStateHelper.is_interacting(interactor_extension) then
		local config = interactor_extension:interaction_config()

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
--edit--
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end
end)

Mods.hook.set(mod_name, "PlayerCharacterStateWalking.update", function(func, self, unit, input, dt, context, t)
	local csm = self.csm
	local world = self.world
	local unit = self.unit
	local movement_settings_table = PlayerUnitMovementSettings.get_movement_settings_table(unit)
	local input_extension = self.input_extension
	local status_extension = self.status_extension
	local first_person_extension = self.first_person_extension

	ScriptUnit.extension(unit, "whereabouts_system"):set_is_onground()

	if CharacterStateHelper.do_common_state_transitions(status_extension, csm) then
		return
	end

	if CharacterStateHelper.is_ledge_hanging(world, unit, self.temp_params) then
		csm:change_state("ledge_hanging", self.temp_params)

		return
	end

	if CharacterStateHelper.is_overcharge_exploding(status_extension) then
		csm:change_state("overcharge_exploding")

		return
	end

	if CharacterStateHelper.is_using_transport(status_extension) then
		csm:change_state("using_transport")

		return
	end

	if CharacterStateHelper.is_pushed(status_extension) then
		status_extension:set_pushed(false)
		csm:change_state("stunned", movement_settings_table.stun_settings.pushed)

		return
	end

	if CharacterStateHelper.is_block_broken(status_extension) then
		status_extension:set_block_broken(false)
		csm:change_state("stunned", movement_settings_table.stun_settings.parry_broken)

		return
	end

	if self.locomotion_extension:is_animation_driven() then
		return
	end

	CharacterStateHelper.update_dodge_lock(unit, self.input_extension, self.status_extension)

	local start_dodge, dodge_direction = CharacterStateHelper.check_to_start_dodge(unit, input_extension, status_extension, t)

	if start_dodge then
		local params = self.temp_params
		params.dodge_direction = dodge_direction

		csm:change_state("dodging", params)

		return
	end

	local gamepad_active = Managers.input:is_device_active("gamepad")

	if not csm.state_next and input_extension:get("jump") and not status_extension:is_crouching() and self.locomotion_extension:jump_allowed() then
		local movement_input = CharacterStateHelper.get_movement_input(input_extension)

		if (not input_extension.dodge_on_jump_key and not gamepad_active) or status_extension:can_override_dodge_with_jump(t) or Vector3.y(movement_input) >= 0 or Vector3.length(movement_input) <= input_extension.minimum_dodge_input then
			if Vector3.y(CharacterStateHelper.get_movement_input(input_extension)) < 0 then
				self.temp_params.backward_jump = true
			else
				self.temp_params.backward_jump = false
			end

			csm:change_state("jumping", self.temp_params)

			return
		end
	end

	local is_moving = CharacterStateHelper.is_moving(input_extension)

	if not self.csm.state_next and not is_moving and self.movement_speed == 0 then
		local params = self.temp_params

		csm:change_state("standing", params)

		return
	end

	if not self.csm.state_next and not self.locomotion_extension:is_colliding_down() then
		csm:change_state("falling", self.temp_params)

		return
	end

	local colliding_with_ladder, ladder_unit = CharacterStateHelper.is_colliding_with_gameplay_collision_box(self.world, unit, "filter_ladder_collision")
	local looking_up = CharacterStateHelper.looking_up(first_person_extension, movement_settings_table.ladder.looking_up_threshold)
	local recently_left_ladder = CharacterStateHelper.recently_left_ladder(status_extension, t)
	local above_align_cube = false

	if colliding_with_ladder then
		local ladder_rot = Unit.local_rotation(ladder_unit, 0)
		local ladder_plane_inv_normal = Quaternion.forward(ladder_rot)
		local ladder_offset = Unit.local_position(ladder_unit, 0) - POSITION_LOOKUP[unit]
		local distance = Vector3.dot(ladder_plane_inv_normal, ladder_offset)
		local facing_correctly = false
		local close_enough = false
		local ladder_forward = Quaternion.forward(Unit.local_rotation(ladder_unit, 0))
		local facing = Quaternion.forward(first_person_extension:current_rotation())
		local facing_ladder = Vector3.dot(facing, ladder_forward) < 0
		local movement_in_ladder_direction = Vector3.dot(self.locomotion_extension.velocity_current:unbox(), ladder_forward)
		local top_node = Unit.node(ladder_unit, "c_platform")

		if Vector3.z(Unit.world_position(ladder_unit, top_node)) < POSITION_LOOKUP[unit].z then
			local player = Managers.player:owner(unit)
			local is_bot = player and player.bot_player
			local threshold = (is_bot and movement_settings_table.ladder.bot_looking_down_threshold) or movement_settings_table.ladder.looking_down_threshold
			local looking_down = not looking_up

			if looking_down and facing_ladder and movement_in_ladder_direction < 0 then
				close_enough = distance > 0.5
				facing_correctly = true
			elseif looking_down and distance > 0 and not facing_ladder and movement_in_ladder_direction > 0.5 then
				close_enough = distance > 0.25
				facing_correctly = true
			end

			above_align_cube = true
		else
			local epsilon = 0.02
			close_enough = distance < 0.7 + epsilon and distance > 0
			facing_correctly = looking_up and not facing_ladder and movement_in_ladder_direction > 0
		end

		if facing_correctly and not recently_left_ladder and close_enough then
			local params = self.temp_params
			params.ladder_unit = ladder_unit

			if above_align_cube then
				csm:change_state("enter_ladder_top", params)

				return
			else
				csm:change_state("climbing_ladder", params)

				return
			end
		end
	end

	local inventory_extension = self.inventory_extension
	local toggle_crouch = input_extension.toggle_crouch

	CharacterStateHelper.crouch(unit, input_extension, status_extension, toggle_crouch, first_person_extension, t)

	local player = Managers.player:owner(unit)
	local move_input = CharacterStateHelper.get_movement_input(input_extension)

	if is_moving then
		self.movement_speed = math.min(Vector3.length(move_input), self.movement_speed + movement_settings_table.move_acceleration_up * dt)
	elseif player and player.bot_player then
		self.movement_speed = 0
	else
		self.movement_speed = math.max(0, self.movement_speed - movement_settings_table.move_acceleration_down * dt)
	end

	local walking = input_extension:get("walk")
	local max_move_speed = (status_extension:is_crouching() and movement_settings_table.crouch_move_speed) or (walking and movement_settings_table.walk_move_speed) or movement_settings_table.move_speed
	local move_speed_multiplier = status_extension:current_move_speed_multiplier()

	if walking ~= self.walking then
		status_extension:set_slowed(walking)
	end

	local move_speed = max_move_speed * move_speed_multiplier * movement_settings_table.player_speed_scale * self.movement_speed

	if script_data.debug_player_movementspeed then
		Debug.text("Movement Speed: " .. move_speed)
	end

	local move_input_direction = Vector3.normalize(move_input)

	if Vector3.length(move_input_direction) == 0 then
		move_input_direction = self.last_input_direction:unbox()
	else
		self.last_input_direction:store(move_input_direction)
	end

	local interactor_extension = self.interactor_extension

	if CharacterStateHelper.is_starting_interaction(input_extension, interactor_extension) then
		local config = interactor_extension:interaction_config()

		interactor_extension:start_interaction("interacting")

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
			params.show_weapons = config.show_weapons
--edit--
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	CharacterStateHelper.move_on_ground(first_person_extension, input_extension, self.locomotion_extension, move_input_direction, move_speed, unit)
	CharacterStateHelper.look(input_extension, self.player.viewport_name, first_person_extension, status_extension, self.inventory_extension)
	CharacterStateHelper.update_weapon_actions(t, unit, input_extension, inventory_extension, self.damage_extension)
	CharacterStateHelper.reload(input_extension, inventory_extension, status_extension)

	if CharacterStateHelper.is_interacting(interactor_extension) then
		local config = interactor_extension:interaction_config()

		if not config.allow_movement then
			local params = self.temp_params
			params.swap_to_3p = config.swap_to_3p
			params.show_weapons = config.show_weapons
--edit--
			params.activate_block = config.activate_block
--edit--

			csm:change_state("interacting", params)
		end

		return
	end

	local move_anim_3p, move_anim_1p = CharacterStateHelper.get_move_animation(self.locomotion_extension, input_extension, status_extension)

	if move_anim_3p ~= self.move_anim_3p or move_anim_1p ~= self.move_anim_1p then
		CharacterStateHelper.play_animation_event(unit, move_anim_3p)
		CharacterStateHelper.play_animation_event_first_person(first_person_extension, move_anim_1p)

		self.move_anim_3p = move_anim_3p
		self.move_anim_1p = move_anim_1p
	end

	self.walking = walking
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
me.create_options()