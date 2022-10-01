Mods.debug.clear_log()
local unit_string = Mods.debug:table_to_string(Breeds, 5, "Breeds")
Mods.debug.write_log(unit_string)

Breeds = {
    [skaven_ratling_gunner] = {
        [bots_flank_while_targeted] = true,
        [base_unit] = "units/beings/enemies/skaven_ratlinggunner/chr_skaven_ratlinggunner",
        [behavior] = "skaven_ratling_gunner",
        [perception_continuous] = "perception_continuous_keep_target",
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.29999999999999999",
        [weapon_reach] = "2",
        [death_sound_event] = "Play_enemy_vo_ratling_gunner_die",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "2",
        [poison_resistance] = "100",
        [proximity_system_check] = true,
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "200",
            [4] = "0",

        },
        [perception_previous_attacker_stickyness_value] = "-20",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightleg",
                    [2] = "c_rightupleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftleg",
                    [2] = "c_leftupleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",
                    [2] = "c_neck1",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_hips",
                    [2] = "c_spine",
                    [3] = "c_spine2",
                    [4] = "c_leftshoulder",
                    [5] = "c_rightshoulder",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [aux] = {
                [prio] = "6",
                [actors] = {
                    [1] = "c_backpack",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },

        },
        [unit_template] = "ai_unit_ratling_gunner",
        [disabled] = false,
        [radius] = "1",
        [detection_radius] = "1.#INF",
        [smart_targeting_height_multiplier] = "2.1000000000000001",
        [hit_effect_template] = "HitEffectsRatlingGunner",
        [walk_speed] = "1.8999999999999999",
        [smart_targeting_outer_width] = "0.69999999999999996",
        [target_selection] = "pick_closest_target",
        [special] = true,
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [wield_inventory_on_spawn] = true,
        [max_health] = {
            [1] = "8",
            [2] = "9",
            [3] = "11",
            [4] = "14",
            [5] = "20",

        },
        [scale_death_push] = "5",
        [line_of_sight_cast_template] = {
            [1] = "c_spine1",
            [2] = "c_head",
            [current_index] = "1",
            [c_head] = false,
            [c_spine1] = false,

        },
        [hit_reaction] = "ai_default",
        [no_stagger_duration] = true,
        [aim_template] = "ratling_gunner",
        [size_variation_range] = {
            [1] = "1.1000000000000001",
            [2] = "1.1000000000000001",

        },
        [default_inventory_template] = "ratlinggun",
        [flingable] = true,
        [perception] = "perception_all_seeing",
        [death_reaction] = "ai_default",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [animation_sync_rpc] = "rpc_sync_anim_state_4",
        [exchange_order] = "2",
        [spawning_rule] = "always_ahead",
        [is_bot_aid_threat] = true,
        [bots_should_flank] = true,
        [smart_object_template] = "special",
        [awards_positive_reinforcement_message] = true,
        [run_speed] = "4",
        [bone_lod_level] = "1",
        [has_inventory] = true,
        [name] = "skaven_ratling_gunner",
        [num_push_anims] = {
            [push_backward] = "2",

        },

    },
    [skaven_clan_rat] = {
        [during_horde_detection_radius] = "15",
        [aoe_height] = "1.3999999999999999",
        [base_unit] = "units/beings/enemies/skaven_clan_rat/chr_skaven_clan_rat",
        [behavior] = "pack_rat",
        [smart_targeting_width] = "0.20000000000000001",
        [use_backstab_vo] = true,
        [horde_target_selection] = "horde_pick_closest_target_with_spillover",
        [weapon_reach] = "2",
        [death_sound_event] = "Play_clan_rat_die_vce",
        [backstab_player_sound_event] = "Play_clan_rat_attack_player_back_vce",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "1",
        [poison_resistance] = "70",
        [stagger_duration_mod] = "1",
        [name] = "skaven_clan_rat",
        [has_running_attack] = true,
        [increase_incoming_damage_fx_node] = "c_head",
        [detection_radius] = "12",
        [attack_player_sound_event] = "Play_clan_rat_attack_vce",
        [target_selection] = "pick_closest_target_with_spillover",
        [unit_template] = "ai_unit_clan_rat",
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "40",
            [4] = "40",

        },
        [horde_behavior] = "horde_rat",
        [passive_walk_speed] = "2",
        [wwise_voices] = {
            [1] = "indy_low",
            [2] = "indy_medium",
            [3] = "indy_high",
            [4] = "james_low",
            [5] = "james_medium",
            [6] = "james_high",
            [7] = "danijel_high",
            [8] = "danijel_medium",
            [9] = "danijel_low",
            [10] = "magnus_high",
            [11] = "magnus_low",
            [12] = "magnus_medium",

        },
        [flingable] = true,
        [stagger_duration_difficulty_mod] = {
            [hard] = "0.90000000000000002",
            [harder] = "0.75",
            [normal] = "1",
            [easy] = "1",
            [hardest] = "0.59999999999999998",

        },
        [smart_targeting_outer_width] = "0.75",
        [max_health] = {
            [1] = "3",
            [2] = "4",
            [3] = "5",
            [4] = "6",
            [5] = "10",

        },
        [default_inventory_template] = "default",
        [attack_general_sound_event] = "Play_clan_rat_attack_vce",
        [has_inventory] = true,
        [bone_lod_level] = "1",
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.20000000000000001",
            [j_lefthand] = "0.20000000000000001",
            [j_spine] = "0.40000000000000002",
            [j_neck] = "0.29999999999999999",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.20000000000000001",
            [j_leftleg] = "0.20000000000000001",
            [j_rightupleg] = "0.20000000000000001",
            [j_tail5] = "0.050000000000000003",
            [j_spine1] = "0.40000000000000002",
            [j_leftfoot] = "0.20000000000000001",
            [j_rightleg] = "0.20000000000000001",
            [j_leftforearm] = "0.20000000000000001",
            [j_righthand] = "0.20000000000000001",
            [j_tail4] = "0.050000000000000003",
            [j_rightarm] = "0.20000000000000001",
            [j_leftupleg] = "0.20000000000000001",
            [j_rightshoulder] = "0.29999999999999999",
            [j_tail6] = "0.050000000000000003",
            [j_righttoebase] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_hips] = "0.40000000000000002",
            [j_leftarm] = "0.20000000000000001",
            [j_leftshoulder] = "0.29999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.20000000000000001",

        },
        [wwise_voice_switch_group] = "clan_rat_vce",
        [hit_reaction] = "ai_default",
        [hit_effect_template] = "HitEffectsSkavenClanRat",
        [smart_targeting_height_multiplier] = "2",
        [size_variation_range] = {
            [1] = "0.94999999999999996",
            [2] = "1.05",

        },
        [radius] = "2",
        [increase_incoming_damage_fx] = "fx/chr_enemy_clanrat_damage_buff",
        [opt_base_unit] = {
            [1] = "units/beings/enemies/skaven_clan_rat/chr_skaven_clan_rat_baked_var1",
            [2] = "units/beings/enemies/skaven_clan_rat/chr_skaven_clan_rat_baked_var2",
            [3] = "units/beings/enemies/skaven_clan_rat/chr_skaven_clan_rat_baked_var3",
            [4] = "units/beings/enemies/skaven_clan_rat/chr_skaven_clan_rat_baked_var4",

        },
        [smart_object_template] = "default_clan_rat",
        [perception_previous_attacker_stickyness_value] = "-7.75",
        [animation_sync_rpc] = "rpc_sync_anim_state_7",
        [exchange_order] = "4",
        [perception] = "perception_regular",
        [death_reaction] = "ai_default",
        [animation_merge_options] = {
            [idle_animation_merge_options] = {

            },
            [move_animation_merge_options] = {

            },
            [walk_animation_merge_options] = {

            },
            [interest_point_animation_merge_options] = {

            },

        },
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_spine1",
                    [3] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        [num_push_anims] = {
            [push_backward] = "2",

        },
        [run_speed] = "4.75",
        [using_first_attack] = true,
        [walk_speed] = "2.75",
        [perception_exceptions] = {
            [wizard_destructible] = true,
            [poison_well] = true,

        },
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },

    },
    [skaven_storm_vermin] = {
        [bots_should_flank] = true,
        [aoe_height] = "1.7",
        [base_unit] = "units/beings/enemies/skaven_stormvermin/chr_skaven_stormvermin",
        [behavior] = "storm_vermin",
        [is_bot_aid_threat] = true,
        [death_squad_detection_radius] = "8",
        [smart_targeting_width] = "0.20000000000000001",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [horde_target_selection] = "horde_pick_closest_target_with_spillover",
        [name] = "skaven_storm_vermin",
        [is_bot_threat] = true,
        [weapon_reach] = "2",
        [death_sound_event] = "Play_stormvermin_die_vce",
        [backstab_player_sound_event] = "Play_clan_rat_attack_player_back_vce",
        [attack_player_sound_event] = "Play_stormvermin_attack_vce",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "2",
        [poison_resistance] = "100",
        [target_selection] = "pick_closest_target_with_spillover",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "0",
            [4] = "170",

        },
        [perception_previous_attacker_stickyness_value] = "-4.5",
        [run_speed] = "4.7999999999999998",
        [has_running_attack] = true,
        [detection_radius] = "12",
        [unit_template] = "ai_unit_storm_vermin",
        [smart_targeting_outer_width] = "1",
        [radius] = "1",
        [panic_close_detection_radius_sq] = "9",
        [wwise_voices] = {
            [1] = "low",
            [2] = "medium",
            [3] = "high",

        },
        [hit_effect_template] = "HitEffectsStormVermin",
        [walk_speed] = "2",
        [patrol_detection_radius] = "10",
        [flingable] = true,
        [default_inventory_template] = "halberd",
        [animation_merge_options] = {
            [move_animation_merge_options] = {

            },
            [idle_animation_merge_options] = {

            },
            [walk_animation_merge_options] = {

            },

        },
        [perception] = "perception_regular",
        [max_health] = {
            [1] = "8",
            [2] = "9",
            [3] = "11",
            [4] = "14",
            [5] = "20",

        },
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.20000000000000001",
            [j_lefthand] = "0.20000000000000001",
            [j_spine] = "0.29999999999999999",
            [j_neck] = "0.29999999999999999",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.20000000000000001",
            [j_leftleg] = "0.20000000000000001",
            [j_rightupleg] = "0.20000000000000001",
            [j_tail5] = "0.050000000000000003",
            [j_spine1] = "0.29999999999999999",
            [j_leftfoot] = "0.20000000000000001",
            [j_rightleg] = "0.20000000000000001",
            [j_leftforearm] = "0.20000000000000001",
            [j_righthand] = "0.20000000000000001",
            [j_tail4] = "0.050000000000000003",
            [j_rightarm] = "0.20000000000000001",
            [j_leftupleg] = "0.20000000000000001",
            [j_rightshoulder] = "0.29999999999999999",
            [j_tail6] = "0.050000000000000003",
            [j_righttoebase] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_hips] = "0.29999999999999999",
            [j_leftarm] = "0.20000000000000001",
            [j_leftshoulder] = "0.29999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.20000000000000001",

        },
        [death_reaction] = "ai_default",
        [hit_reaction] = "ai_default",
        [aoe_radius] = "0.40000000000000002",
        [smart_targeting_height_multiplier] = "2.5",
        [size_variation_range] = {
            [1] = "1.05",
            [2] = "1.1499999999999999",

        },
        [horde_behavior] = "horde_vermin",
        run_on_death = "function(unit, blackboard)",
        [smart_object_template] = "special",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_spine1",
                    [3] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        [disable_crowd_dispersion] = true,
        [animation_sync_rpc] = "rpc_sync_anim_state_5",
        [exchange_order] = "3",
        [bone_lod_level] = "1",
        [attack_general_sound_event] = "Play_stormvermin_attack_vce",
        [num_push_anims] = {
            [push_backward] = "2",

        },
        [wwise_voice_switch_group] = "stormvermin_vce",
        [awards_positive_reinforcement_message] = true,
        [no_stagger_duration] = true,
        [using_first_attack] = true,
        [has_inventory] = true,
        [perception_exceptions] = {
            [wizard_destructible] = true,
            [poison_well] = true,

        },
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },

    },
    [skaven_storm_vermin_commander] = {
        [bots_should_flank] = true,
        [aoe_height] = "1.7",
        [base_unit] = "units/beings/enemies/skaven_stormvermin/chr_skaven_stormvermin",
        [behavior] = "storm_vermin_commander",
        [is_bot_aid_threat] = true,
        [death_squad_detection_radius] = "8",
        [smart_targeting_width] = "0.20000000000000001",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [horde_target_selection] = "horde_pick_closest_target_with_spillover",
        [name] = "skaven_storm_vermin_commander",
        [is_bot_threat] = true,
        [weapon_reach] = "2",
        [death_sound_event] = "Play_stormvermin_die_vce",
        [backstab_player_sound_event] = "Play_clan_rat_attack_player_back_vce",
        [attack_player_sound_event] = "Play_stormvermin_attack_vce",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "2",
        [poison_resistance] = "100",
        [target_selection] = "pick_closest_target_with_spillover",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "0",
            [4] = "170",

        },
        [perception_previous_attacker_stickyness_value] = "-4.5",
        [run_speed] = "4.7999999999999998",
        [has_running_attack] = true,
        [detection_radius] = "12",
        [unit_template] = "ai_unit_storm_vermin",
        [smart_targeting_outer_width] = "1",
        [radius] = "1",
        [panic_close_detection_radius_sq] = "9",
        [wwise_voices] = {
            [1] = "low",
            [2] = "medium",
            [3] = "high",

        },
        [hit_effect_template] = "HitEffectsStormVermin",
        [walk_speed] = "2",
        [patrol_detection_radius] = "10",
        [flingable] = true,
        [default_inventory_template] = "halberd",
        [animation_merge_options] = {
            [move_animation_merge_options] = {

            },
            [idle_animation_merge_options] = {

            },
            [walk_animation_merge_options] = {

            },

        },
        [perception] = "perception_regular",
        [max_health] = {
            [1] = "8",
            [2] = "9",
            [3] = "11",
            [4] = "14",
            [5] = "20",

        },
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.20000000000000001",
            [j_lefthand] = "0.20000000000000001",
            [j_spine] = "0.29999999999999999",
            [j_neck] = "0.29999999999999999",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.20000000000000001",
            [j_leftleg] = "0.20000000000000001",
            [j_rightupleg] = "0.20000000000000001",
            [j_tail5] = "0.050000000000000003",
            [j_spine1] = "0.29999999999999999",
            [j_leftfoot] = "0.20000000000000001",
            [j_rightleg] = "0.20000000000000001",
            [j_leftforearm] = "0.20000000000000001",
            [j_righthand] = "0.20000000000000001",
            [j_tail4] = "0.050000000000000003",
            [j_rightarm] = "0.20000000000000001",
            [j_leftupleg] = "0.20000000000000001",
            [j_rightshoulder] = "0.29999999999999999",
            [j_tail6] = "0.050000000000000003",
            [j_righttoebase] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_hips] = "0.29999999999999999",
            [j_leftarm] = "0.20000000000000001",
            [j_leftshoulder] = "0.29999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.20000000000000001",

        },
        [death_reaction] = "ai_default",
        [hit_reaction] = "ai_default",
        [aoe_radius] = "0.40000000000000002",
        [smart_targeting_height_multiplier] = "2.5",
        [size_variation_range] = {
            [1] = "1.05",
            [2] = "1.1499999999999999",

        },
        [horde_behavior] = "horde_vermin",
        run_on_death = "function(unit, blackboard)",
        [smart_object_template] = "special",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_spine1",
                    [3] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        [disable_crowd_dispersion] = true,
        [animation_sync_rpc] = "rpc_sync_anim_state_5",
        [exchange_order] = "3",
        [bone_lod_level] = "1",
        [attack_general_sound_event] = "Play_stormvermin_attack_vce",
        [num_push_anims] = {
            [push_backward] = "2",

        },
        [wwise_voice_switch_group] = "stormvermin_vce",
        [awards_positive_reinforcement_message] = true,
        [no_stagger_duration] = true,
        [using_first_attack] = true,
        [has_inventory] = true,
        [perception_exceptions] = {
            [wizard_destructible] = true,
            [poison_well] = true,

        },
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },

    },
    [skaven_slave] = {
        [aoe_height] = "1.2",
        [base_unit] = "units/beings/enemies/skaven_clan_rat/chr_skaven_slave",
        [behavior] = "pack_rat",
        [smart_targeting_width] = "0.10000000000000001",
        [use_backstab_vo] = true,
        [horde_target_selection] = "horde_pick_closest_target_with_spillover",
        [weapon_reach] = "2",
        [death_sound_event] = "Play_slave_rat_die_vce",
        [backstab_player_sound_event] = "Play_clan_rat_attack_player_back_vce",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "1",
        [poison_resistance] = "70",
        [debug_color] = {
            [1] = "255",
            [2] = "240",
            [3] = "90",
            [4] = "10",

        },
        [perception_previous_attacker_stickyness_value] = "-12.5",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [name] = "skaven_slave",
        [detection_radius] = "10",
        [unit_template] = "ai_unit_clan_rat",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_spine1",
                    [3] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        [radius] = "1.75",
        [passive_walk_speed] = "2",
        [wwise_voices] = {
            [1] = "slave_james",
            [2] = "slave_magnus",

        },
        [flingable] = true,
        [target_selection] = "pick_closest_target_with_spillover",
        [dialogue_source_name] = "skaven_slave",
        [max_health] = {
            [1] = "1",
            [2] = "1.5",
            [3] = "2",
            [4] = "3",
            [5] = "5",

        },
        [default_inventory_template] = "default",
        [attack_general_sound_event] = "Play_slave_rat_attack_vce",
        [scale_death_push] = "1",
        [bone_lod_level] = "1",
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.14999999999999999",
            [j_lefthand] = "0.14999999999999999",
            [j_spine] = "0.20000000000000001",
            [j_neck] = "0.20000000000000001",
            [j_righthand] = "0.14999999999999999",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.14999999999999999",
            [j_neck_1] = "0.20000000000000001",
            [j_rightupleg] = "0.14999999999999999",
            [j_tail5] = "0.050000000000000003",
            [j_leftforearm] = "0.14999999999999999",
            [j_leftleg] = "0.14999999999999999",
            [j_rightleg] = "0.14999999999999999",
            [j_leftfoot] = "0.14999999999999999",
            [j_hips] = "0.20000000000000001",
            [j_tail4] = "0.050000000000000003",
            [j_leftshoulder] = "0.20000000000000001",
            [j_righttoebase] = "0.14999999999999999",
            [j_rightshoulder] = "0.20000000000000001",
            [j_tail6] = "0.050000000000000003",
            [j_spine1] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_leftupleg] = "0.14999999999999999",
            [j_leftarm] = "0.14999999999999999",
            [j_rightarm] = "0.14999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.14999999999999999",

        },
        [num_push_anims] = {
            [push_backward] = "4",

        },
        [hit_reaction] = "ai_default",
        [walk_speed] = "2.5",
        [animation_merge_options] = {
            [idle_animation_merge_options] = {

            },
            [move_animation_merge_options] = {

            },
            [walk_animation_merge_options] = {

            },
            [interest_point_animation_merge_options] = {

            },

        },
        [size_variation_range] = {
            [1] = "0.84999999999999998",
            [2] = "0.94999999999999996",

        },
        [smart_targeting_outer_width] = "0.5",
        [hit_effect_template] = "HitEffectsSkavenClanRat",
        [opt_base_unit] = "units/beings/enemies/skaven_clan_rat/chr_skaven_slave_baked",
        [horde_behavior] = "horde_rat",
        [smart_targeting_height_multiplier] = "3",
        [animation_sync_rpc] = "rpc_sync_anim_state_7",
        [exchange_order] = "5",
        [smart_object_template] = "default_clan_rat",
        [death_reaction] = "ai_default",
        [perception] = "perception_regular",
        [has_running_attack] = true,
        [wwise_voice_switch_group] = "clan_rat_vce",
        [run_speed] = "4.25",
        [using_first_attack] = true,
        [has_inventory] = true,
        [attack_player_sound_event] = "Play_slave_rat_attack_vce",
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },

    },
    [skaven_loot_rat] = {
        [dodge_damage_points] = "20",
        [clean_spawn] = true,
        [base_unit] = "units/beings/enemies/skaven_loot_rat/chr_skaven_loot_rat",
        [behavior] = "loot_rat",
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.20000000000000001",
        [weapon_reach] = "1.6000000000000001",
        [dodge_crosshair_max_distance] = "30",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "1",
        [death_reaction] = "loot_rat",
        [proximity_system_check] = true,
        [debug_color] = {
            [1] = "255",
            [2] = "100",
            [3] = "200",
            [4] = "200",

        },
        [perception_previous_attacker_stickyness_value] = "0",
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.20000000000000001",
            [j_lefthand] = "0.20000000000000001",
            [j_spine] = "0.29999999999999999",
            [j_neck] = "0.29999999999999999",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.20000000000000001",
            [j_leftleg] = "0.20000000000000001",
            [j_rightupleg] = "0.20000000000000001",
            [j_tail5] = "0.050000000000000003",
            [j_spine1] = "0.29999999999999999",
            [j_leftfoot] = "0.20000000000000001",
            [j_rightleg] = "0.20000000000000001",
            [j_leftforearm] = "0.20000000000000001",
            [j_righthand] = "0.20000000000000001",
            [j_tail4] = "0.050000000000000003",
            [j_rightarm] = "0.20000000000000001",
            [j_leftupleg] = "0.20000000000000001",
            [j_rightshoulder] = "0.29999999999999999",
            [j_tail6] = "0.050000000000000003",
            [j_righttoebase] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_hips] = "0.29999999999999999",
            [j_leftarm] = "0.20000000000000001",
            [j_leftshoulder] = "0.29999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.20000000000000001",

        },
        [detection_radius] = "12",
        [unit_template] = "ai_unit_loot_rat",
        [run_speed] = "5",
        [radius] = "1",
        [target_selection] = "pick_closest_target",
        [smart_targeting_height_multiplier] = "3.5",
        [hit_effect_template] = "HitEffectsSkavenLootRat",
        [walk_speed] = "3",
        [smart_targeting_outer_width] = "0.59999999999999998",
        [dodge_cooldown] = "2",
        [default_inventory_template] = "loot_rat_sack",
        [target_selection_alerted] = "pick_closest_target_infinte_range",
        [wield_inventory_on_spawn] = true,
        [bone_lod_level] = "1",
        run_on_alerted = "function(unit, blackboard, alerting_unit, enemy_unit)",
        [dodge_crosshair_min_distance] = "4",
        [hit_reaction] = "ai_default",
        [dodge_crosshair_radius] = "1",
        [smart_object_template] = "special",
        [size_variation_range] = {
            [1] = "1",
            [2] = "1",

        },
        [allowed_layers] = {
            [fire_grenade] = "10",
            [planks] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [ledges_with_fence] = "10",
            [ledges] = "10",
            [jumps] = "10",
            [smoke_grenade] = "4",
            [bot_poison_wind] = "10",
            [bot_ratling_gun_fire] = "10",

        },
        [flingable] = true,
        [poison_resistance] = "70",
        run_on_stagger_action_done = "function(unit)",
        [perception] = "perception_regular",
        [animation_sync_rpc] = "rpc_sync_anim_state_3",
        [exchange_order] = "1",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_spine1",
                    [3] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },
        [dodge_crosshair_delay] = "0.10000000000000001",
        [max_health] = {
            [1] = "20",
            [2] = "30",
            [3] = "35",
            [4] = "40",
            [5] = "50",

        },
        [awards_positive_reinforcement_message] = true,
        [no_stagger_duration] = true,
        run_on_update = "function(unit, blackboard, t)",
        [has_inventory] = true,
        [name] = "skaven_loot_rat",
        [num_push_anims] = {
            [push_backward] = "4",

        },

    },
    [skaven_storm_vermin_champion] = {
        [aoe_height] = "1.7",
        [base_unit] = "units/beings/enemies/skaven_stormvermin_champion/chr_skaven_stormvermin_champion",
        [stagger_immune] = true,
        [override_mover_move_distance] = "1.5",
        [weapon_reach] = "2",
        [bot_opportunity_target_melee_range_while_ranged] = "5",
        [player_locomotion_constrain_radius] = "1",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [smart_object_template] = "special",
        [bot_optimal_melee_distance] = "2",
        [unit_template] = "ai_unit_storm_vermin_champion",
        [horde_behavior] = "storm_vermin_champion",
        [perception_weights] = {
            [target_disabled_mul] = "0.14999999999999999",
            [target_stickyness_bonus_b] = "10",
            [target_stickyness_bonus_a] = "50",
            [max_distance] = "50",
            [target_stickyness_duration_a] = "5",
            [distance_weight] = "10",
            [target_stickyness_duration_b] = "20",
            [target_outside_navmesh_mul] = "0.5",
            [aggro_decay_per_sec] = "10",
            [target_disabled_aggro_mul] = "0",
            [old_target_aggro_mul] = "1",
            [targeted_by_other_special] = "-10",
            [aggro_multipliers] = {
                [grenade] = "2",
                [melee] = "1",
                [ranged] = "3",

            },
            [target_catapulted_mul] = "0.5",

        },
        [smart_targeting_height_multiplier] = "2.5",
        [hit_effect_template] = "HitEffectsStormVerminChampion",
        run_on_husk_spawn = "function(unit)",
        [smart_targeting_outer_width] = "1",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        run_on_update = "function(unit, blackboard, t, dt)",
        [hit_reaction] = "ai_default",
        [exchange_order] = "1",
        [awards_positive_reinforcement_message] = true,
        [run_speed] = "6.1090909090909076",
        [has_inventory] = true,
        [name] = "skaven_storm_vermin_champion",
        [bots_should_flank] = true,
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [ward] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_trophy_rack_ward",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "2",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "2",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_spine1",
                    [3] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",

                },

            },
            [neck] = {
                [prio] = "2",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        run_on_spawn = "function(unit, blackboard)",
        [is_bot_aid_threat] = true,
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.20000000000000001",
        [death_sound_event] = "Play_stormvermin_die_vce",
        [armor_category] = "2",
        [poison_resistance] = "100",
        [proximity_system_check] = true,
        [disable_second_hit_ragdoll] = true,
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "0",
            [4] = "170",

        },
        [boss] = true,
        [radius] = "1",
        hot_join_sync = "function(sender, unit)",
        [dialogue_source_name] = "skaven_storm_vermin_champion",
        [default_inventory_template] = "halberd",
        [animation_merge_options] = {
            [move_animation_merge_options] = {

            },
            [idle_animation_merge_options] = {

            },
            [walk_animation_merge_options] = {

            },

        },
        [wield_inventory_on_spawn] = true,
        [bone_lod_level] = "1",
        [bot_opportunity_target_melee_range] = "7",
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },
        [size_variation_range] = {
            [1] = "1.3999999999999999",
            [2] = "1.3999999999999999",

        },
        [target_selection] = "pick_rat_ogre_target_with_weights",
        [no_stagger_duration] = true,
        [initial_is_passive] = false,
        run_on_despawn = "function(unit, blackboard)",
        [disable_crowd_dispersion] = true,
        [animation_sync_rpc] = "rpc_sync_anim_state_5",
        [behavior] = "storm_vermin_champion",
        [aoe_radius] = "0.59999999999999998",
        [angry_run_speed] = "6",
        [perception] = "perception_rat_ogre",
        [death_reaction] = "storm_vermin_champion",
        [has_running_attack] = true,
        [perception_continuous] = "perception_continuous_rat_ogre",
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.20000000000000001",
            [j_lefthand] = "0.20000000000000001",
            [j_spine] = "0.29999999999999999",
            [j_neck] = "0.29999999999999999",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.20000000000000001",
            [j_leftleg] = "0.20000000000000001",
            [j_rightupleg] = "0.20000000000000001",
            [j_tail5] = "0.050000000000000003",
            [j_spine1] = "0.29999999999999999",
            [j_leftfoot] = "0.20000000000000001",
            [j_rightleg] = "0.20000000000000001",
            [j_leftforearm] = "0.20000000000000001",
            [j_righthand] = "0.20000000000000001",
            [j_tail4] = "0.050000000000000003",
            [j_rightarm] = "0.20000000000000001",
            [j_leftupleg] = "0.20000000000000001",
            [j_rightshoulder] = "0.29999999999999999",
            [j_tail6] = "0.050000000000000003",
            [j_righttoebase] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_hips] = "0.29999999999999999",
            [j_leftarm] = "0.20000000000000001",
            [j_leftshoulder] = "0.29999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.20000000000000001",

        },
        [walk_speed] = "2",
        [max_health] = {
            [1] = "300",
            [2] = "350",
            [3] = "400",
            [4] = "500",
            [5] = "800",

        },
        [detection_radius] = "1.#INF",

    },
    [skaven_gutter_runner] = {
        [heroic_archetype_lookup] = {
            [decoy] = "1",

        },
        [base_unit] = "units/beings/enemies/skaven_gutter_runner/chr_skaven_gutter_runner",
        [behavior] = "gutter_runner",
        [is_bot_aid_threat] = true,
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.29999999999999999",
        [heroic_archetypes] = {
            [1] = {
                [health_multiplier] = "5",
                [behaviour] = "gutter_runner_heroic",
                [blackboard] = {
                    [ninja_vanish_at_health_percent] = "0.66666666666666663",
                    [ninja_vanish_at_health_percent_treshold] = "0.33333333333333331",

                },
                [breed_name] = "skaven_gutter_runner_decoy",
                [name] = "decoy",

            },

        },
        [jump_range] = "20",
        run_on_spawn = "function(unit, blackboard)",
        [debug_flag] = "ai_gutter_runner_behavior",
        [jump_gravity] = "9.8200000000000003",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "1",
        [poison_resistance] = "100",
        [proximity_system_check] = true,
        [force_despawn] = true,
        [smart_object_template] = "special",
        [combat_spawn_stinger] = "enemy_gutterrunner_stinger",
        [max_health] = {
            [1] = "10",
            [2] = "12",
            [3] = "14",
            [4] = "16",
            [5] = "20",

        },
        [initial_is_passive] = false,
        [walk_speed] = "3",
        [unit_template] = "ai_unit_gutter_runner",
        [target_selection] = "pick_ninja_approach_target",
        [radius] = "1",
        [perception_weights] = {
            [max_distance] = "40",
            [sticky_bonus] = "5",
            [dog_pile_penalty] = "-5",
            [distance_weight] = "10",

        },
        [smart_targeting_height_multiplier] = "1.6000000000000001",
        [flingable] = true,
        [has_inventory] = true,
        [smart_targeting_outer_width] = "0.59999999999999998",
        [run_speed] = "9",
        [default_inventory_template] = "gutter_runner",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [debug_class] = {
            update = "function(unit, blackboard, t)",
            debug_hud_background = "function(max_index)",
            debug_hud_print = "function(caption, value, index, valid)",

        },
        [bone_lod_level] = "1",
        [time_to_unspawn_after_death] = "1",
        [jump_speed] = "25",
        [pounce_bonus_dmg_per_meter] = "1",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightleg",
                    [2] = "c_rightupleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftleg",
                    [2] = "c_leftupleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_hips",
                    [2] = "c_spine",
                    [3] = "c_spine2",
                    [4] = "c_leftshoulder",
                    [5] = "c_rightshoulder",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },

        },
        [approaching_switch_radius] = "10",
        [size_variation_range] = {
            [1] = "1",
            [2] = "1",

        },
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "200",
            [4] = "0",

        },
        [allow_fence_jumping] = true,
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [hit_reaction] = "ai_default",
        [special] = true,
        [animation_sync_rpc] = "rpc_sync_anim_state_3",
        [exchange_order] = "2",
        [hit_effect_template] = "HitEffectsGutterRunner",
        [death_reaction] = "gutter_runner",
        [perception] = "perception_all_seeing_re_evaluate",
        [stagger_in_air_mover_check_radius] = "0.20000000000000001",
        [awards_positive_reinforcement_message] = true,
        [no_stagger_duration] = true,
        [disabled] = false,
        [pounce_impact_damage] = {
            [1] = "5",
            [2] = "7",

        },
        [name] = "skaven_gutter_runner",
        [detection_radius] = "9999999",

    },
    [critter_rat] = {
        [aoe_height] = "0.10000000000000001",
        [base_unit] = "units/beings/critters/chr_critter_common_rat/chr_critter_common_rat",
        [behavior] = "critter_rat",
        [disable_local_hit_reactions] = true,
        run_on_death = "function(unit, blackboard, t)",
        [weapon_reach] = "2",
        [perception] = "perception_regular",
        [death_reaction] = "ai_default",
        [debug_color] = {
            [1] = "255",
            [2] = "40",
            [3] = "90",
            [4] = "170",

        },
        [perception_previous_attacker_stickyness_value] = "0",
        [unit_template] = "ai_unit_critter",
        [radius] = "1",
        hot_join_sync = "function(sender, unit)",
        [hit_effect_template] = "HitEffectsCritterRat",
        run_on_husk_spawn = "function(unit, blackboard, t)",
        [allowed_layers] = {
            [fire_grenade] = "5",
            [bot_poison_wind] = "5",
            [smoke_grenade] = "4",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "5",
            [planks] = "1.5",

        },
        [bone_lod_level] = "1",
        [hit_reaction] = "ai_default",
        [smart_object_template] = "fallback",
        [cannot_far_path] = true,
        [size_variation_range] = {
            [1] = "0.90000000000000002",
            [2] = "1.1000000000000001",

        },
        [num_push_anims] = {
            [push_backward] = "4",

        },
        [max_health] = {
            [1] = "1",
            [2] = "1",
            [3] = "1",
            [4] = "1",
            [5] = "1",

        },
        [has_inventory] = false,
        [animation_merge_options] = {
            [idle_animation_merge_options] = {

            },
            [move_animation_merge_options] = {

            },

        },
        [aoe_radius] = "0.10000000000000001",
        [animation_sync_rpc] = "rpc_sync_anim_state_1",
        [exchange_order] = "1",
        [hit_zones] = {
            [torso] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",
                    [2] = "c_hips",
                    [3] = "c_spine",
                    [4] = "c_spine1",
                    [5] = "c_spine2",

                },
                [push_actors] = {
                    [1] = "c_spine2",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },

        },
        [target_selection] = "pick_closest_target",
        [poison_resistance] = "70",
        run_on_spawn = "function(unit, blackboard, t)",
        [not_bot_target] = true,
        [run_speed] = "6",
        [armor_category] = "1",
        [walk_speed] = "4",
        [name] = "critter_rat",
        [detection_radius] = "10",

    },
    [skaven_rat_ogre] = {
        [jump_slam_gravity] = "19",
        [bots_should_flank] = true,
        [aoe_height] = "2.3999999999999999",
        [is_bot_aid_threat] = true,
        [base_unit] = "units/beings/enemies/skaven_rat_ogre/chr_skaven_rat_ogre",
        [behavior] = "ogre",
        [perception_continuous] = "perception_continuous_rat_ogre",
        run_on_death = "function(unit, blackboard)",
        [override_mover_move_distance] = "1.5",
        [trigger_dialogue_on_target_switch] = true,
        [detection_radius] = "9999999",
        [far_off_despawn_immunity] = true,
        [target_selection_angry] = "pick_rat_ogre_target_with_weights",
        [target_selection] = "pick_rat_ogre_target_idle",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [blood_effect_name] = "fx/impact_blood_ogre",
        [combat_detect_player_stinger] = "enemy_ratogre_stinger",
        [bot_opportunity_target_melee_range_while_ranged] = "5",
        [player_locomotion_constrain_radius] = "1.5",
        [armor_category] = "3",
        [poison_resistance] = "100",
        [proximity_system_check] = true,
        [run_speed] = "7",
        [debug_color] = {
            [1] = "255",
            [2] = "20",
            [3] = "20",
            [4] = "20",

        },
        [combat_spawn_stinger] = "enemy_ratogre_stinger",
        [has_inventory] = true,
        [hit_reaction] = "ai_default",
        [smart_targeting_outer_width] = "1.3999999999999999",
        [unit_template] = "ai_unit_rat_ogre",
        [blood_intensity] = {
            [mtr_skin] = "blood_intensity",

        },
        [radius] = "2",
        [perception_weights] = {
            [target_disabled_mul] = "0.14999999999999999",
            [target_stickyness_bonus_b] = "10",
            [old_target_aggro_mul] = "1",
            [max_distance] = "50",
            [target_stickyness_bonus_a] = "50",
            [target_stickyness_duration_a] = "5",
            [target_outside_navmesh_mul] = "0.5",
            [aggro_decay_per_sec] = "1",
            [targeted_by_other_special] = "-10",
            [target_stickyness_duration_b] = "20",
            [target_disabled_aggro_mul] = "0",
            [distance_weight] = "100",
            [target_catapulted_mul] = "0.5",

        },
        [smart_targeting_height_multiplier] = "1.5",
        [boss_staggers] = true,
        [perception] = "perception_rat_ogre",
        [use_aggro] = true,
        [animation_sync_rpc] = "rpc_sync_anim_state_5",
        [default_inventory_template] = "rat_ogre",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [bone_lod_level] = "0",
        [max_health] = {
            [1] = "800",
            [2] = "1000",
            [3] = "1200",
            [4] = "1400",
            [5] = "2000",

        },
        [bot_opportunity_target_melee_range] = "7",
        [blood_effect_nodes] = {
            [1] = {
                [node] = "fx_wound_001",
                [triggered] = false,

            },
            [2] = {
                [node] = "fx_wound_002",
                [triggered] = false,

            },
            [3] = {
                [node] = "fx_wound_003",
                [triggered] = false,

            },
            [4] = {
                [node] = "fx_wound_004",
                [triggered] = false,

            },
            [5] = {
                [node] = "fx_wound_005",
                [triggered] = false,

            },
            [6] = {
                [node] = "fx_wound_006",
                [triggered] = false,

            },
            [7] = {
                [node] = "fx_wound_007",
                [triggered] = false,

            },
            [8] = {
                [node] = "fx_wound_008",
                [triggered] = false,

            },
            [9] = {
                [node] = "fx_wound_009",
                [triggered] = false,

            },
            [10] = {
                [node] = "fx_wound_010",
                [triggered] = false,

            },
            [11] = {
                [node] = "fx_wound_011",
                [triggered] = false,

            },
            [12] = {
                [node] = "fx_wound_012",
                [triggered] = false,

            },
            [13] = {
                [node] = "fx_wound_013",
                [triggered] = false,

            },

        },
        [ignore_nav_propagation_box] = true,
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine1",
                    [2] = "c_spine2",
                    [3] = "c_spine",
                    [4] = "c_hips",
                    [5] = "c_leftshoulder",
                    [6] = "c_rightshoulder",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck1",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },

        },
        [hit_effect_template] = "HitEffectsRatOgre",
        [use_avoidance] = false,
        [smart_object_template] = "rat_ogre",
        [num_forced_slams_at_target_switch] = "0",
        [death_reaction] = "ai_default",
        [reach_distance] = "3",
        [aoe_radius] = "1",
        [blackboard_init_data] = {
            [ladder_distance] = "1.#INF",

        },
        [exchange_order] = "1",
        [boss] = true,
        [bot_optimal_melee_distance] = "2",
        run_on_spawn = "function(unit, blackboard)",
        [smart_targeting_width] = "0.59999999999999998",
        [awards_positive_reinforcement_message] = true,
        [no_stagger_duration] = false,
        [chance_of_starting_angry] = "1",
        [walk_speed] = "5",
        [name] = "skaven_rat_ogre",
        [num_push_anims] = {

        },

    },
    [skaven_poison_wind_globadier] = {
        [base_unit] = "units/beings/enemies/skaven_wind_globadier/chr_skaven_wind_globadier",
        [behavior] = "skaven_poison_wind_globadier",
        [is_bot_aid_threat] = true,
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.29999999999999999",
        [death_sound_event] = "Play_globadier_death_vce",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [perception] = "perception_all_seeing",
        [poison_resistance] = "100",
        [proximity_system_check] = true,
        [smart_object_template] = "special",
        [unit_template] = "ai_unit_poison_wind_globadier",
        [radius] = "1",
        [debug_flag] = "ai_globadier_behavior",
        [smart_targeting_height_multiplier] = "2.2000000000000002",
        [flingable] = true,
        [smart_targeting_outer_width] = "0.69999999999999996",
        [special] = true,
        [allowed_layers] = {
            [fire_grenade] = "10",
            [planks] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [ledges_with_fence] = "5",
            [ledges] = "5",
            [jumps] = "5",
            [smoke_grenade] = "4",
            [bot_poison_wind] = "2",
            [bot_ratling_gun_fire] = "10",

        },
        [debug_class] = {
            update = "function(unit, blackboard, t)",
            debug_hud_background = "function(max_index)",
            debug_hud_print = "function(caption, value, index, valid)",

        },
        [max_health] = {
            [1] = "8",
            [2] = "10",
            [3] = "12",
            [4] = "16",
            [5] = "20",

        },
        [perception_continuous] = "perception_continuous_keep_target",
        [hit_reaction] = "ai_default",
        [detection_radius] = "9999999",
        [max_globe_throw_speed] = "16383",
        [no_stagger_duration] = true,
        [walk_speed] = "2.5",
        [disabled] = false,
        [scale_death_push] = "2",
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "200",
            [4] = "0",

        },
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightleg",
                    [2] = "c_rightupleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftleg",
                    [2] = "c_leftupleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_hips",
                    [2] = "c_spine",
                    [3] = "c_spine2",
                    [4] = "c_leftshoulder",
                    [5] = "c_rightshoulder",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [aux] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_compressor_valve",
                    [2] = "c_compressor",
                    [3] = "c_backpack_can",
                    [4] = "c_backpack_bag",
                    [5] = "c_ballsling_ball",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },

        },
        [animation_sync_rpc] = "rpc_sync_anim_state_3",
        [exchange_order] = "2",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [hit_effect_template] = "HitEffectsPoisonWind",
        [death_reaction] = "poison_globadier",
        [bone_lod_level] = "1",
        [awards_positive_reinforcement_message] = true,
        [run_speed] = "5",
        [armor_category] = "1",
        [target_selection] = "pick_closest_target",
        [name] = "skaven_poison_wind_globadier",
        [num_push_anims] = {
            [push_backward] = "1",

        },

    },
    [critter_pig] = {
        [aoe_height] = "0.5",
        [base_unit] = "units/beings/critters/chr_critter_pig/chr_critter_pig",
        [behavior] = "critter_pig",
        [disable_local_hit_reactions] = true,
        [weapon_reach] = "2",
        [perception] = "perception_no_seeing",
        [death_reaction] = "ai_default",
        [no_autoaim] = true,
        [debug_color] = {
            [1] = "255",
            [2] = "40",
            [3] = "90",
            [4] = "170",

        },
        [perception_previous_attacker_stickyness_value] = "0",
        [unit_template] = "ai_unit_critter",
        [radius] = "1",
        [hit_effect_template] = "HitEffectsCritterPig",
        [allowed_layers] = {

        },
        [bone_lod_level] = "1",
        [hit_reaction] = "ai_default",
        [smart_object_template] = "fallback",
        [cannot_far_path] = true,
        [walk_speed] = "4",
        [num_push_anims] = {
            [push_backward] = "4",

        },
        [max_health] = {
            [1] = "3",
            [2] = "3",
            [3] = "3",
            [4] = "3",
            [5] = "3",

        },
        [target_selection] = "pick_no_targets",
        [aoe_radius] = "0.25",
        [animation_sync_rpc] = "rpc_sync_anim_state_1",
        [exchange_order] = "1",
        [not_bot_target] = true,
        [animation_merge_options] = {
            [idle_animation_merge_options] = {

            },

        },
        [size_variation_range] = {
            [1] = "0.90000000000000002",
            [2] = "1.1000000000000001",

        },
        [poison_resistance] = "70",
        [armor_category] = "1",
        [run_speed] = "6",
        [hit_zones] = {
            [torso] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",
                    [2] = "c_hips",
                    [3] = "c_spine",
                    [4] = "c_spine1",
                    [5] = "c_spine2",

                },
                [push_actors] = {
                    [1] = "c_spine2",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },

        },
        [has_inventory] = false,
        [name] = "critter_pig",
        [detection_radius] = "10",

    },
    [skaven_grey_seer] = {
        [bots_should_flank] = true,
        [aoe_height] = "1.7",
        [base_unit] = "units/beings/enemies/skaven_grey_seer/chr_skaven_grey_seer",
        [behavior] = "grey_seer",
        [perception_continuous] = "perception_continuous_keep_target",
        [death_squad_detection_radius] = "1.#INF",
        [smart_targeting_width] = "0.20000000000000001",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [weapon_reach] = "2",
        [death_sound_event] = "Play_stormvermin_die_vce",
        [name] = "skaven_grey_seer",
        [is_bot_threat] = true,
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "1",
        [poison_resistance] = "100",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftshoulder",
                    [2] = "c_leftarm",
                    [3] = "c_leftforearm",
                    [4] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_leftshoulder",
                    [3] = "j_leftarm",
                    [4] = "j_leftforearm",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_neck_1",
                    [4] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",

                },
                [push_actors] = {
                    [1] = "j_neck",
                    [2] = "j_neck_1",
                    [3] = "j_spine1",
                    [4] = "j_hips",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightshoulder",
                    [2] = "c_rightarm",
                    [3] = "c_rightforearm",
                    [4] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",
                    [2] = "j_rightshoulder",
                    [3] = "j_rightarm",
                    [4] = "j_right_forearm",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",
                    [2] = "c_neck1",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_neck",
                    [3] = "j_neck_1",
                    [4] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",
                    [2] = "j_taill",

                },

            },

        },
        [target_selection] = "pick_closest_target",
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "0",
            [4] = "170",

        },
        [perception_previous_attacker_stickyness_value] = "-4.5",
        [weakspots] = {
            [head] = true,

        },
        [has_running_attack] = true,
        run_on_spawn = "function(unit, blackboard)",
        [unit_template] = "ai_unit_grey_seer",
        [smart_targeting_outer_width] = "1",
        [radius] = "1",
        [panic_close_detection_radius_sq] = "1.#INF",
        [smart_targeting_height_multiplier] = "2.5",
        [flingable] = false,
        [hit_effect_template] = "HitEffectsSkavenGreySeer",
        [patrol_detection_radius] = "1.#INF",
        [disable_crowd_dispersion] = true,
        [default_inventory_template] = "rat_ogre",
        [animation_merge_options] = {
            [move_animation_merge_options] = {

            },
            [idle_animation_merge_options] = {

            },
            [walk_animation_merge_options] = {

            },

        },
        [has_inventory] = true,
        [max_health] = {
            [1] = "2000",
            [2] = "2000",
            [3] = "2000",
            [4] = "2000",
            [5] = "2000",

        },
        [ragdoll_actor_thickness] = {
            [j_tail2] = "0.050000000000000003",
            [j_rightforearm] = "0.20000000000000001",
            [j_lefthand] = "0.20000000000000001",
            [j_neck1] = "0.29999999999999999",
            [j_spine1] = "0.29999999999999999",
            [j_righthand] = "0.20000000000000001",
            [j_head] = "0.29999999999999999",
            [j_lefttoebase] = "0.20000000000000001",
            [j_neck] = "0.29999999999999999",
            [j_rightupleg] = "0.20000000000000001",
            [j_tail5] = "0.050000000000000003",
            [j_leftforearm] = "0.20000000000000001",
            [j_leftleg] = "0.20000000000000001",
            [j_rightleg] = "0.20000000000000001",
            [j_leftshoulder] = "0.29999999999999999",
            [j_hips] = "0.29999999999999999",
            [j_tail4] = "0.050000000000000003",
            [j_rightarm] = "0.20000000000000001",
            [j_righttoebase] = "0.20000000000000001",
            [j_rightshoulder] = "0.29999999999999999",
            [j_tail6] = "0.050000000000000003",
            [j_leftfoot] = "0.20000000000000001",
            [j_tail3] = "0.050000000000000003",
            [j_leftupleg] = "0.20000000000000001",
            [j_leftarm] = "0.20000000000000001",
            [j_spine] = "0.29999999999999999",
            [j_taill] = "0.050000000000000003",
            [j_rightfoot] = "0.20000000000000001",

        },
        [ranged_shield] = {
            [hit_flow_event] = "lua_on_shielded_hit",
            [distance] = "4",

        },
        [hit_reaction] = "ai_default",
        [no_blood_splatter_on_damage] = true,
        [is_bot_aid_threat] = true,
        [size_variation_range] = {
            [1] = "1",
            [2] = "1",

        },
        [smart_object_template] = "special",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [death_reaction] = "ai_default",
        [perception] = "perception_all_seeing_re_evaluate",
        [aoe_radius] = "0.40000000000000002",
        [animation_sync_rpc] = "rpc_sync_anim_state_8",
        [exchange_order] = "3",
        [bone_lod_level] = "0",
        [num_push_anims] = {
            [push_backward] = "2",

        },
        [dialogue_source_name] = "skaven_grey_seer",
        [detection_radius] = "1.#INF",
        [awards_positive_reinforcement_message] = true,
        [run_speed] = "4.7999999999999998",
        [using_first_attack] = true,
        [walk_speed] = "2",
        [perception_exceptions] = {
            [wizard_destructible] = true,
            [poison_well] = true,

        },
        [hitbox_ragdoll_translation] = {
            [c_lefttoebase] = "j_lefttoebase",
            [c_hips] = "j_hips",
            [c_leftarm] = "j_leftarm",
            [c_rightforearm] = "j_rightforearm",
            [c_tail3] = "j_tail3",
            [c_neck] = "j_neck",
            [c_leftfoot] = "j_leftfoot",
            [c_righttoebase] = "j_righttoebase",
            [c_leftforearm] = "j_leftforearm",
            [c_head] = "j_head",
            [c_spine] = "j_spine",
            [c_tail4] = "j_tail4",
            [c_neck1] = "j_neck_1",
            [c_tail1] = "j_taill",
            [c_tail6] = "j_tail6",
            [c_rightfoot] = "j_rightfoot",
            [c_spine2] = "j_spine1",
            [c_leftleg] = "j_leftleg",
            [c_rightupleg] = "j_rightupleg",
            [c_lefthand] = "j_lefthand",
            [c_rightleg] = "j_rightleg",
            [c_tail2] = "j_tail2",
            [c_righthand] = "j_righthand",
            [c_tail5] = "j_tail5",
            [c_rightarm] = "j_rightarm",
            [c_leftupleg] = "j_leftupleg",

        },

    },
    [skaven_gutter_runner_decoy] = {
        [heroic_archetype_lookup] = {
            [decoy] = "1",

        },
        [base_unit] = "units/beings/enemies/skaven_gutter_runner/chr_skaven_gutter_runner",
        [behavior] = "gutter_runner_decoy",
        [is_bot_aid_threat] = true,
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.29999999999999999",
        [heroic_archetypes] = {
            [1] = {
                [health_multiplier] = "5",
                [behaviour] = "gutter_runner_heroic",
                [blackboard] = {
                    [ninja_vanish_at_health_percent] = "0.66666666666666663",
                    [ninja_vanish_at_health_percent_treshold] = "0.33333333333333331",

                },
                [breed_name] = "skaven_gutter_runner_decoy",
                [name] = "decoy",

            },

        },
        [jump_range] = "20",
        [debug_flag] = "ai_gutter_runner_behavior",
        [jump_gravity] = "9.8200000000000003",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "1",
        [poison_resistance] = "100",
        [proximity_system_check] = true,
        [force_despawn] = true,
        [smart_object_template] = "special",
        [combat_spawn_stinger] = "enemy_gutterrunner_stinger",
        [max_health] = {
            [1] = "1",
            [2] = "1",
            [3] = "1",
            [4] = "1",
            [5] = "1",

        },
        [initial_is_passive] = false,
        [walk_speed] = "3",
        [unit_template] = "ai_unit_gutter_runner",
        [target_selection] = "pick_ninja_approach_target",
        [radius] = "1",
        [perception_weights] = {
            [max_distance] = "40",
            [sticky_bonus] = "5",
            [dog_pile_penalty] = "-5",
            [distance_weight] = "10",

        },
        [smart_targeting_height_multiplier] = "1.6000000000000001",
        [flingable] = true,
        [has_inventory] = true,
        [smart_targeting_outer_width] = "0.59999999999999998",
        [run_speed] = "9",
        [default_inventory_template] = "gutter_runner",
        [allowed_layers] = {
            [fire_grenade] = "10",
            [bot_poison_wind] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [bot_ratling_gun_fire] = "3",
            [smoke_grenade] = "4",
            [ledges_with_fence] = "1.5",
            [jumps] = "1.5",
            [barrel_explosion] = "10",
            [ledges] = "1.5",
            [planks] = "1.5",

        },
        [debug_class] = {
            update = "function(unit, blackboard, t)",
            debug_hud_background = "function(max_index)",
            debug_hud_print = "function(caption, value, index, valid)",

        },
        [bone_lod_level] = "1",
        [time_to_unspawn_after_death] = "1",
        [jump_speed] = "25",
        [pounce_bonus_dmg_per_meter] = "1",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightleg",
                    [2] = "c_rightupleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftleg",
                    [2] = "c_leftupleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_hips",
                    [2] = "c_spine",
                    [3] = "c_spine2",
                    [4] = "c_leftshoulder",
                    [5] = "c_rightshoulder",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },

        },
        [approaching_switch_radius] = "10",
        [size_variation_range] = {
            [1] = "1",
            [2] = "1",

        },
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "200",
            [4] = "0",

        },
        [allow_fence_jumping] = true,
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [hit_reaction] = "ai_default",
        [special] = true,
        [animation_sync_rpc] = "rpc_sync_anim_state_3",
        [exchange_order] = "2",
        [hit_effect_template] = "HitEffectsGutterRunner",
        [death_reaction] = "gutter_runner_decoy",
        [perception] = "perception_all_seeing_re_evaluate",
        [stagger_in_air_mover_check_radius] = "0.20000000000000001",
        [awards_positive_reinforcement_message] = true,
        [no_stagger_duration] = true,
        [disabled] = false,
        [pounce_impact_damage] = {
            [1] = "5",
            [2] = "7",

        },
        [name] = "skaven_gutter_runner_decoy",
        [detection_radius] = "9999999",

    },
    [skaven_pack_master] = {
        [base_unit] = "units/beings/enemies/skaven_pack_master/chr_skaven_pack_master",
        [behavior] = "pack_master",
        [is_bot_aid_threat] = true,
        run_on_death = "function(unit, blackboard)",
        [smart_targeting_width] = "0.20000000000000001",
        [weapon_reach] = "5",
        [player_locomotion_constrain_radius] = "0.69999999999999996",
        [armor_category] = "3",
        [death_reaction] = "ai_default",
        [proximity_system_check] = true,
        [smart_object_template] = "special",
        [unit_template] = "ai_unit_pack_master",
        [radius] = "1",
        [smart_targeting_height_multiplier] = "3",
        [flingable] = false,
        [smart_targeting_outer_width] = "0.59999999999999998",
        [default_inventory_template] = "pack_master",
        [allowed_layers] = {
            [fire_grenade] = "15",
            [planks] = "1.5",
            [teleporters] = "5",
            [doors] = "1.5",
            [ledges_with_fence] = "1.5",
            [ledges] = "1.5",
            [jumps] = "1.5",
            [smoke_grenade] = "10",
            [bot_poison_wind] = "15",
            [bot_ratling_gun_fire] = "15",

        },
        [wield_inventory_on_spawn] = true,
        [max_health] = {
            [1] = "16",
            [2] = "20",
            [3] = "24",
            [4] = "28",
            [5] = "36",

        },
        [hit_reaction] = "ai_default",
        [disabled] = false,
        [detection_radius] = "12",
        [size_variation_range] = {
            [1] = "1",
            [2] = "1",

        },
        [walk_speed] = "2.25",
        [has_inventory] = true,
        [perception] = "perception_pack_master",
        [debug_color] = {
            [1] = "255",
            [2] = "200",
            [3] = "200",
            [4] = "0",

        },
        [bone_lod_level] = "1",
        [animation_sync_rpc] = "rpc_sync_anim_state_5",
        [exchange_order] = "2",
        [poison_resistance] = "100",
        [headshot_coop_stamina_fatigue_type] = "headshot_special",
        [hit_effect_template] = "HitEffectsSkavenPackMaster",
        [hit_zones] = {
            [left_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftarm",
                    [2] = "c_leftforearm",
                    [3] = "c_lefthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [right_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightupleg",
                    [2] = "c_rightleg",
                    [3] = "c_rightfoot",
                    [4] = "c_righttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [afro] = {
                [prio] = "5",
                [actors] = {
                    [1] = "c_afro",

                },

            },
            [head] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_head",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [left_leg] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_leftupleg",
                    [2] = "c_leftleg",
                    [3] = "c_leftfoot",
                    [4] = "c_lefttoebase",

                },
                [push_actors] = {
                    [1] = "j_leftfoot",
                    [2] = "j_rightfoot",
                    [3] = "j_hips",

                },

            },
            [full] = {
                [prio] = "1",
                [actors] = {

                },

            },
            [neck] = {
                [prio] = "1",
                [actors] = {
                    [1] = "c_neck",

                },
                [push_actors] = {
                    [1] = "j_head",
                    [2] = "j_spine1",

                },

            },
            [torso] = {
                [prio] = "3",
                [actors] = {
                    [1] = "c_spine2",
                    [2] = "c_spine",
                    [3] = "c_hips",
                    [4] = "c_leftshoulder",
                    [5] = "c_rightshoulder",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [aux] = {
                [prio] = "6",
                [actors] = {
                    [1] = "c_backpack",

                },

            },
            [right_arm] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_rightarm",
                    [2] = "c_rightforearm",
                    [3] = "c_righthand",

                },
                [push_actors] = {
                    [1] = "j_spine1",

                },

            },
            [tail] = {
                [prio] = "4",
                [actors] = {
                    [1] = "c_tail1",
                    [2] = "c_tail2",
                    [3] = "c_tail3",
                    [4] = "c_tail4",
                    [5] = "c_tail5",
                    [6] = "c_tail6",

                },
                [push_actors] = {
                    [1] = "j_hips",

                },

            },

        },
        [awards_positive_reinforcement_message] = true,
        [run_speed] = "5",
        [special] = true,
        [target_selection] = "pick_pack_master_target",
        [name] = "skaven_pack_master",
        [num_push_anims] = {
            [push_backward] = "4",

        },

    },

}
