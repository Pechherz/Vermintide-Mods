local all_distinct_traits = {}
local all_distinct_slot_types = {}
local all_distinct_rarities = {}
local all_promo_items = {}

for weapon, attributes in pairs(ItemMasterList) do
    if attributes.traits then 
        for _, trait in ipairs(attributes.traits) do
            if not all_distinct_traits[trait] then
                local buff_template = BuffTemplates[trait]
                all_distinct_traits[trait] = {
                    name = Localize(buff_template.display_name),
                    description =  BackendUtils.get_trait_description(trait, attributes.rarity),
                }
            end
        end
    end

    if attributes.slot_type and not table.contains(all_distinct_slot_types, attributes.slot_type) then
        table.insert(all_distinct_slot_types, attributes.slot_type)
    end

    if attributes.rarity and not table.contains(all_distinct_rarities, attributes.rarity) then
        table.insert(all_distinct_rarities, attributes.rarity)
    end

    if attributes.rarity and attributes.rarity == "promo" then
        all_promo_items[weapon] = {
            name = Localize(attributes.display_name),
            description = Localize(attributes.description),
            can_wield = {}
        }

        for _, character_id in pairs(attributes.can_wield) do
            table.insert(all_promo_items[weapon].can_wield, Localize(character_id))
        end
    end
end

Mods.debug.clear_log()
Mods.debug.write_log(Mods.debug:table_to_string(all_distinct_traits, "all_distinct_traits", 3))
Mods.debug.write_log(Mods.debug:table_to_string(all_distinct_slot_types, "all_distinct_slot_types", 3))
Mods.debug.write_log(Mods.debug:table_to_string(all_distinct_rarities, "all_distinct_rarities", 3))
Mods.debug.write_log(Mods.debug:table_to_string(all_promo_items, "all_promo_items", 3))