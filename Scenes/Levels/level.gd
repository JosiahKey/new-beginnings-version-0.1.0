extends Node2D

@export var biome: String = ""

func _ready() -> void:
	if biome != "":
		GameState.biome = biome
