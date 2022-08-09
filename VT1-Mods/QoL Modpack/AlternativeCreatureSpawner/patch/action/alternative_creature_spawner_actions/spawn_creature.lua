if CreatureSpawner.get(CreatureSpawner.widget_settings.CREATURE_SPAWNER_ENABLED) then
    if Managers.player.is_server then

        local creature_name = CreatureSpawner.breeds[CreatureSpawner.breed_index].value
        if "skaven_horde" == creature_name then
            for i = 1, CreatureSpawner.spawn_multiplier, 1 do
                Managers.state.conflict:debug_spawn_horde()
            end
        elseif "skaven_storm_vermin_patrol" == creature_name then
            for i = 1, CreatureSpawner.spawn_multiplier, 1 do
                Managers.state.conflict:debug_spawn_group(0)
            end
        else
            for i = 1, CreatureSpawner.spawn_multiplier, 1 do
                Managers.state.conflict:aim_spawning(Breeds[creature_name], false)
            end
        end
        EchoConsole(CreatureSpawner.spawn_multiplier ..
            "x " .. CreatureSpawner.breeds[CreatureSpawner.breed_index].text .. " were spawned")
    end
end
