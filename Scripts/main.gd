extends Node2D

@onready var combat_scene = preload("res://Scenes/Combat.tscn")
@onready var game_over_scene = preload("res://Scenes/UI/game_over.tscn")

func _ready() -> void:
	SignalBus.connect("enemy_encountered", Callable(self, "start_combat"))
	SignalBus.connect("reward", Callable(self, "show_reward"))
	SignalBus.connect("game_over", Callable(self, "game_over"))

func start_combat():
	add_child(combat_scene.instantiate())

func game_over():
	get_tree().paused = true
	add_child(game_over_scene.instantiate())

func show_reward():
	get_tree().paused = true
	$Reward.visible = true
