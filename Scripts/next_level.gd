extends Area2D

@export var next_level: String = ""
@export var randomize: bool = false

func _on_next_level_entered(body):
	if body.is_in_group("Player"):
		AudioManager.level_change()
		if randomize:
			randomize()
			var num = randi_range(1,9)
			next_level = "Level" + str(num)
			SignalBus.new_load_area_entered.emit(next_level)
		else:
			SignalBus.load_area_entered.emit(next_level)
