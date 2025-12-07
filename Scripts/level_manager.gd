extends Node2D

@onready var Level_List:= {
	"Level1": preload("res://Scenes/Levels/Level1.tscn"),
	"Level2": preload("res://Scenes/Levels/Level2.tscn"),
	"Level3": preload("res://Scenes/Levels/Level3.tscn"),
	"Level4": preload("res://Scenes/Levels/Level4.tscn")
}

func _ready() -> void:
	SignalBus.connect("load_area_entered", Callable(self, "load_level"))

func load_level(next_level: String) -> void:
	print("_on_nextlevel_entered()")
	if(get_child_count()>0):
		get_child(0).queue_free()
	call_deferred("add_child", Level_List[next_level].instantiate())
