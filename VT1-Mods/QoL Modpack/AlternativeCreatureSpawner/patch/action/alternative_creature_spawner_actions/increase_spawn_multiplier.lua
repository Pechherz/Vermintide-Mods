if CreatureSpawner.get(CreatureSpawner.widget_settings.CREATURE_SPAWNER_ENABLED) then
    if Managers.player.is_server then
        CreatureSpawner.spawn_multiplier = CreatureSpawner.spawn_multiplier + 1
        EchoConsole("Current Creature: " ..
            CreatureSpawner.spawn_multiplier .. "x " .. CreatureSpawner.breeds[CreatureSpawner.breed_index].text)
    end
end
