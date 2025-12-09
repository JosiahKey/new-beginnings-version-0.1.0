extends NinePatchRect

@onready var  max_hp_label = $M/V/Stat_Grid/Health_Points_Stat_Label/stat_num
@onready var  acc_label = $M/V/Stat_Grid/Accuracy_Stat_Label/stat_num
@onready var  eva_label = $M/V/Stat_Grid/Evasion_Stat_Label/stat_num
@onready var  pdr_label = $M/V/Stat_Grid/PDR_Stat_Label/stat_num
@onready var  spd_label = $M/V/Stat_Grid/Speed_Stat_Label/stat_num
@onready var  stren_label = $M/V/Stat_Grid/Strength_Stat_Label/stat_num
@onready var  dmg_label = $M/V/Stat_Grid/Damage_Stat_Label/stat_num
@onready var  weight_label = $M/V/Stat_Grid/Weight_Stat_Label/stat_num

func _ready() -> void:
	SignalBus.connect("equipment_updated", Callable(self, "_update_stat_panel"))
	_update_stat_panel()

func _process(_delta: float) -> void:
	max_hp_label.text = str(int(PlayerData.stat_data["Total_hp"])) + " / " + str(
		PlayerData.stat_data["Current_hp"])

func _update_stat_panel():
	acc_label.text = str(PlayerData.stat_data["Accuracy"])
	eva_label.text = str(PlayerData.stat_data["Evasion"])
	pdr_label.text = str(PlayerData.stat_data["PDR"])
	stren_label.text = str(PlayerData.stat_data["Strength"])
	spd_label.text = str(int(PlayerData.stat_data["Speed"]))
	max_hp_label.text = str(int(PlayerData.stat_data["Total_hp"])) + " / " + str(
		PlayerData.stat_data["Current_hp"])
	dmg_label.text = str(int(PlayerData.stat_data["Total_equipped_damage_min"])) + " - " + str(int(
						PlayerData.stat_data["Total_equipped_damage_max"]))
	weight_label.text = str(int(PlayerData.stat_data["Total_equipped_weight"]))
