local token_type_list = {
    {
        value = "gold_tokens",
        text = "Orange Tokens"
    },
    {
        value = "silver_tokens",
        text = "Blue Tokens"
    },
    {
        value = "bronze_tokens",
        text = "Green Tokens"
    },
    {
        value = "iron_tokens",
        text = "White Tokens"
    }
}

local args = { ... }
local params = {}
local expected_number_of_parameters = 2

for value in string.gmatch(args[1], "%S+") do
    table.insert(params, value)
end

local get_help = function()
    EchoConsole("\n")
    EchoConsole("You need to pass 2 arguments.")
    EchoConsole("/givetokens <token type> <non-zero number>")

    EchoConsole("There are only 4 available tokens you can award yourself with.")
    EchoConsole("1. iron_tokens (white tokens)")
    EchoConsole("2. bronze_tokens (green tokens)")
    EchoConsole("3. silver_tokens (blue tokens)")
    EchoConsole("4. gold_tokens (orange/red tokens)")
    EchoConsole("\n")
end

if params[1] == "help" then
    get_help()
elseif #params == expected_number_of_parameters then
    local token_type = params[1]
    local number_of_tokens = params[2]

    for index, token in ipairs(token_type_list) do
        if token_type == token.value then
            if number_of_tokens < 0 then
                EchoConsole("No Tokens were added to your inventory.")
            elseif number_of_tokens == 1 then
                BackendUtils.add_tokens(number_of_tokens, token_type)
                Managers.backend:commit()

                EchoConsole("A single " .. token.text .. " was added to your inventory.")
            else
                BackendUtils.add_tokens(number_of_tokens, token_type)
                Managers.backend:commit()

                EchoConsole(number_of_tokens .. "x " .. token.text .. " were successfully added to your inventory.")
            end
        end
    end
else
    EchoConsole("Refer to the help page. /givetokens help")
end
