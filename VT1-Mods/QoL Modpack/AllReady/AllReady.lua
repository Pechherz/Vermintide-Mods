local mod_name = "AllReady"

if Managers.player.is_server then
    Mods.hook.set(mod_name, "MatchmakingManager.all_peers_ready", function(func, self, ...)
        return true
    end)
end
