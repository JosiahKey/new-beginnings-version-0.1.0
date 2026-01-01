extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
		SignalBus.update_stat_panel.emit()
		$SFX.playing = true
