-- fix patrols (or bosses) spawning right at your face
-- 
-- Xq 2021
-- This adjustment is intended to work with QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "fix_no_face_patrols"

local event_triggered = false
local MP_BOXED_POS = 2
local EVENT_TOO_CLOSE_THRESHOLD = 16
local EVENT_TOO_CLOSE_HEIGHT_THRESHOLD = 6

Mods.hook.set(mod_name , "EnemyRecycler._update_main_path_events", function(func, self, t, dt)
	local id				= self.current_main_path_event_id
	local events			= self.main_path_events
	local event				= id and events[id]
	local event_position	= event and event[MP_BOXED_POS] and event[MP_BOXED_POS]:unbox()
	
	if event_position then
		if self.current_main_path_event_activation_dist <= self.main_path_info.ahead_travel_dist then
			event_triggered = true
		end
		
		local player_too_close = false
		-- local closest_dist = math.huge
		for _, owner in pairs(Managers.player:human_and_bot_players()) do
			local unit				= owner.player_unit
			local pos				= POSITION_LOOKUP[unit]
			if pos then
				local distance_to_event	= Vector3.distance(pos, event_position)
				-- if distance_to_event < closest_dist then
					-- closest_dist = distance_to_event
				-- end
				if distance_to_event < EVENT_TOO_CLOSE_THRESHOLD and math.abs(event_position.z - pos.z) < EVENT_TOO_CLOSE_HEIGHT_THRESHOLD then
					player_too_close = true
					break
				end
			end
		end
		
		-- if player_too_close and event_triggered then
			-- EchoConsole("delaying face event " .. tostring(event_position))
		-- end
		
		if not player_too_close and event_triggered then
			-- trigger the event
			-- EchoConsole("Event triggered  " .. tostring(event_position) .. " dist:" .. tostring(closest_dist))
			self.current_main_path_event_activation_dist = self.main_path_info.ahead_travel_dist
			func(self, t, dt)
			event_triggered = false
		end
	end
	return
end)

-- engines of war
-- (119.563, -142.997, -14.404) << face patrol
