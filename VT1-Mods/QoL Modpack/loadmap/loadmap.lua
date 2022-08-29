local args = { ... }
local params = {}
--give a non-negative amount of parameters
local expected_number_of_parameters = 1
local available_maps = {
    {
        value = "magnus",
        text = "The Horn of Magnus",
    },
    {
        value = "bridge",
        text = "Black Powder",
    },
    {
        value = "Smuggler's Run",
        text = "sewers_short",
    },
    {
        value = "wizard",
        text = "The Wizard's Tower",
    },
    {
        value = "city_wall",
        text = "Man the Ramparts",
    },
    {
        value = "tunnels",
        text = "The Enemy Below",
    },
    {
        value = "cemetery",
        text = "Garden of Morr",
    },
    {
        value = "forest_ambush",
        text = "Engines of War",
    },
    {
        value = "merchant",
        text = "Supply and Demand",
    },
    {
        value = "end_boss",
        text = "The White Rat",
    },
    {
        value = "courtyard_level",
        text = "Well Watch",
    },
    {
        value = "docks_short_level",
        text = "Waterfront",
    },
    {
        value = "farm",
        text = "Wheat and Chaff",
    },
    {
        value = "dlc_dwarf_interior",
        text = "Khazid Kro",
    },
    {
        value = "dlc_portals",
        text = "Summoner's Peak",
    },
    {
        value = "dlc_castle_dungeon",
        text = "The Dungeons",
    },
    {
        value = "dlc_castle",
        text = "Castle Drachenfels",
    },
    {
        value = "dlc_dwarf_exterior",
        text = "The Cursed Rune",
    },
    {
        value = "dlc_dwarf_beacons",
        text = "Chain of Fire",
    },
    {
        value = "dlc_stromdorf_hills",
        text = "The Courier",
    },
    {
        value = "dlc_stromdorf_town",
        text = "Reaching Out",
    },
    {
        value = "dlc_reikwald_forest",
        text = "Reikwald Forest",
    },
    {
        value = "dlc_reikwald_river",
        text = "The River Reik",
    },
    {
        value = "dlc_challenge_wizard",
        text = "Trial of the Foolhardy",
    },
    {
        value = "dlc_survival_magnus",
        text = "Town Meeting",
    },
    {
        value = "dlc_survival_ruins",
        text = "The Fall",
    },
}

local difficulties = {
    {
        difficulty_id = "easy",
        difficulty_name = "Easy"
    },
    {
        difficulty_id = "normal",
        difficulty_name = "Normal"
    },
    {
        difficulty_id = "hard",
        difficulty_name = "Hard"
    },
    {
        difficulty_id = "harder",
        difficulty_name = "Nightmare"
    },
    {
        difficulty_id = "hardest",
        difficulty_name = "Cataclysm"
    },
    {
        difficulty_id = "survival_hard",
        difficulty_name = "Veteran (Last Stand)",
    },
    {
        difficulty_id = "survival_harder",
        difficulty_name = "Champion (Last Stand)",
    },
    {
        difficulty_id = "survival_hardest",
        difficulty_name = "Heroic (Last Stand)",
    },
}

for value in string.gmatch(args[1], "%S+") do
    table.insert(params, value)
end

local get_help = function()
    EchoConsole("\n-START-OF-HELP-MESSAGE-")

    if expected_number_of_parameters == 1 then
        EchoConsole("You need to pass 1 argument.")
    else
        EchoConsole("You need to pass " .. expected_number_of_parameters .. " arguments.")
    end
    EchoConsole("\n")

    EchoConsole("/loadmap <map name> <difficulty name (optional)>")

    EchoConsole("map names:")
    for index, value in ipairs(available_maps) do
        EchoConsole(index .. ". " .. value.value .. " (" .. value.text .. ")")
    end
    EchoConsole("\n")

    EchoConsole("difficulties")
    for index, value in ipairs(difficulties) do
        EchoConsole(index .. ". " .. value.difficulty_id .. " (" .. value.difficulty_name .. ")")
    end
    EchoConsole("\n")

    EchoConsole("The following example would load 'The Horn of Magnus' on Nightmare:\n /loadmap magnus harder")

    EchoConsole("-END-OF-HELP-MESSAGE-\n")
end

if params[1] == "help" then
    get_help()
elseif #params >= expected_number_of_parameters then
    local map_id = params[1]
    local difficulty_id = params[2]

    --optional
    --check if the difficulty exists
    if difficulty_id ~= nil then
        local difficulty_exists = false
        for _, difficulty in ipairs(difficulties) do
            if difficulty.difficulty_id == difficulty_id then
                difficulty_exists = true
                -- return
            end
        end

        if difficulty_exists then
            local difficulty_manager = Managers.state.difficulty
            difficulty_manager:set_difficulty(difficulty_id)
        else
            EchoConsole("The difficulty '" .. difficulty_id .. "' doesn't exist.")
            return
        end
    end

    local map_name_exists = false
    for _, map in ipairs(available_maps) do
        if map.value == map_id then
            map_name_exists = true
            -- return
        end
    end

    if map_name_exists then
        Managers.state.game_mode:start_specific_level(map_id, nil)
    else
        EchoConsole("The map '" .. map_id .. "' doesn't exist.")
    end
else
    EchoConsole("Refer to the following help command for more information:\n/loadmap help")
end
