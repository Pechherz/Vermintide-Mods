-- local mod_name = "test"

-- Mods.hook.set(mod_name, "AnimationSystem.rpc_anim_event", function(func, self, sender, anim_id, go_id)
--     local unit = self.unit_storage:unit(go_id)

--     if not unit or not Unit.alive(unit) then
--         return
--     end

--     if self.is_server then
--         self.network_transmit:send_rpc_clients_except("rpc_anim_event", sender, anim_id, go_id)
--     end

--     if Unit.has_animation_state_machine(unit) then
--         local event = NetworkLookup.anims[anim_id]
--         EchoConsole("event: " .. event)

--         assert(event, "[GameNetworkManager] Lookup missing for event_id", anim_id)
--         Unit.animation_event(unit, event)
--     end
-- end)
