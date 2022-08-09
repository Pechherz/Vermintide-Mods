if CreatureSpawner.get(CreatureSpawner.widget_settings.CREATURE_SPAWNER_ENABLED) then
    if Managers.player.is_server then
        CreatureSpawner.breed_index = CreatureSpawner.breed_index - 1
        if CreatureSpawner.breed_index < 1 then
            CreatureSpawner.breed_index = #CreatureSpawner.breeds
        end
        EchoConsole("Current Creature: " ..
            CreatureSpawner.spawn_multiplier .. "x " .. CreatureSpawner.breeds[CreatureSpawner.breed_index].text)
    end
end
