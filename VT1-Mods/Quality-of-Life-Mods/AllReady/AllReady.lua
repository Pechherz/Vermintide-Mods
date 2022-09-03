local mod_name = "AllReady"

Mods.hook.set(mod_name, "MatchmakingManager.all_peers_ready", function(func, self, ...)
    return true
end)
