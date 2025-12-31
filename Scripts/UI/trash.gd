extends TextureRect

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	#update data of the origin
	if data["origin_panel"] == "Inventory_Panel":
		PlayerData.inv_data[origin_slot]["Item"] = 0
	else:
		PlayerData.equipment_data[origin_slot] = 0
		SignalBus.item_equipped.emit()
	
	#update origin text
	data["origin_node"].texture = null
