local args = { ... }
local params = {}
local expected_number_of_parameters = 1

local maps = {
    {
        id = "inn_level",
        name = "Red Moon Inn",
    },
    {
        id = "magnus",
        name = "The Horn of Magnus",
    },
    {
        id = "merchant",
        name = "Supply and Demand",
    },
    {
        id = "sewers_short",
        name = "Smuggler's Run",
    },
    {
        id = "wizard",
        name = "The Wizard's Tower",
    },
    {
        id = "dlc_challenge_wizard",
        name = "Trial of the Foolhardy",
    },
    {
        id = "bridge",
        name = "Black Powder",
    },
    {
        id = "forest_ambush",
        name = "Engines of War",
    },
    {
        id = "city_wall",
        name = "Man the Ramparts",
    },
    {
        id = "cemetery",
        name = "Garden of Morr",
    },
    {
        id = "farm",
        name = "Wheat and Chaff",
    },
    {
        id = "tunnels",
        name = "The Enemy Below",
    },
    {
        id = "courtyard_level",
        name = "Well Watch",
    },
    {
        id = "docks_short_level",
        name = "Waterfront",
    },
    {
        id = "end_boss",
        name = "The White Rat",
    },
    {
        id = "chamber",
        name = "Waylaid",
    },
    {
        id = "dlc_dwarf_interior",
        name = "Khazid Kro",
    },
    {
        id = "dlc_dwarf_exterior",
        name = "The Cursed Rune",
    },
    {
        id = "dlc_dwarf_beacons",
        name = "Chain of Fire",
    },
    {
        id = "dlc_castle",
        name = "Castle Drachenfels",
    },
    {
        id = "dlc_castle_dungeon",
        name = "The Dungeons",
    },
    {
        id = "dlc_portals",
        name = "Summoner's Peak",
    },
    {
        id = "dlc_stromdorf_hills",
        name = "The Courier",
    },
    {
        id = "dlc_stromdorf_town",
        name = "Reaching Out",
    },
    {
        id = "dlc_reikwald_river",
        name = "The River Reik",
    },
    {
        id = "dlc_reikwald_forest",
        name = "Reikwald Forest",
    },
    {
        id = "dlc_survival_magnus",
        name = "Town Meeting",
    },
    {
        id = "dlc_survival_ruins",
        name = "The Fall",
    },
}

local difficulties = {
    {
        id = "easy",
        name = "Easy"
    },
    {
        id = "normal",
        name = "Normal"
    },
    {
        id = "hard",
        name = "Hard"
    },
    {
        id = "harder",
        name = "Nightmare"
    },
    {
        id = "hardest",
        name = "Cataclysm"
    },
    {
        id = "survival_hard",
        name = "Veteran (Last Stand)",
    },
    {
        id = "survival_harder",
        name = "Champion (Last Stand)",
    },
    {
        id = "survival_hardest",
        name = "Heroic (Last Stand)",
    },
}

for value in string.gmatch(args[1], "%S+") do
    table.insert(params, value)
end

local get_help = function()
    local help_message = "\n-START-OF-HELP-MESSAGE-\n"

    if expected_number_of_parameters == 1 then
        help_message = help_message .. "You need to pass atleast 1 argument.\n"
    else
        help_message = help_message .. "You need to pass " .. expected_number_of_parameters .. " arguments.\n"
    end

    help_message = help_message .. "/loadmap <map id> <optional difficulty id>\n\n"

    help_message = help_message .. "maps:\n"

    for index, map in ipairs(maps) do
        help_message = help_message .. index .. ". " .. map.id .. " (" .. map.name .. ")\n"
        index = index + 1
    end

    help_message = help_message .. "\ndifficulties:\n"

    for index, difficulty in ipairs(difficulties) do
        help_message = help_message .. index .. ". " .. difficulty.id .. " (" .. difficulty.name .. ")\n"
        index = index + 1
    end

    help_message = help_message .. "\nThe following example would load 'The Horn of Magnus' on Nightmare:\n"
    help_message = help_message .. "/loadmap magnus harder\n"
    help_message = help_message .. "-END-OF-HELP-MESSAGE-\n"

    return help_message
end

if params[1] == "help" then
    EchoConsole(get_help())
elseif #params >= expected_number_of_parameters then
    local map_id = params[1]
    local difficulty_id = params[2]
    local difficulty_manager = Managers.state.difficulty

    local map = nil

    for _, map_entry in ipairs(maps) do
        if map_entry.id == map_id then
            map = map_entry
            break
        end
    end

    if map == nil then
        EchoConsole("\nThe map id '" .. map_id .. "' doesn't exist.")
        EchoConsole("Refer to the following help command for more information:\n/loadmap help")
        return
    end

    --optional
    --check if a diffiulty is provided, otherwise just get the currently set difficulty
    local difficulty = nil

    if difficulty_id ~= nil then
        for _, difficulty_entry in ipairs(difficulties) do
            if difficulty_entry.id == difficulty_id then
                difficulty = difficulty_entry
                break
            end
        end

        if difficulty == nil then
            EchoConsole("\nThe difficulty id '" .. difficulty_id .. "' doesn't exist.")
            EchoConsole("Refer to the following help command for more information:\n/loadmap help")
            return
        else
            difficulty_manager:set_difficulty(difficulty_id)
        end
    else
        for _, difficulty_entry in ipairs(difficulties) do
            if difficulty_entry.id == difficulty_manager:get_difficulty() then
                difficulty = difficulty_entry
                break
            end
        end
    end

    local map_name = map.name
    local difficulty_name = difficulty.name

    Managers.chat:send_system_chat_message(1, "Loading " .. map_name .. " on " .. difficulty_name, 0, true)

    Managers.state.game_mode:start_specific_level(map_id, nil)
else
    EchoConsole("Refer to the following help command for more information:\n/loadmap help")
end
