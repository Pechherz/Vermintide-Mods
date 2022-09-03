Mods.hook.set(mod_name, "MatchmakingManager.find_game",
    function(func, self, level_key, difficulty, private_game, quick_game, game_mode, area, t, level_filter)
        local status, err = pcall(function()
            EchoConsole("level_key:" ..
                level_key ..
                " difficulty:" ..
                difficulty ..
                " private_game:" ..
                tostring(private_game) ..
                " quick_game:" ..
                tostring(quick_game) ..
                "game_mode:" .. game_mode .. "area:" .. area .. " t:" .. t .. "level_filter:" .. tostring(level_filter))
        end)

        EchoConsole(err)

        return func(self, level_key, difficulty, private_game, quick_game, game_mode, area, t, level_filter)
    end)




-- Mods.hook.set(mod_name, "MatchmakingManager.hero_available_in_lobby_data",
--     function(func, self, hero_index, lobby_data)
--         return true
--     end)
