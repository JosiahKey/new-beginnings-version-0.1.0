extends Node

var number_of_enemies = 0

var combatants_data: Dictionary = {
	"player" : PlayerData.stat_data,
	#"enemy1" : data generated from enemy.gd init
}

func _ready() -> void:
	pass

func add_combatant(new_combatant: Dictionary) -> String:
	number_of_enemies += 1
	var new_id: String = "enemy" + str(number_of_enemies)
	var new_dict: Dictionary = {new_id : new_combatant}
	combatants_data.merge(new_dict)
	return new_id

func clear_data():
	combatants_data = {"player" : PlayerData.stat_data,}
	number_of_enemies = 0
