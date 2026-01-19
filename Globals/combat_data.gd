extends Node

var number_of_enemies = 0

var combatants_data: Dictionary = {
	"player" : PlayerData.stat_data,
	#"enemy1" : data generated from enemy.gd init
}

var reward_data: Array = [0,0,0,0,0,0] #[exp, loot1, loot2, etc...]

func add_reward(experience: int, loot: int):
	reward_data[0] += experience
	for r in reward_data:
		if r == 0:
			r = loot
			break

func add_combatant(new_combatant: Dictionary) -> String:
	number_of_enemies += 1
	var new_id: String = "enemy" + str(number_of_enemies)
	var new_dict: Dictionary = {new_id : new_combatant.duplicate()}
	combatants_data.merge(new_dict)
	return new_id

func clear_data():
	combatants_data = {"player" : PlayerData.stat_data,}
	number_of_enemies = 0
	reward_data = [0,0,0,0,0,0]
