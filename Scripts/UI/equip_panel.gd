extends NinePatchRect

@onready var grid_ref := $GridContainer

func _ready() -> void:
	SignalBus.connect("item_equipped", Callable(self, "_update_equipped_stats"))
	_update_equipped_items()
	SignalBus.item_equipped.emit()

func _update_equipped_items():
	for i in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[i] != null:
			var item_name:String  = GameData.item_data[str(int(PlayerData.equipment_data[i]))]["name"]
			var icon_texture:Texture =  load("res://Assets/item_assets/"+ item_name +".png")
			print("TextureRect" +str(i)+ "/" + str(i) + "/Icon")
			grid_ref.get_node(str(i)+ "/" + str(i) + "/Icon").texture = icon_texture

func _update_equipped_stats():
	PlayerData.stat_data["Total_equipped_weight"] = 0
	PlayerData.stat_data["Total_equipped_damage_min"] = 0
	PlayerData.stat_data["Total_equipped_damage_max"] = 0
	PlayerData.stat_data["Bonus_hp"] = 0
	PlayerData.stat_data["Accuracy"] = 0
	PlayerData.stat_data["Evasion"] = 0
	PlayerData.stat_data["PDR"] = 0


	for i in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[i] != null:
			PlayerData.stat_data["Bonus_hp"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["Hp"]
			PlayerData.stat_data["Accuracy"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["Accuracy"]
			PlayerData.stat_data["Evasion"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["Evasion"]
			PlayerData.stat_data["PDR"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["PDR"]
			PlayerData.stat_data["Total_equipped_weight"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["Weight"]
			PlayerData.stat_data["Total_equipped_damage_min"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["Damage_min"]
			PlayerData.stat_data["Total_equipped_damage_max"] += GameData.item_data[
									str(int(PlayerData.equipment_data[i]))]["Damage_max"]
	PlayerData.stat_data["Total_hp"] = PlayerData.stat_data["Natural_hp"] + PlayerData.stat_data["Bonus_hp"]
	SignalBus.equipment_updated.emit()
