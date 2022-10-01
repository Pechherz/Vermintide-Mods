AchievementTracker = {}
AchievementTracker.achievements = {
    {
        name = "complete_the_horn_of_magnus",

    }
}
local player_manager = Managers.player
local achievement_manager = Managers.state.achievement
local local_player = player_manager:local_player()
local platform_id = local_player:platform_id()
local stats_id = local_player:stats_id()

--Check Dodge Krench Overheads Achievement Progress
-- Managers.chat:send_system_chat_message(1, "Dodge Krench Overheads", 0, true)
-- local achievement_manager = Managers.state.achievement
-- for key, value in pairs(Managers.player._human_players) do
--     local krench_achievement_progress = achievement_manager.statistics_db.statistics[key]["dodged_storm_vermin_champion"]
--     local peer_id = value.network_manager.peer_id
--     local player_name = value._cached_name

--     local message = "" .. player_name .. " " .. krench_achievement_progress.value .. "/3"
--     Managers.chat:send_system_chat_message(1, message, 0, true)
-- end
