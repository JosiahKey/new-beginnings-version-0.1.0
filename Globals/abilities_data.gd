extends Node

var abilities_data = {
	10001: {"Ability_type": "Single_attack",  
	"Ability_rarity": "common", 
	"Ability_requirements": [0,0,0], 
	"Damage_min_flat": 0,
	"Damage_scaling_stat": "",
	"Stat_damage_multiplier" : 0.0, 
	"Final_damage_multiplier": 1, 
	"Accuracy_flat": 0,
	"Hp_change": 0,
	},
	10002: {"Ability_type": "Aoe_attack",  
	"Ability_rarity": "common", 
	"Ability_requirements": [0,0,0], 
	"Damage_min_flat": 0, 
	"Damage_scaling_stat": "",
	"Stat_damage_multiplier" : 0.0,
	"Final_damage_multiplier": 0.3, 
	"Accuracy_flat": 5,
	"Hp_change": 0,
	},
	10003: {"Ability_type": "Single_attack",  
	"Ability_rarity": "common", 
	"Ability_requirements": [0,0,0], 
	"Damage_min_flat": 0, 
	"Damage_scaling_stat": "Strength",
	"Stat_damage_multiplier" : 25,
	"Final_damage_multiplier": 1,
	"Accuracy_flat": -20,
	"Hp_change_multi": -0.1,
	},
}

func _ready() -> void:
	pass # Replace with function body.
