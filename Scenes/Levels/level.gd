extends Node2D

@export var biome: String = ""

func _ready() -> void:
	GameState.biome = biome
