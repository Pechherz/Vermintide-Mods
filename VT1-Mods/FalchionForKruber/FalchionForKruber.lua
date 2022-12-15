for weapon_name, weapon in pairs(ItemMasterList) do
    if weapon.item_type == "wh_1h_falchions" then
        weapon.can_wield = {
            "witch_hunter",
            "empire_soldier",
        }
    end
end