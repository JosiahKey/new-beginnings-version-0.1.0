extends Area2D

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		AudioManager.change_song_to_combat("pokemon")
		SignalBus.combat_entered.emit()
		await get_tree().create_timer(0.5).timeout
		SignalBus.enemy_encountered.emit()
		queue_free()
