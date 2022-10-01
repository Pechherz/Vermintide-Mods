Mods.debug = {
	-- Draw parameter of function call if you only know the function name
	parameter = function(func_name)
		Mods.hook.set("debug", func_name, function(func, ...)
			local args = table.pack(...)
			local str = func_name .. "("

			for i, v in ipairs(args) do
				str = str .. type(v)

				if #args ~= i then
					str = str .. ", "
				end
			end

			EchoConsole(str .. ")")

			-- Disable the hook
			Mods.hook.enable(false, "debug", func_name)

			return func(...)
		end)

		return
	end,

	parameters = function(o)
		for key, obj in pairs(o) do
			if type(obj) == "function" then
				Mods.debug.parameter(key)
			end
		end

		return
	end,

	---Convert a table to string and reveal its content
	---@param self Mods.debug
	---@param inputTable table
	---@param recursionLimit number
	---@param inputTableName string
	---@param recursionCounter any
	---@param code any
	---@param tabs any
	---@return string
	-- table_to_string = function(self, inputTable, recursionLimit, inputTableName, recursionCounter, code, tabs)
	-- 	if recursionCounter == nil then
	-- 		recursionCounter = 0
	-- 		tabs = ""
	-- 		inputTableName = inputTableName or "tableName"
	-- 		code = code or ""
	-- 	else
	-- 		recursionCounter = recursionCounter + 1
	-- 	end

	-- 	code = code .. tabs .. "[" .. tostring(inputTableName) .. "] = {\n"
	-- 	tabs = tabs .. "    "


	-- 	if inputTable ~= nil and type(inputTable) ~= "table" then
	-- 		return tostring(inputTable)
	-- 	elseif inputTable ~= nil then
	-- 		for key, value in pairs(inputTable) do
	-- 			if type(value) == "table" and recursionLimit > recursionCounter then
	-- 				code = self:table_to_string(value, recursionLimit, key, recursionCounter, code, tabs)
	-- 				code = code .. "\n" .. tabs .. "},\n"
	-- 			elseif type(value) == "function" then

	-- 				local what = debug.getinfo(value, "S").what
	-- 				if what == "Lua" then
						
	-- 					local args = self.get_args(value)
	-- 					local args_string = ""
	-- 					for index, value in ipairs(args) do
	-- 						if index == 1 then
	-- 							args_string = value
	-- 						else
	-- 							args_string = args_string .. ", " .. value						
	-- 						end
	-- 					end
						
	-- 					code = code .. tabs .. key .. " = " .. "\"function(" .. args_string .. ")\"" .. ",\n"
	-- 				elseif what == "C" then
	-- 					code = code .. tabs .. key .. " = " .. "\"C function\"" .. ",\n"
	-- 				else
	-- 					code = code .. tabs .. key .. " = " .. "\"main part of a Lua chunk\"" .. ",\n"
	-- 				end
	-- 			elseif type(value) == "number" and (not value == math.huge or not value == -math.huge) or type(value) == "boolean" then
	-- 				code = code .. tabs .. "[" .. tostring(key) .. "] = " .. tostring(value) .. ",\n"
	-- 			else
	-- 				code = code .. tabs .. "[" .. tostring(key) .. "] = \"" .. tostring(value) .. "\",\n"
	-- 			end
	-- 		end
	-- 	end

	-- 	if recursionCounter == 0 then
	-- 		return code .. "\n" .. "}"
	-- 	else
	-- 		return code
	-- 	end
	-- end,

	---Convert a table to a string
	---@param self Mods.debug
	---@param input_table table The table to be converted to a string representation
	---@param input_table_name string The name of the output table (optional)
	---@param recursion_limit number The number of tables within the input_table to be recursively converted
	---@return string
	table_to_string = function(self, input_table, input_table_name, recursion_limit)
		
		if input_table == nil then
			return input_table_name .. " = " .. "nil"
		elseif type(input_table) ~= "table" then
			return input_table_name .. " = " .. tostring(input_table)
		end
		
		local table_to_string_resursive = function(func, table_field, table_field_name, recursion_limit, recursion_counter, table_string_format, tabs)
			table_field = table_field or {}
			table_field_name = table_field_name or "table"
			recursion_limit = recursion_limit or 0
			recursion_counter = recursion_counter or 0
			table_string_format = table_string_format or ""
			tabs = tabs or "    "

			for field_name, field_value in pairs(table_field)do
				if type(field_name) == "number" or type(field_name) == "string" and type(tonumber(field_name:sub(1, 1))) == "number" then
					field_name = "[\"" .. tostring(field_name) .. "\"]"
				else
					field_name = tostring(field_name)
				end

				if type(field_value) == "table" then
					if recursion_counter < recursion_limit then
						table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "{"
						table_string_format = func(func, field_value, field_name, recursion_limit, (recursion_counter + 1), table_string_format, (tabs .. "    "))
						table_string_format = table_string_format .. "\n" .. tabs .. "},"
					else
						table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "{},"
					end
				elseif type(field_value) == "function" then
					local what = debug.getinfo(field_value, "S").what
					if what == "Lua" then
						
						local args = self.get_args(field_value)
						local args_string = ""
						for index, value in ipairs(args) do
							if index == 1 then
								args_string = value
							else
								args_string = args_string .. ", " .. value						
							end
						end
						
						table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "function(" .. args_string .. ") end,"
					elseif what == "C" then
						table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "function() end, --C function"
					else
						table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "function() end, --main part of a Lua chunk"
					end
				elseif type(field_value) == "boolean" or type(field_value) == "number" and (field_value ~= math.huge or field_value ~= -math.huge) then
					table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. tostring(field_value) .. ","
				elseif type(field_value) == "userdata" then
					table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "\"" .. tostring(field_value) .. "\"" .. ","
				else					
					table_string_format = table_string_format .. "\n" .. tabs .. field_name .. " = " .. "\"" .. tostring(string.gsub(field_value, "\n", "\\n")) .. "\","
				end
			end

			return table_string_format
		end
		
		local table_string_format = input_table_name .. " = {"
		table_string_format = table_string_format .. table_to_string_resursive(table_to_string_resursive, input_table, input_table_name, recursion_limit)
		table_string_format = table_string_format .. "\n}"

		return table_string_format
	end,

	---Get all parameter by their names
	---Note: Doesn't show variable number of arguments, three dots (...)
	---@param func_name string
	---@return table
	get_args = function(func_name)
		local args = {}
	
		local param_index = 1
		while true do
			local param_name = debug.getlocal(func_name, param_index)
			if param_name then
				table.insert(args, param_index, param_name)
			else
				break
			end
			param_index = param_index + 1
		end
		
		return args
	end,

	clear_log = function()
		local fileName = "E:\\SteamLibrary\\steamapps\\common\\Warhammer End Times Vermintide\\binaries\\mods\\patch\\function\\Mods.debug.log.lua"
		local file = io.open(fileName, "w")
		file.write(file, "")
		file.flush(file)
		file.close(file)

		return
	end,

	write_log = function(string)
		local fileName = "E:\\SteamLibrary\\steamapps\\common\\Warhammer End Times Vermintide\\binaries\\mods\\patch\\function\\Mods.debug.log.lua"
		local file = io.open(fileName, "a")
		file.write(file, tostring(string) .. "\n")
		file.flush(file)
		file.close(file)

		return
	end,
	-- Draw all propeties inside object
	object = {

		draw = function(obj, obj_name, level_max)
			local draw
			local found_adress = {}

			if type(obj) ~= "table" then
				return
			end

			table.insert(found_adress, table.adress(obj))

			draw = function(out, o, space, level)
				if level >= level_max then
					return
				end

				for key, obj in pairs(o) do
					if type(obj) == "table" then
						local adress = table.adress(obj)

						if not table.has_item(found_adress, adress) then
							table.insert(found_adress, table.adress(obj))

							out:write(space .. tostring(key) .. "(" .. table.adress(obj) .. ") = {\n")
							draw(out, obj, space .. "	", level + 1)
							out:write(space .. "},\n")
						else
							out:write(space .. tostring(key) .. " = table: " .. table.adress(obj) .. "\n")
						end
					else
						out:write(space .. tostring(key) .. " = " .. tostring(obj) .. ",\n")
					end
				end

				return
			end

			local out = assert(io.open(obj_name .. ".json", "w+"))

			out:write(obj_name .. "(" .. table.adress(obj) .. ") = {\n")
			draw(out, obj, "	", 1)
			out:write("}\n")
			out:close()
		end,

		draw_safe = function(obj, obj_name, level_max)
			local draw
			local draw_obj

			draw = function(out, o, space, level)
				if level >= level_max then
					return
				end

				for key, obj in pairs(o) do
					safe_pcall(function()
						draw_obj(out, obj, key, level, space)
					end)
				end
				return
			end

			draw_obj = function(out, obj, key, level, space)
				if type(obj) == "table" then
					out:write(space .. tostring(key) .. " = {\n")
					draw(out, obj, space .. "	", level + 1)
					out:write(space .. "},\n")
				else
					out:write(space .. tostring(key) .. " = " .. tostring(obj) .. ",\n")
				end
			end

			local out = assert(io.open(obj_name .. ".json", "w+"))

			out:write(obj_name .. " = {\n")
			draw(out, obj, "	", 1)
			out:write("}\n")
			out:close()
		end
	}
}

-- Lazyness mode xD
mdp = Mods.debug.parameter
mdps = Mods.debug.parameters
mdod = Mods.debug.object.draw
mdods = Mods.debug.object.draw_safe
