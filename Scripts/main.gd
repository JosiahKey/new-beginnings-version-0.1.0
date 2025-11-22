extends Node2D

var level_counter: int = 0
var level_max: int = 0
@onready var Level_List: Array[PackedScene] = [
	preload("res://Scenes/Levels/Level1.tscn"),
	preload("res://Scenes/Levels/Level2.tscn"),
	preload("res://Scenes/Levels/Level3.tscn"),
	preload("res://Scenes/Levels/Level4.tscn")
]
@onready var combat_scene = preload("res://Scenes/Combat.tscn")
@onready var game_over_scene = preload("res://Scenes/UI/game_over.tscn")

func _ready() -> void:
	SignalBus.connect("load_area_entered", Callable(self, "_on_next_level_load_area_entered"))
	SignalBus.connect("enemy_encountered", Callable(self, "start_combat"))
	SignalBus.connect("game_over", Callable(self, "game_over"))
	
	level_max = Level_List.size() 
	self.find_child("LevelDock").add_child(Level_List[level_counter].instantiate())

func start_combat():
	add_child(combat_scene.instantiate())

func game_over():
	get_tree().paused = true
	add_child(game_over_scene.instantiate())

func _on_next_level_load_area_entered() -> void:
	self.find_child("LevelDock").get_child(0).queue_free()
	level_counter += 1
	self.find_child("LevelDock").call_deferred("add_child", Level_List[level_counter % level_max].instantiate())
	print("signal passed")
	
