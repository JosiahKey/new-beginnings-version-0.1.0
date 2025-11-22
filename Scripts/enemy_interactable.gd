extends Area2D

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		SignalBus.enemy_encountered.emit()
		queue_free()
