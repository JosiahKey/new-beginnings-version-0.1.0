extends Node

var item_data = {}
var debug_item_data = {
	"10001": {
	"name": "dagger",
	"Damage_min": 1,
	"Damage_max": 2,
	"Accuracy": 1,
	"Evasion": 0,
	"Hp": 0,
	"PDR": 0,
	"Weight": 1,
	"equipmentSlot": "Mainhand",
	"commonMulti": 10,
	"uncommonMulti": 2,
	"rareMulti": 3,
	"epicMulti": 4,
	"legendaryMulti": 5
  },
}
var item_stats = ["Damage_min", "Damage_max", "Accuracy", "Evasion", "Hp", "PDR", "Weight"]
var item_stats_readable = ["Minimum Damage", "Maximum Damage", "Hit Chance", "Evasion", "Hp", "PDR", "Weight"]
var item_scaling_stats = ["Damage_min", "Damage_max", "Accuracy", "Evasion", "Hp", "PDR"]

var item_rarity_ditribution = {"common": 60,
	"uncommon": 27,
	"rare": 9,
	"epic": 3,
	"legendary": 1}

func _ready() -> void:
	var item_data_file = FileAccess.open("res://Data/item_data2.json", FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	item_data = debug_item_data #item_data_json
