extends Node
#next level to levelmanager
@warning_ignore("unused_signal")
signal load_area_entered
#interactable to item generator
@warning_ignore("unused_signal")
signal item_generated
#itemgenerator to inventorypanel
@warning_ignore("unused_signal")
signal item_collected
#inventorypanel to equippanel
@warning_ignore("unused_signal")
signal item_equipped
#equippanel/levelup to statpanel
@warning_ignore("unused_signal")
signal update_stat_panel
#itemgenerator to inventory
@warning_ignore("unused_signal")
signal item_added
#enemy to combat
@warning_ignore("unused_signal")
signal hit_player
#player to enemy
@warning_ignore("unused_signal")
signal start_enemy_turn
#enemy to player
@warning_ignore("unused_signal")
signal end_enemy_turn
#enemy to combatui
@warning_ignore("unused_signal")
signal combat_victory
#enemy_interactable to main
@warning_ignore("unused_signal")
signal enemy_encountered
#combatui to main
@warning_ignore("unused_signal")
signal game_over
#enemy interactable to scene transition
@warning_ignore("unused_signal")
signal combat_entered
#combat to scene transition
@warning_ignore("unused_signal")
signal combat_exited
#combatui to combatengine
@warning_ignore("unused_signal")
signal scene_transition_finished
#enemy to combat
@warning_ignore("unused_signal")
signal miss_player
#combat to levelup
@warning_ignore("unused_signal")
signal levelup
#itemgen to combat
@warning_ignore("unused_signal")
signal update_reward_item
#inventoryitem to equippanel
@warning_ignore("unused_signal")
signal highlight_slot
#inventoryitem to equippanel
@warning_ignore("unused_signal")
signal unhighlight_slot
#chest to main
@warning_ignore("unused_signal")
signal reward
#levelup ui to combat(reward)
@warning_ignore("unused_signal")
signal check_for_levelup
#combatant to combat_engine
@warning_ignore("unused_signal")
signal turn_start
#combatant to combat_engine
@warning_ignore("unused_signal")
signal turn_finished
#combatant to combat_engine
@warning_ignore("unused_signal")
signal combat_action
#enemy to combat_engine
@warning_ignore("unused_signal")
signal enemy_selected
#enemy to combatplayer
@warning_ignore("unused_signal")
signal action_resolved
#combatplayer to combatui
@warning_ignore("unused_signal")
signal player_hp_changed
#enemy_interactable to player
@warning_ignore("unused_signal")
signal player_paused
#combatdata to combatui
@warning_ignore("unused_signal")
signal num_enemies_changed
#levelup to combatreward
@warning_ignore("unused_signal")
signal exp_finished
#combat_engine to equip_panel
@warning_ignore("unused_signal")
signal player_died
#equip_panel to combat_engine
@warning_ignore("unused_signal")
signal gameover_item_deleted
#chest to itemgenerator
@warning_ignore("unused_signal")
signal reward_generated
#anywhere to world_map
@warning_ignore("unused_signal")
signal world_map_entered
