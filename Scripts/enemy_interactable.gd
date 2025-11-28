extends Area2D

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		SignalBus.scene_transition_started.emit()
		await get_tree().create_timer(0.5).timeout
		SignalBus.enemy_encountered.emit()
		queue_free()
