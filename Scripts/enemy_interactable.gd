extends Area2D

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		SignalBus.player_paused.emit()
		AudioManager.change_song_to_combat("boss")
		SignalBus.combat_entered.emit()
		await get_tree().create_timer(0.5).timeout
		GameState.biome = "Boss"
		SignalBus.enemy_encountered.emit()
		queue_free()
