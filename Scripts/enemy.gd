extends Control

@onready var sprite := $Enemy_Sprite
@onready var hp_bar: TextureProgressBar = $Enemy_Hp
@onready var emitter := $Hit_Indicator
@onready var enemy_turn_ind := $Turn_Indicator
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")

@onready var enemy_stats: Dictionary = {}

func _ready() -> void:
	SignalBus.connect("start_enemy_turn", Callable(self, "ready_enemy_turn"))
	
	enemy_stats = {
		"Max_hp": 10,
		"Current_hp": 10,
		"Damage_min": 1,
		"Damage_max": 3,
		"Accuracy": 65,
		"Evasion": 5,
		"PDR": 0,
		"Speed": 1,
		"EXP": 50.0
	}
	hp_bar.max_value = enemy_stats["Max_hp"]
	hp_bar.value = enemy_stats["Current_hp"]

func get_stats() -> Dictionary:
	return enemy_stats

func ready_enemy_turn():
	if enemy_stats["Current_hp"] > 0:
		await get_tree().create_timer(0.5).timeout
		enemy_turn_ind.visible = true
		await get_tree().create_timer(1).timeout
		enemy_action("attack")
		await get_tree().create_timer(0.8).timeout
		enemy_turn_ind.visible = false
		SignalBus.end_enemy_turn.emit()
	else:
		self.visible = false
		SignalBus.combat_victory.emit(enemy_stats["EXP"])

func enemy_action(action:String):
	match action:
		"attack":
			sprite.play("attack")
			await get_tree().create_timer(0.5).timeout
			if roll_to_hit() == true:
				randomize()
				SignalBus.hit_player.emit(randi_range(enemy_stats["Damage_min"],enemy_stats["Damage_max"]))
			else:
				SignalBus.miss_player.emit()

func roll_to_hit() -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if roll >= enemy_stats["Accuracy"]:
		return false
	else:
		return true

func roll_to_evade() -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if roll >= enemy_stats["Evasion"]:
		return false
	else:
		return true

func on_hit(damage):
	if roll_to_evade():
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
