local mod_name = "test_perception_utils"

Mods.hook.set(mod_name, "PerceptionUtils.pick_area_target", function(func, unit, blackboard, breed, radius, max_distance)
    -- Mods.debug.debug_message = Mods.debug:table_to_string(blackboard, "blackboard", 2)
	local target = nil
	local enemies_in_area = 0
	local circles = {}
	local positions = PLAYER_AND_BOT_POSITIONS

    -- Mods.debug.debug_message = Mods.debug.debug_message .. "\n" .. Mods.debug:table_to_string(positions, "PLAYER_AND_BOT_POSITIONS", 2)

	if #positions > 1 then
		circles = PerceptionUtils._find_circles(unit, positions, radius, max_distance)
	end

    -- Mods.debug.debug_message = Mods.debug.debug_message .. "\n" .. Mods.debug:table_to_string(circles, "circles", 2)

	if #circles > 0 then
		local best_circle = PerceptionUtils._pick_best_circle(circles, positions, radius)
		target = best_circle.pos
		enemies_in_area = best_circle.targets
        
        -- Mods.debug.debug_message = Mods.debug.debug_message .. "\n" .. Mods.debug:table_to_string(target, "target", 2)
	else
		target = POSITION_LOOKUP[blackboard.target_unit]
		enemies_in_area = 1

        -- Mods.debug.debug_message = Mods.debug.debug_message .. "\n" .. Mods.debug:table_to_string(target, "target", 2)
	end

	if Development.parameter("ai_debug_aoe_targeting") then
		PerceptionUtils.debug_draw_pick_area_target(circles, target, radius, positions)
	end

	-- return func(unit, blackboard, breed, radius, max_distance)
    return target, enemies_in_area
end)