extends Node

var item_data = {
	66666: { "item_rarity": "legendary", 
	"item_name": "sword_legendary", 
	"equipmentSlot": "Mainhand", 
	"Type": "Weapon", 
	"Damage_min": 100.0, 
	"Damage_max": 200.0, 
	"Accuracy": 100.0, 
	"Evasion": 0, 
	"Hp": 0, 
	"PDR": 0, 
	"Strength": 0, 
	"Speed": 0.0 
	}
}
var base_item_data = {}

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
	var enemy_data_file = FileAccess.open("res://Data/enemy_data.json", FileAccess.READ)
	var enemy_data_json = JSON.parse_string(enemy_data_file.get_as_text())
	enemy_data_file.close()
	enemy_data = enemy_data_json
