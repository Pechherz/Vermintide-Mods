for weapon_name, weapon in pairs(ItemMasterList) do
    if weapon.item_type == "wh_1h_falchions" then
        table.insert(weapon.can_wield, "empire_soldier")
    end
end

local falchion = {
    Weapons.one_hand_falchion_template_1,
    Weapons.one_hand_falchion_template_1_co,
    Weapons.one_hand_falchion_template_1_t2,
    Weapons.one_hand_falchion_template_1_t3,
    Weapons.one_hand_falchion_template_1_t3_un,
}

for _, weapon in ipairs(falchion) do
    weapon.actions.action_one.light_attack_right.anim_event = "attack_swing_right"
    weapon.actions.action_one.default.anim_event = "attack_swing_charge"
    weapon.actions.action_one.heavy_attack.anim_event = "attack_swing_heavy"
    weapon.actions.action_one.default_right.anim_event = "attack_swing_charge_left"
    weapon.actions.action_one.heavy_attack_2.anim_event = "attack_swing_heavy_right"
end
