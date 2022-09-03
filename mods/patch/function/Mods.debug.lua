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

	table_to_string = function(self, inputTable, recursionLimit, inputTableName, recursionCounter, code, tabs)
		if recursionCounter == nil then
			recursionCounter = 0
			tabs = ""
			inputTableName = inputTableName or "tableName"
			code = code or ""
		else
			recursionCounter = recursionCounter + 1
		end

		code = code .. tabs .. tostring(inputTableName) .. " = {\n"
		tabs = tabs .. "    "


		if inputTable ~= nil and type(inputTable) ~= "table" then
			return tostring(inputTable)
		elseif inputTable ~= nil then
			for key, value in pairs(inputTable) do
				if type(value) == "table" and recursionLimit > recursionCounter then
					code = self:table_to_string(value, recursionLimit, key, recursionCounter, code, tabs)
					code = code .. "\n" .. tabs .. "},\n"
				elseif type(value) == "function" then
					-- code = code .. tabs .. key .. " = " .. string.dump(value) .. "\n"
					code = code .. tabs .. key .. " = " .. "\"function() ... end\"" .. ",\n"
				elseif type(value) == "number" or type(value) == "boolean" then
					code = code .. tabs .. tostring(key) .. " = " .. tostring(value) .. ",\n"
				else
					code = code .. tabs .. "" .. tostring(key) .. " = \"" .. tostring(value) .. "\",\n"
				end
			end
		end

		if recursionCounter == 0 then
			return code .. "\n" .. "}"
		else
			return code
		end
	end,

	table_to_string_new = function(self, inputTable, inputTableName, recursionLimit)


		local table_to_string_resursive = function(inputTable, inputTableName, recursionLimit, recursionCounter, code, tabs)
			if recursionCounter == nil then
				recursionCounter = 0
				tabs = ""
				inputTableName = inputTableName or "tableName"
				code = code or ""
			else
				recursionCounter = recursionCounter + 1
			end

		end

		-- return table_to_string_resursive(inputTable, inputTableName, recursionLimit, recursionLimit)


		code = code .. tabs .. tostring(inputTableName) .. " = {\n"
		tabs = tabs .. "    "
		code = code or ""
		inputTableName = inputTableName or "[no table name providede]"



		if inputTable ~= nil and type(inputTable) ~= "table" then
			return tostring(inputTable)
		elseif inputTable ~= nil then
			for key, value in pairs(inputTable) do
				if type(value) == "table" and recursionLimit > recursionCounter then
					code = table_to_string_resursive(value, recursionLimit, key, recursionCounter, code, tabs)
					code = code .. "\n" .. tabs .. "},\n"
				elseif type(value) == "function" then
					code = code .. tabs .. key .. " = " .. "\"function() ... end\"" .. ",\n"
				elseif type(value) == "number" or type(value) == "boolean" then
					code = code .. tabs .. tostring(key) .. " = " .. tostring(value) .. ",\n"
				else
					code = code .. tabs .. "" .. tostring(key) .. " = \"" .. tostring(value) .. "\",\n"
				end
			end
		end

		if recursionCounter == 0 then
			return code .. "\n" .. "}"
		else
			return code
		end
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
		local fileName = "D:\\SteamLibrary\\steamapps\\common\\Warhammer End Times Vermintide\\binaries\\mods\\patch\\function\\Mods.debug.log.lua"
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
