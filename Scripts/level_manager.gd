extends Node2D

@export var floor_check = 0

@onready var home = preload("res://Scenes/Levels/Home.tscn")

func _ready() -> void:
	SignalBus.connect("load_area_entered", Callable(self, "load_level"))

func load_level() -> void:
	if(get_child_count() > 0 and GameState.state != "Combat"):
		get_child(0).queue_free()
	if !_checkpoint_floor():
		var level_res = load("res://Scenes/Biomes/Cave/Level1.tscn")
		call_deferred("add_child", level_res.instantiate())

func _checkpoint_floor() -> bool:
	if floor_check >= 5:
		call_deferred("add_child", home.instantiate())
		floor_check = 0
		return true
	else:
		floor_check += 1
		return false
