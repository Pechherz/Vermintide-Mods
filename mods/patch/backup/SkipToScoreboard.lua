local mod_name = "SkipToScoreboard"

 Mods.hook.set(mod_name, "EndOfLevelUI.start", function(func, self, ignore_input_blocking)
 	ShowCursorStack.push()

 	self.cursor_pushed = true

 	-- self:handle_transition("summary_screen", ignore_input_blocking)
 	self:handle_transition("scoreboard_screen", ignore_input_blocking)

 	self.initialize_start_transition = nil
 	self.start_transition_initialized = true
 end)
