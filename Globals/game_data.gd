extends Node

var item_data = {
	10002: {
	"item_rarity": "common",
	"item_name": "sword_common",
	"equipmentSlot": "Mainhand",
	"Damage_min": 1,
	"Damage_max": 4,
	"Accuracy": 95,
	"Evasion": 0,
	"Hp": 0,
	"PDR": 0,
	"Strength": 0,
	"Speed": 0,
	"Weight": 0,
	},
}
var base_item_data = {
	"10001": { #sample item for reference. overwritten on line 36
	"name": "dagger",
	"Damage_min": 1,
	"Damage_max": 2,
	"Accuracy": 1,
	"Evasion": 0,
	"Hp": 0,
	"PDR": 0,
	"Weight": 1,
	"equipmentSlot": "Offhand",
	"commonMulti": 10,
	"uncommonMulti": 2,
	"rareMulti": 3,
	"epicMulti": 4,
	"legendaryMulti": 5
  },
}
var item_stats = ["Damage_min", "Damage_max", "Accuracy", "Evasion", "Hp", "PDR", "Strength", "Speed"] #Weight
var item_stats_readable = ["Minimum Damage", "Maximum Damage", "Hit Chance", "Evasion", "Hp", "Armor", "Strength", "Speed"] #"Weight"
var item_scaling_stats = ["Damage_min", "Damage_max", "Evasion", "Hp", "PDR", "Strength", "Speed"]
var item_randomized_stats = ["Damage_min", "Damage_max", "Accuracy", "Evasion", "Hp", "PDR", "Strength", "Speed"]
var weapon_randomized_stats = ["Evasion", "Hp", "PDR", "Strength", "Speed"]

var item_rarity_ditribution = {"common": 80.0,
	"uncommon": 15.0,
	"rare": 3.0,
	"epic": 1.8,
	"legendary": 0.2}

var enemy_data = {
		10001: {
		"enemy_name": "GreenSlime",
		"Max_hp": 10,
		"Current_hp": 10,
		"Damage_min": 1,
		"Damage_max": 6,
		"Accuracy": 50,
		"Evasion": 5,
		"PDR": 0,
		"Speed": 1,
		"EXP": 50.0
		},
	}

func _ready() -> void:
	var item_data_file = FileAccess.open("res://Data/items_data.json", FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	base_item_data = item_data_json
