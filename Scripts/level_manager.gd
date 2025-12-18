extends Node2D

@onready var Level_List:= {
	"Sidearea": preload("res://Scenes/Levels/Sidearea.tscn"),
	"Level2": preload("res://Scenes/Levels/Level2.tscn"),
	"Overworld": preload("res://Scenes/Levels/Overworld.tscn"),
	"Level4": preload("res://Scenes/Levels/Level4.tscn"),
	"Bossarea": preload("res://Scenes/Levels/Bossarea.tscn"),
	"Home": preload("res://Scenes/Levels/Home.tscn"),
	"Overworld_fromhome": preload("res://Scenes/Levels/Overworld_fromhome.tscn"),
	"Overworld_fromside": preload("res://Scenes/Levels/Overworld_fromside.tscn"),
}

func _ready() -> void:
	SignalBus.connect("load_area_entered", Callable(self, "load_level"))

func load_level(next_level: String) -> void:
	print("_on_nextlevel_entered()")
	if(get_child_count()>0):
		get_child(0).queue_free()
	call_deferred("add_child", Level_List[next_level].instantiate())
