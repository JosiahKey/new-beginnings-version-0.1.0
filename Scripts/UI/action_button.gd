extends TextureButton

@onready var action_label: Label = $Label
var abililty: String = "player_action"

func _ready() -> void:
	pass

func _on_pressed() -> void:
	SignalBus.action_button_pressed.emit("")
	SignalBus.player_action_selected.emit(true)
