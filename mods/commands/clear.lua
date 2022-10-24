local chat_manager = Managers.chat
local chat_gui = chat_manager.chat_gui
local messages = chat_gui.chat_output_widget.content.message_tables

while #messages > 0 do
    table.remove(messages, #messages)
end