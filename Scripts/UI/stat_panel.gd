extends NinePatchRect

@onready var  max_hp_label = $M/V/Stat_Grid/Health_Points_Stat_Label/stat_num
@onready var  acc_label = $M/V/Stat_Grid/Accuracy_Stat_Label/stat_num
@onready var  eva_label = $M/V/Stat_Grid/Evasion_Stat_Label/stat_num
@onready var  pdr_label = $M/V/Stat_Grid/PDR_Stat_Label/stat_num
@onready var  spd_label = $M/V/Stat_Grid/Speed_Stat_Label/stat_num
@onready var  stren_label = $M/V/Stat_Grid/Strength_Stat_Label/stat_num
@onready var  dmg_label = $M/V/Stat_Grid/Damage_Stat_Label/stat_num
@onready var  weight_label = $M/V/Stat_Grid/Weight_Stat_Label/stat_num
@onready var  exp_bar = $M/V/H/Exp_Bar
@onready var  exp_bar_label = $M/V/H/Exp_Bar/exp_bar_label

func _ready() -> void:
	SignalBus.connect("update_stat_panel", Callable(self, "_update_stat_panel"))
	_update_stat_panel()

func _process(_delta: float) -> void:
	max_hp_label.text = str(PlayerData.stat_data["Current_hp"]) + " / " + str(int(
		PlayerData.stat_data["Total_hp"]))

func _update_stat_panel():
	PlayerData.stat_data["Total_hp"] = PlayerData.stat_data["Natural_hp"] + PlayerData.stat_data["Bonus_hp"]
	acc_label.text = str(PlayerData.stat_data["Accuracy"]) + "%"
	eva_label.text = str(PlayerData.stat_data["Evasion"])+ "%"
	pdr_label.text = str(PlayerData.stat_data["PDR"])+ "%"
	stren_label.text = str(PlayerData.stat_data["Strength"])
	spd_label.text = str(int(PlayerData.stat_data["Speed"])) + "{not used}"
	max_hp_label.text = str(PlayerData.stat_data["Current_hp"]) + " / " + str(int(
		PlayerData.stat_data["Total_hp"]))
	dmg_label.text = str(int(PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.stat_data["Strength"])) + " - " + str(int(
						PlayerData.stat_data["Total_equipped_damage_max"]+ PlayerData.stat_data["Strength"]))
	weight_label.text = str(int(PlayerData.stat_data["Total_equipped_weight"]))
	exp_bar_label.text = str(PlayerData.stat_data["Experience"]) + " / " + str(PlayerData.stat_data["Exp_to_next_level"])
	exp_bar.max_value = PlayerData.stat_data["Exp_to_next_level"]
	exp_bar.value = PlayerData.stat_data["Experience"]
