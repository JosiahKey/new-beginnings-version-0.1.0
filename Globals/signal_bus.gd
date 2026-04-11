extends Node
#next level to levelmanager
signal load_area_entered
#interctable to item generator
signal item_generated
#itemgenerator to inventorypanel
signal item_collected
#inventorypanel to equippanel
signal item_equipped
#equippanel/levelup to statpanel
signal update_stat_panel
#itemgenerator to inventory
signal item_added
#enemy to combat
signal hit_player
#player to enemy
signal start_enemy_turn
#enemy to player
signal end_enemy_turn
#enemy to combatui
signal combat_victory
#enemy_interactable to main
signal enemy_encountered
#combatui to main
signal game_over
#enemy interactable to scene transition
signal combat_entered
#combat to scene transition
signal combat_exited
#combatui to combatengine
signal scene_transition_finished
#enemy to combat
signal miss_player
#combat to levelup
signal levelup
#itemgen to combat
signal update_reward_item
#inventoryitem to equippanel
signal highlight_slot
#inventoryitem to equippanel
signal unhighlight_slot
#chest to main
signal reward
#levelup ui to combat(reward)
signal check_for_levelup
#combatant to combat_engine
signal turn_start
#combatant to combat_engine
signal turn_finished
#combatant to combat_engine
signal combat_action
#enemy to combat_engine
signal enemy_selected
#enemy to combatplayer
signal action_resolved
#combatplayer to combatui
signal player_hp_changed
#enemy_interactable to player
signal player_paused
#combatdata to combatui
signal num_enemies_changed
#levelup to combatreward
signal exp_finished
#combat_engine to equip_panel
signal player_died
#equip_panel to combat_engine
signal gameover_item_deleted
#chest to itemgenerator
signal reward_generated
#anywhere to world_map
signal world_map_entered
#action_button to combat ui
signal action_button_pressed
#action button to combat engine
signal player_action_selected
