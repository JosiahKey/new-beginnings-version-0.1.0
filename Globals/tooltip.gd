extends Control

func item_popup(slot_pos: Rect2i, slot: String, origin: String):
	var valid = false
	@warning_ignore("unused_variable")
	var item_id: int
	if origin == "Inventory":
		if PlayerData.inv_data[slot]["Item"] != null and GameData.item_data.has(PlayerData.inv_data[slot]["Item"]):
			item_id = PlayerData.inv_data[slot]["Item"]
			valid = true
		else:
			valid = false
	else: #origin equipment
		if PlayerData.equipment_data[slot] != null and GameData.item_data.has(PlayerData.equipment_data[slot]):
			item_id = PlayerData.equipment_data[slot]
			valid = true
		else:
			valid = false
	if valid:
		get_node("CanvasLayer/Tooltip/N/M/V/Item_Name").text = GameData.item_data[item_id]["item_name"]
		var ui_iterator = 1
		for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_readable = GameData.item_stats_readable[i]
			if GameData.item_data[item_id][stat_name] != null and GameData.item_data[item_id][stat_name] != 0:
				var stat_value = int(GameData.item_data[item_id][stat_name])
				get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Stat").text = stat_readable + ": +" + str(stat_value)
				if GameData.item_data[item_id]["equipmentSlot"] != null and origin == "Inventory":
					var stat_diff = compare_items(item_id, stat_name, stat_value)
					if stat_diff > 0:
						get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").text = "+" + str(stat_diff) + "       "
						get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("2eff27"))
					elif stat_diff < 0:
						get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").text = str(stat_diff) + "       "
						get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("ff3131"))
					else:
						get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").text = "0       "
						get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("003131ff"))
				else:
					get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").text = "0       "
					get_node("CanvasLayer/Tooltip/N/M/V/Stat" + str(ui_iterator) + "/Diff").add_theme_color_override("font_color", Color("003131ff"))
				ui_iterator += 1
		%Tooltip.popup(Rect2i(slot_pos.position - Vector2i(328,200), %Tooltip.size))
	else:
		%Tooltip.hide()

func hide_item_popup():
	%Tooltip.hide()

func compare_items(item_id, stat_name, stat_value) -> int:
	var stat_diff = 0
	var slot = GameData.item_data[item_id]["equipmentSlot"]
	if PlayerData.equipment_data[slot] != null:
		var equipped_item_id = PlayerData.equipment_data[slot]
		var equipped_item_stat_value = GameData.item_data[equipped_item_id][stat_name]
		stat_diff = stat_value - equipped_item_stat_value
		if int(PlayerData.equipment_data[slot]) == int(item_id):
			return 0
	else:
		stat_diff = stat_value
	return int(stat_diff)
