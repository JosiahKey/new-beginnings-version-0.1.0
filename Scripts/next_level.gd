extends Area2D

var active: bool = false

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		print("_on_nextlevel_entered()")
		SignalBus.load_area_entered.emit()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		print("_on_test_entered()")
		active = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		print("_on_test_exited()")
		active = false
