extends Node

var inv_data = {}

var stat_data = {
	"Natural_hp": 30,
	"Strength": 0,
	"Bonus_hp": 0,
	"Total_hp": 0,
	"Current_hp": 29,
	"Accuracy": 0,
	"Evasion": 0,
	"PDR": 0,
	"Total_equipped_damage_min": 0,
	"Total_equipped_damage_max": 0,
	"Speed": 1,
	"Total_equipped_weight": 1,
	"Experience": 0,
}

var equipment_data = {
	"Head": null,
	"Neck": null,
	"Shoulders": null,
	"Chest": null,
	"Mainhand": 10001,
	"Offhand": null,
	"Ring1": null,
	"Ring2": null,
	"Waist": null,
	"Legs": null,
	"Feet": null,
}

func _ready() -> void:
	_load_inv_data()
	stat_data["Total_hp"] = stat_data["Natural_hp"] + stat_data["Bonus_hp"]
	

func _load_inv_data():
	var inv_data_file = FileAccess.open("user://inv_data.json", FileAccess.READ)
	var inv_data_json = JSON.parse_string(inv_data_file.get_as_text())
	inv_data_file.close()
	inv_data = inv_data_json

func _save_inv_data():
	var inv_data_file = FileAccess.open("user://inv_data.json", FileAccess.READ)
	var inv_data_json = JSON.stringify(inv_data)
	inv_data_file.store_string(inv_data_json)
	inv_data_file.close()
