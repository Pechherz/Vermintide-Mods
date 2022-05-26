local mod = get_mod("Console")
mod:dofile("scripts/mods/Console/Console_commands") --Read a list of console commands.
mod.ConsoleVisible = false --Main flag whether console is on or off.
mod.DeltaTime = 0 --Required for latency command.
mod.Binds = Application.user_setting("ConsoleBinds") or {} --Handle bindings.
local Input = "" --Actual input string.
local LastInput = "" --Input before entering new key to rematch current string with list of commands for autocomplete.
local Index = 1 --Required for keystroke helper.
local MaxChars = 512 --Just in case.
local InputMode = "insert" --Required for keystroke helper.
local Hint = "Use list command to show all available commands. (" .. tostring(mod.CommandsCount()) .. " commands indexed)" --Default autocomplete string.
local AutoFillCommand = "" --Actual command to input via autocomplete when pressing tab.
local onetimebool = false --Flag for to do on first tick when console has been enabled/disabled.
local CommandHistory = {} --History to cycle through with arrow up/down.
local SelectedHistoryIndex = 1 --Required for above.
local Photomode = get_mod("Photomode") --Some compatibility stuff.
local WorldHandle = nil
local GuiHandle = nil
local special_characters = {
	[8] = "backspace",
	[9] = "tab",
	[13] = "enter",
	[20] = "caps lock",
	[32] = "space",
	[11] = "page up",
	[12] = "page down",
	[7] = "end",
	[6] = "home",
	[37] = "left",
	[38] = "up",
	[39] = "right",
	[40] = "down",
	[5] = "insert",
	[26] = "delete",
	[91] = "win",
	[92] = "right win",
	[96] = "numpad 0",
	[97] = "numpad 1",
	[98] = "numpad 2",
	[99] = "numpad 3",
	[100] = "numpad 4",
	[101] = "numpad 5",
	[102] = "numpad 6",
	[103] = "numpad 7",
	[104] = "numpad 8",
	[105] = "numpad 9",
	[106] = "numpad *",
	[107] = "numpad +",
	[109] = "numpad -",
	[110] = "numpad .",
	[111] = "numpad /",
	[14] = "f1",
	[15] = "f2",
	[16] = "f3",
	[17] = "f4",
	[18] = "f5",
	[19] = "f6",
	[20] = "f7",
	[21] = "f8",
	[22] = "f9",
	[23] = "f10",
	[24] = "f11",
	[25] = "f12",
	[144] = "num lock",
	[145] = "scroll lock",
	[166] = "browser back",
	[167] = "browser forward",
	[168] = "browser refresh",
	[169] = "browser stop",
	[170] = "browser search",
	[171] = "browser favorites",
	[172] = "browser home",
	[173] = "volume mute",
	[174] = "volume down",
	[175] = "volume up",
	[176] = "next track",
	[177] = "previous track",
	[178] = "stop",
	[179] = "play pause",
	[180] = "mail",
	[181] = "media",
	[182] = "start app 1",
	[183] = "start app 2",
	[256] = "numpad enter"
} --Helper for retarded keystroke design.

--[[
	Functions
--]]
local function ischeat(input) --If flag is cheat then output it to hint.
	if input == true then return "{CHEAT}" else return "" end
end

local function inphotomode() --Needed to restrict input upon exiting console back to free flight input only.
	Photomode = get_mod("Photomode")
	if Photomode ~= nil then
		return Photomode.SessionEnabled
	else
		return false
	end
end

DebugTextManager.output_screen_text_console_console = function (self, text, text_size, time, color) --Custom version.
	if script_data and script_data.disable_debug_draw then
		return
	end

	text_size = text_size or self._screen_text_console_size
	color = color or Vector3(255, 255, 255)
	local gui = GuiHandle--self._gui
	local resolution = Vector2(RESOLUTION_LOOKUP.res_w, RESOLUTION_LOOKUP.res_h)
	local material = "gw_arial_16"
	local font = "materials/fonts/" .. material
	local text_extent_min, text_extent_max = Gui.text_extents(gui, text, font, text_size)
	local text_w = text_extent_max[1] - text_extent_min[1]
	local text_h = text_extent_max[3] - text_extent_min[3]
	local text_position = Vector3(0 + text_size - 2, resolution.y - text_size - 10, UILayer.debug_screen + 1)	
	local bgr_margin = 10
	local bgr_x = text_position.x - bgr_margin
	local bgr_y = text_position.y - bgr_margin
	local bgr_w = resolution.x
	local bgr_h = text_h + bgr_margin * 2
	local bgr_position = Vector3(bgr_x, bgr_y, UILayer.debug_screen)
	local bgr_size = Vector2(bgr_w, bgr_h)

	if self._screen_text_console then
		Gui.update_text(gui, self._screen_text_console.text_id, text, font, text_size, material, text_position, Color(color.x, color.y, color.z))
		Gui.update_rect(gui, self._screen_text_console.bgr_id, bgr_position, bgr_size, Color(200, 0, 0, 0))

		self._screen_text_console.time = self._time + (time or self._screen_text_console_time)
	else
		local screen_text = {
			text_id = Gui.text(gui, text, font, text_size, material, text_position, Color(color.x, color.y, color.z)),
			bgr_id = Gui.rect(gui, bgr_position, bgr_size, Color(200, 0, 0, 0)),
			time = self._time + (time or self._screen_text_time)
		}
		self._screen_text_console = screen_text
	end
