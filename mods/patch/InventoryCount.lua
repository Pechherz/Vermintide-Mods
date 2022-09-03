--Xq
local items = (backend_items and backend_items:get_all_backend_items()) or false
local count = 0
if items then
	for key, data in pairs(items) do
		count = count+1
	end
end

EchoConsole("Inventory Count: " .. tostring(count))

--[[
local item_id_list = ScriptBackendItem.get_all_backend_items()

EchoConsole("Inventory Count: " .. tostring(#item_id_list))
--]]
--[[
local item_count = (backend_items and #backend_items:get_all_backend_items()) or 0

EchoConsole("Inventory Count: " .. tostring(item_count))
--]]