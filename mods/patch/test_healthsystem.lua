local mod_name = "healthsystem_test"
local is_already_logged = true
-- Mods.hook.set(mod_name, "HealthSystem.rpc_sync_damage_taken", function(func, self, sender, go_id, is_level_unit, damage_amount, state_id)
--         EchoConsole("go_id: " .. go_id .. ", is_level_unit:" .. is_level_unit .. ", damage_amount: " .. damage_amount .. ", state_id:" .. state_id)

--         return func(self, sender, go_id, is_level_unit, damage_amount, state_id)
-- end)

-- Mods.hook.set(mod_name, "HealthSystem.update", function(func, self, context, t)
--     if not is_already_logged then
--         EchoConsole("context: " .. Mods.debug:table_to_string(context, 2, "context") .. ", t: " .. tostring(t))
--         is_already_logged = true
--     end

--     return func(self, context, t)
-- end)
