extends Control

@onready var sprite := $Enemy_Sprite
@onready var hp_bar: TextureProgressBar = $Enemy_Hp
@onready var emitter := $Hit_Indicator
@onready var enemy_turn_ind := $Turn_Indicator
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")
@onready var enemy_stats: Dictionary = {}
@onready var selector:= $Enemy_Hp/Button/Container/Selector

var selected = false
var half_y = 0

func _ready() -> void:
	SignalBus.connect("start_enemy_turn", Callable(self, "ready_enemy_turn"))

	GameData.generate_enemy()
	enemy_stats = GameData.generate_enemy()
	name = CombatData.add_combatant(enemy_stats)

	var sprite_size = sprite.sprite_frames.get_frame_texture("default", 0).get_size()
	half_y = sprite_size.y /2
	print("size: " + str(half_y))
	sprite.sprite_frames = load("res://Resources/" + enemy_stats["enemy_name"] + ".tres")
	sprite.play("default")
	
	hp_bar.max_value = enemy_stats["Max_hp"]
	hp_bar.value = enemy_stats["Max_hp"]
	enemy_stats["Current_hp"] = enemy_stats["Max_hp"]

func _process(_delta: float) -> void:
	set_position(Vector2( position.x , (-half_y+150)))

func get_stats() -> Dictionary:
	return enemy_stats

func ready_enemy_turn():
	sprite.play("default")
	SignalBus.turn_start.emit(name)
	if enemy_stats["Current_hp"] > 0:
		await get_tree().create_timer(0.5).timeout
		enemy_turn_ind.visible = true
		await get_tree().create_timer(1).timeout
		enemy_action("attack")
		await get_tree().create_timer(0.8).timeout
		sprite.play("default")
		enemy_turn_ind.visible = false
	else:
		self.visible = false
		SignalBus.combat_victory.emit(enemy_stats["EXP"])

func enemy_action(action:String):
	match action:
		"attack":
			sprite.play("attack")
			await get_tree().create_timer(0.5).timeout
			if roll_stat("Accuracy") == true:
				randomize()
				SignalBus.hit_player.emit(randi_range(enemy_stats["Damage_min"],enemy_stats["Damage_max"]))
			else:
				SignalBus.miss_player.emit()
	SignalBus.turn_finished.emit()

func roll_stat(stat: String) -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if roll >= enemy_stats[stat]:
		return false
	else:
		return true

func on_hit(damage):
	if roll_stat("Evasion"):
		var text = floating_text.instantiate()
		text.amount = "EVADED"
		text.type = "damage"
		sprite.add_child(text)
		$enemy_miss.playing = true
	else:
		#midigate damage
		damage = damage * (1 - enemy_stats["PDR"]/100)
		if(damage < 0): damage = 0
		#deal damage
		enemy_stats["Current_hp"] -= damage
		#move hp bar
		var tween = get_tree().create_tween()
		tween.tween_property(hp_bar, "value", enemy_stats["Current_hp"], 0.5)
		#animate floating text
		var text = floating_text.instantiate()
		text.amount = damage
		text.type = "damage"
		sprite.add_child(text)
		#play damage sprite animation
		sprite.play("damaged")
		#vfx 1shot
		emitter.emitting = true
		#sfx play
		$enemy_hit.playing = true

func on_miss():
	var text = floating_text.instantiate()
	text.amount = "miss"
	text.type = "damage"
	sprite.add_child(text)
	$enemy_miss.playing = true

func _on_enemy_sprite_animation_finished() -> void:
		sprite.play("default")


func _on_button_pressed() -> void:
	var nodes = get_tree().get_nodes_in_group("selector")
	for n in nodes:
		n.visible = false
		n.set("selected", false)
	selector.visible = true
	selected = true