end

KeystrokeHelper[Keyboard.TAB] = nil --Might be a bad idea but come on, what uses tab.

--[[
	Callbacks
--]]

mod.update = function(dt)
	mod.DeltaTime = dt
	if mod:is_enabled() and Managers.state.debug_text ~= nil then
	local keystrokes = Keyboard.keystrokes()
		if WorldHandle == nil or WorldHandle ~= Application.main_world() then
			WorldHandle = Application.main_world()
			GuiHandle = World.create_screen_gui(WorldHandle, "material", "materials/fonts/gw_fonts", "immediate")
		end
		
		if Keyboard.pressed(Keyboard.button_id("oem_3 (~ `)")) and WorldHandle ~= nil and GuiHandle ~= nil then
			mod.ConsoleVisible = not mod.ConsoleVisible
			
			local input_manager = Managers.player:local_player().network_manager.matchmaking_manager._ingame_ui.input_manager
			if mod.ConsoleVisible then
				if not onetimebool then --Block keyboard, disable chat/rcon gui.
					local block_reasons = {
					keybind = true,
					irc_chat = true,
					debug_screen = true,
					rcon = true,
					twitch = true,
					popup = true,
					free_flight = true,
					channels_list = true,
					}
					input_manager:create_input_service("console_input", "RconControllerSettings", "RconControllerFilters", block_reasons)
					input_manager:map_device_to_service("console_input", "keyboard")
					input_manager:map_device_to_service("console_input", "mouse")
					input_manager:block_device_except_service("console_input", "keyboard", 1, "console")
					input_manager:block_device_except_service("console_input", "mouse", 1)
					input_manager:block_device_except_service("console_input", "gamepad", 1)
					Managers.chat.gui_enabled = false
					Managers.rcon._enabled = false
					SelectedHistoryIndex = #CommandHistory
				end
				onetimebool = true
			else
				if onetimebool then --Unblock keyboard, re-enable chat/rcon gui.
					input_manager:device_unblock_all_services("keyboard", 1)
					input_manager:device_unblock_all_services("mouse", 1)
					input_manager:device_unblock_all_services("gamepad", 1)
					if inphotomode() then
						Managers.free_flight.input_manager:block_device_except_service("FreeFlight", "keyboard", nil, "free_flight")
						Managers.free_flight.input_manager:block_device_except_service("FreeFlight", "mouse", nil, "free_flight")
						Managers.free_flight.input_manager:block_device_except_service("FreeFlight", "gamepad", nil, "free_flight")
					end
					Managers.chat.gui_enabled = true
					Managers.rcon._enabled = true
					Input = ""
					LastInput = ""
					Hint = "Use list command to show all available commands. (" .. tostring(mod.CommandsCount()) .. " commands indexed)"
					AutoFillCommand = ""
					Index = 1
				end			
				onetimebool = false
			end
		end
		if script_data.disable_debug_draw == true then script_data.disable_debug_draw = false end --Failsafe.
		
		if Managers.state.debug_text._screen_text_console ~= nil then --Clear everything before (possibly) drawing for a new frame.
			Gui.destroy_text(Managers.state.debug_text._gui, Managers.state.debug_text._screen_text_console.text_id)
			Gui.destroy_rect(Managers.state.debug_text._gui, Managers.state.debug_text._screen_text_console.bgr_id)
			Managers.state.debug_text._screen_text_console = nil
		end		
		
		if mod.ConsoleVisible then --Stuff to do while console is enabled.
			local beforeindex = string.sub(Input, 1, Index - 1)
			local afterindex = string.sub(Input, Index, -1)
			local finalmessage = beforeindex .. "|" .. afterindex
			Managers.state.debug_text:output_screen_text_console_console("> " .. finalmessage .. "     " .. tostring(Hint), 12, nil, Vector3(233,233,233)) 
			for index, key in pairs(keystrokes) do
				local stringed = tostring(key)
				if (stringed:match("%W") and not stringed:match("%s") and not stringed:match("%p") and not stringed:match("%c")) or stringed == "`" then table.remove(keystrokes, index) end
			end
			local ctrl_button_index = Keyboard.button_index("left ctrl")
			local ctrl_held = Keyboard.pressed(ctrl_button_index) or Keyboard.button(ctrl_button_index) > 0
			Input, Index, InputMode = KeystrokeHelper.parse_strokes(Input, Index, InputMode, keystrokes, ctrl_held)
			
			if Input ~= LastInput then
				local HintCBVal = ""
				for index, command in pairs(mod.ConsoleCommands) do
					if ( Input == index or string.find(index, Input:match("%S*")) ) and Input ~= "" then if command.tooltipfunc ~= nil then HintCBVal = " (" .. command.tooltipfunc() .. ")" end Hint = "-[" .. index .. "] " .. command.tooltip .. HintCBVal .. " " .. ischeat(command.cheat) AutoFillCommand = index break else Hint = "Use list command to show all available commands. (" .. tostring(mod.CommandsCount()) .. " commands indexed)" AutoFillCommand = "" end
				end
			end
			
			LastInput = Input
			
			if Keyboard.pressed(Keyboard.button_id("tab")) and AutoFillCommand ~= "" then --Trigger autocomplete with currently matched hint.
				Input = AutoFillCommand
				LastInput = Input
				Index = string.len(Input) + 1
			end
			
			if Keyboard.pressed(Keyboard.button_id("v")) and Keyboard.button(Keyboard.button_index("left ctrl")) > 0 then --Paste from clipboard.
				Input = Input .. tostring(Clipboard.get())
				Index = string.len(Input) + 1
			end	

			if Keyboard.pressed(Keyboard.button_id("up")) and #CommandHistory > 0 then --Autofill with last command from history.
				if Input == CommandHistory[SelectedHistoryIndex] then
					if (SelectedHistoryIndex - 1) <= 0 then SelectedHistoryIndex = #CommandHistory else
					SelectedHistoryIndex = math.clamp(SelectedHistoryIndex - 1, 1, #CommandHistory) end
				end
				Input = CommandHistory[SelectedHistoryIndex] 
				Index = string.len(Input) + 1
			end

			if Keyboard.pressed(Keyboard.button_id("down")) and #CommandHistory > 0 then --Ditto but in other direction.
				if Input == CommandHistory[SelectedHistoryIndex] then
					if (SelectedHistoryIndex + 1) > #CommandHistory then SelectedHistoryIndex = 1 else
					SelectedHistoryIndex = math.clamp(SelectedHistoryIndex + 1, 1, #CommandHistory) end
				end
				Input = CommandHistory[SelectedHistoryIndex] 
				Index = string.len(Input) + 1
			end				
			
			if Keyboard.pressed(Keyboard.button_id("enter")) then --Actually input command.
				local server_id = Managers.state.network.network_transmit.server_peer_id or Managers.state.network.network_transmit.peer_id
				local hit = false
				for index, command in pairs(mod.ConsoleCommands) do
					local cmd, val = Input:match("(%S+)%s+(.+)")
					if (cmd == index or Input == index) and (script_data["eac-untrusted"] and command.cheat and (LobbyInternal.is_friend(server_id) or Managers.player.is_server) or not command.cheat) then --Execute command with variable including cheats but only on modded realm.
						local callback = command.func
						callback(val)
						table.insert(CommandHistory, Input)
						SelectedHistoryIndex = #CommandHistory
						hit = true
						break
					end
				end
					
				if hit == false then
					mod:echo("Unrecognized command " .. Input .. ".")
					mod:echo("You can only execute cheat commands on Modded Realm and while You or a person on Your Steam friends list are the host.")
				end				
				
				Input = ""
				LastInput = ""
				Hint = "Use list command to show all available commands. (" .. tostring(mod.CommandsCount()) .. " commands indexed)"
				AutoFillCommand = ""
				Index = 1
			end
			else
				for index, key in pairs(keystrokes) do --Handle keybindings
					if special_characters[key] ~= nil then key = special_characters[key] end
					local server_id = Managers.state.network.network_transmit.server_peer_id or Managers.state.network.network_transmit.peer_id
					for index1, key1 in pairs(mod.Binds) do
						local command = mod.ConsoleCommands[mod.Binds[index1].command]
						if key == index1 then
							if (script_data["eac-untrusted"] and command.cheat and (LobbyInternal.is_friend(server_id) or Managers.player.is_server)) or not command.cheat then
								command.func(mod.Binds[index1].argument)
								else
								mod:echo("You can only execute cheat commands on Modded Realm and while You or a person on Your Steam friends list are the host.")
							end
						end
					end
				end				
		end
	end
end

-- Called when game state changes (e.g. StateLoading -> StateIngame)
-- status - "enter" or "exit"
-- state  - "StateLoading", "StateIngame" etc.
mod.on_game_state_changed = function(status, state)
	mod.ConsoleVisible = false
	WorldHandle = nil
	GuiHandle = nil
end

-- Called when the checkbox for this mod is unchecked
-- is_first_call - true if called right after mod initialization
mod.on_disabled = function(is_first_call)
	script_data.disable_debug_draw = true --Failsafe
end

-- Called when the checkbox for this is checked
-- is_first_call - true if called right after mod initialization
mod.on_enabled = function(is_first_call)
	script_data.disable_debug_draw = false --Failsafe
end