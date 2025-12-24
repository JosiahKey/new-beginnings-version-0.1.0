extends Node

var inv_data = {}

var stat_data = {
	"Natural_hp": 30,
	"Strength": 0,
	"Bonus_hp": 0,
	"Total_hp": 0,
	"Current_hp": 25,
	"Accuracy": 0,
	"Evasion": 0,
	"PDR": 0,
	"Total_equipped_damage_min": 0,
	"Total_equipped_damage_max": 0,
	"Speed": 0,
	"Total_equipped_weight": 0,
	"Experience": 0,
	"Exp_to_next_level": 100,
	"Level": 1
}

var equipment_data = {
	"Head": 0,
	"Neck": 0,
	"Shoulders": 0,
	"Chest": 0,
	"Mainhand": 10002,
	"Offhand": 0,
	"Ring1": 0,
	"Arms": 0,
	"Waist": 0,
	"Legs": 0,
	"Feet": 0,
}

func _ready() -> void:
	_load_inv_data()
	stat_data["Total_hp"] = stat_data["Natural_hp"] + stat_data["Bonus_hp"]
	

func _load_inv_data():
	var inv_data_file = FileAccess.open("user://inv_data.json", FileAccess.READ)
	var inv_data_json = JSON.parse_string(inv_data_file.get_as_text())
	inv_data_file.close()
	inv_data = inv_data_json
	for k in inv_data.keys():
		inv_data[k]["Item"] = int(str(inv_data[k]["Item"]))


func _save_inv_data():
	var inv_data_file = FileAccess.open("user://inv_data.json", FileAccess.READ)
	var inv_data_json = JSON.stringify(inv_data)
	inv_data_file.store_string(inv_data_json)
	inv_data_file.close()
