extends Node

@onready var music: AudioStreamPlayer = null
var current_song: String = ""
var precombat_song: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music = get_node("untitled")
	music.playing = true
	current_song = "untitled"
	precombat_song = "untitled"

func change_precombat_song(song: String):
	get_node(current_song).playing = false
	music = get_node(song)
	music.playing = true
	current_song = song
	precombat_song = song

func change_song_to_combat(song: String):
	get_node(current_song).playing = false
	music = get_node(song)
	music.playing = true
	current_song = song

func change_to_precombat_song():
	get_node(current_song).playing = false
	music = get_node(precombat_song)
	music.playing = true
	current_song = precombat_song

func pause():
	get_node(current_song).playing = false

func resume():
	get_node(current_song).playing = true

func level_change():
	get_node("level_change").playing = true
