extends AudioStreamPlayer

@onready var fanfare = preload("res://Assets/Audio/SFX/fanfare.mp3")
@onready var untitled = preload("res://Assets/Audio/music/untitled.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = untitled
	self.playing = true

func enemy_transition_audio():
	pass

func combat_audio():
	pass

func fanfare_audio():
	stream = fanfare
	self.playing = true
