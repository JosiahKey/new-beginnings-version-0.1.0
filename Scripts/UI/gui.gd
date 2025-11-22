extends CanvasLayer

func _on_menu_close_pressed() -> void:
	self.visible = !self.visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		self.visible = !self.visible
