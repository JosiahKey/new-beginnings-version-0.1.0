extends Area2D

var in_range: bool = false
var collected: bool = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		if(!collected):
			in_range = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if in_range and !collected:
			SignalBus.item_generated.emit("Jewelry")
			collected = true
			$TextureRect.visible = false
			$AudioStreamPlayer2D.playing = true
