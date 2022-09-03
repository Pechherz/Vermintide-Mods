local args = { ... }
local params = {}
local expected_number_of_parameters = 1

local maps = {
    inn_level = {
        id = "inn_level",
        name = "Red Moon Inn",
    },
    magnus = {
        id = "magnus",
        name = "The Horn of Magnus",
    },
    merchant = {
        id = "merchant",
        name = "Supply and Demand",
    },
    sewers_short = {
        id = "sewers_short",
        name = "Smuggler's Run",
    },
    wizard = {
        id = "wizard",
        name = "The Wizard's Tower",
    },
    dlc_challenge_wizard = {
        id = "dlc_challenge_wizard",
        name = "Trial of the Foolhardy",
    },
    bridge = {
        id = "bridge",
        name = "Black Powder",
    },
    forest_ambush = {
        id = "forest_ambush",
        name = "Engines of War",
    },
    city_wall = {
        id = "city_wall",
        name = "Man the Ramparts",
    },
    cemetery = {
        id = "cemetery",
        name = "Garden of Morr",
    },
    farm = {
        id = "farm",
        name = "Wheat and Chaff",
    },
    tunnels = {
        id = "tunnels",
        name = "The Enemy Below",
    },
    courtyard_level = {
        id = "courtyard_level",
        name = "Well Watch",
    },
    docks_short_level = {
        id = "docks_short_level",
        name = "Waterfront",
    },
    end_boss = {
        id = "end_boss",
        name = "The White Rat",
    },
    chamber = {
        id = "chamber",
        name = "Waylaid",
    },
    dlc_survival_magnus = {
        id = "dlc_survival_magnus",
        name = "Town Meeting",
    },
    dlc_dwarf_interior = {
        id = "dlc_dwarf_interior",
        name = "Khazid Kro",
    },
    dlc_dwarf_exterior = {
        id = "dlc_dwarf_exterior",
        name = "The Cursed Rune",
    },
    dlc_dwarf_beacons = {
        id = "dlc_dwarf_beacons",
        name = "Chain of Fire",
    },
    dlc_castle = {
        id = "dlc_castle",
        name = "Castle Drachenfels",
    },
    dlc_castle_dungeon = {
        id = "dlc_castle_dungeon",
        name = "The Dungeons",
    },
    dlc_portals = {
        id = "dlc_portals",
        name = "Summoner's Peak",
    },
    dlc_stromdorf_hills = {
        id = "dlc_stromdorf_hills",
        name = "The Courier",
    },
    dlc_stromdorf_town = {
        id = "dlc_stromdorf_town",
        name = "Reaching Out",
    },
    dlc_reikwald_river = {
        id = "dlc_reikwald_river",
        name = "The River Reik",
    },
    dlc_reikwald_forest = {
        id = "dlc_reikwald_forest",
        name = "Reikwald Forest",
    },
    dlc_survival_ruins = {
        id = "dlc_survival_ruins",
        name = "The Fall",
    },
}

local difficulties = {
    easy = {
        id = "easy",
        name = "Easy"
    },
    normal = {
        id = "normal",
        name = "Normal"
    },
    hard = {
        id = "hard",
        name = "Hard"
    },
    harder = {
        id = "harder",
        name = "Nightmare"
    },
    hardest = {
        id = "hardest",
        name = "Cataclysm"
    },
    survival_hard = {
        id = "survival_hard",
        name = "Veteran (Last Stand)",
    },
    survival_harder = {
        id = "survival_harder",
        name = "Champion (Last Stand)",
    },
    survival_hardest = {
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

    local index = 1
    for _, map in pairs(maps) do
        help_message = help_message .. index .. ". " .. map.id .. " (" .. map.name .. ")\n"
        index = index + 1
    end

    help_message = help_message .. "\ndifficulties:\n"

    index = 1
    for _, difficulty in pairs(difficulties) do
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

    --
    local map = maps[map_id]
    local map_exists = map ~= nil

    if not map_exists then
        EchoConsole("\nThe map id '" .. map_id .. "' doesn't exist.")
        EchoConsole("Refer to the following help command for more information:\n/loadmap help")
        return
    end

    --optional
    --check if a diffiulty is provided, otherwise just get the currently set difficulty
    local difficulty = nil
    local difficulty_exists = false


    if difficulty_id ~= nil then
        difficulty = difficulties[difficulty_id]
        difficulty_exists = difficulty ~= nil

        if difficulty_exists then
            difficulty_manager:set_difficulty(difficulty_id)
        else
            EchoConsole("\nThe difficulty id '" .. difficulty_id .. "' doesn't exist.")
            EchoConsole("Refer to the following help command for more information:\n/loadmap help")
            return
        end
    else
        difficulty_id = difficulty_manager:get_difficulty()
        difficulty = difficulties[difficulty_id]
    end

    local map_name = map.name
    local difficulty_name = difficulty.name

    Managers.chat:send_system_chat_message(1, "\nLoading the map " .. map_name .. " on " .. difficulty_name, 0, true)
    Managers.state.game_mode:start_specific_level(map_id, nil)
else
    EchoConsole("Refer to the following help command for more information:\n/loadmap help")
end
