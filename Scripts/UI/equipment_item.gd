extends TextureRect

func _ready() -> void:
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _get_drag_data(at_position: Vector2):
	var equipment_type = get_parent().get_name()
	if PlayerData.equipment_data[equipment_type] != null:
		var data: Dictionary = {}
		data["origin_node"] = self
		data["origin_panel"] = "Equip_Panel"
		data["origin_item_id"] = PlayerData.equipment_data[equipment_type]
		data["origin_equipment_type"] = equipment_type
		data["origin_texture"] = texture
	
		var drag_texture = TextureRect.new()
		drag_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		drag_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		drag_texture.texture = texture
		drag_texture.custom_minimum_size = size*1.3
		drag_texture.modulate.a = 0.5
		
		var c := Control.new()
		c.add_child(drag_texture)
		drag_texture.position = Vector2(-at_position)
		set_drag_preview(c)
		
		return data
		
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var target_slot = get_parent().get_name()
	if target_slot == data["origin_equipment_type"]:
		if PlayerData.equipment_data[target_slot] == 0:
			data["target_item_id"] = 0
			data["target_texture"] = null
		else:
			data["target_item_id"] = PlayerData.equipment_data[target_slot]
			data["target_texture"] = texture
		return true
	else:
		return false
	

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var target_equipment_type = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	#update data of the origin
	if data["origin_panel"] == "Inventory_Panel":
		PlayerData.inv_data[origin_slot]["Item"] = data["target_item_id"]
	else:
		PlayerData.equipment_data[origin_slot] = data["target_item_id"]
		
	#update origin text
	data["origin_node"].texture = data["target_texture"]
	
	#update texture and data of target
	PlayerData.equipment_data[target_equipment_type] = data["origin_item_id"]
	texture = data["origin_texture"]
	
	SignalBus.item_equipped.emit()

func _on_mouse_entered() -> void:
	Tooltip.item_popup(Rect2i(Vector2i(global_position) + Vector2i(362,0), Vector2i(size)), get_parent().get_name(), "Equip_Panel")

func _on_mouse_exited() -> void:
	Tooltip.hide_item_popup()
