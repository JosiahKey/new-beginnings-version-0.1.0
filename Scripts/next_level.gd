extends Area2D

@export var next_level: String = ""

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		AudioManager.level_change()
		SignalBus.load_area_entered.emit(next_level)
