extends NinePatchRect

@onready var grid_ref := $GridContainer

func _ready() -> void:
	SignalBus.connect("item_equipped", Callable(self, "_update_equipped_stats"))
	SignalBus.connect("highlight_slot", Callable(self, "highlight_slot"))
	SignalBus.connect("unhighlight_slot", Callable(self, "unhighlight_slot"))
	PlayerData.stat_data["Total_equipped_weight"] = 0
	PlayerData.stat_data["Total_equipped_damage_min"] = 0
	PlayerData.stat_data["Total_equipped_damage_max"] = 0
	PlayerData.stat_data["Bonus_hp"] = 0
	PlayerData.stat_data["Accuracy"] = 0
	PlayerData.stat_data["Evasion"] = 0
	PlayerData.stat_data["PDR"] = 0
	_update_equipped_items()
	_update_equipped_stats()

func _update_equipped_items():
	for i in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[i] != null and GameData.item_data.has(PlayerData.equipment_data[i]):
			var item_name:String  = GameData.item_data[PlayerData.equipment_data[i]]["item_name"]
			var icon_texture:Texture =  load("res://Assets/item_assets/"+ item_name +".png")
			grid_ref.get_node(str(i)+ "/" + str(i) + "/Icon").texture = icon_texture

func _update_equipped_stats():
	get_node("equip").playing = true
	PlayerData.stat_data["Total_equipped_weight"] = 0
	PlayerData.stat_data["Total_equipped_damage_min"] = 0
	PlayerData.stat_data["Total_equipped_damage_max"] = 0
	PlayerData.stat_data["Bonus_hp"] = 0
	PlayerData.stat_data["Accuracy"] = 0
	PlayerData.stat_data["Evasion"] = 0
	PlayerData.stat_data["PDR"] = 0
	PlayerData.stat_data["Strength"] = 0
	PlayerData.stat_data["Speed"] = 0
	
	#no mainhand equipped
	if PlayerData.equipment_data["Mainhand"] == 0:
		PlayerData.stat_data["Total_equipped_damage_min"] = 1
		PlayerData.stat_data["Total_equipped_damage_max"] = 1
		PlayerData.stat_data["Accuracy"] = 100

	for i in PlayerData.equipment_data.keys():
		if PlayerData.equipment_data[i] != null and GameData.item_data.has(PlayerData.equipment_data[i]):
			PlayerData.stat_data["Bonus_hp"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Hp"]
			PlayerData.stat_data["Accuracy"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Accuracy"]
			PlayerData.stat_data["Evasion"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Evasion"]
			PlayerData.stat_data["PDR"] += GameData.item_data[
									PlayerData.equipment_data[i]]["PDR"]
			PlayerData.stat_data["Strength"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Strength"]
			PlayerData.stat_data["Speed"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Speed"]
			#PlayerData.stat_data["Total_equipped_weight"] += GameData.item_data[
									#PlayerData.equipment_data[i]]["Weight"]
			PlayerData.stat_data["Total_equipped_damage_min"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Damage_min"]
			PlayerData.stat_data["Total_equipped_damage_max"] += GameData.item_data[
									PlayerData.equipment_data[i]]["Damage_max"]
			if PlayerData.stat_data["Total_equipped_damage_min"] > PlayerData.stat_data["Total_equipped_damage_max"]:
				PlayerData.stat_data["Total_equipped_damage_max"] = PlayerData.stat_data["Total_equipped_damage_min"]
	SignalBus.update_stat_panel.emit()

func highlight_slot(slot: String):
	get_node("GridContainer/" + slot + "/" + slot + "/Highlight").visible = true

func unhighlight_slot(slot: String):
	get_node("GridContainer/" + slot + "/" + slot + "/Highlight").visible = false
