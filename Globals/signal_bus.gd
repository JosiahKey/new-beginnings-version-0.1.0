extends Node
#main to interactable
@warning_ignore("unused_signal")
signal load_area_entered
#interactable to item generator
@warning_ignore("unused_signal")
signal item_generated
#itemgenerator to inventorypanel
@warning_ignore("unused_signal")
signal item_collected
#inventory to equippanel
@warning_ignore("unused_signal")
signal item_equipped
#equippanel to statpanel
@warning_ignore("unused_signal")
signal equipment_updated
#itemgenerator to inventory
@warning_ignore("unused_signal")
signal item_added
#enemy to player stats
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
