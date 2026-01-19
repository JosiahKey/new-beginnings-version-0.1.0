extends Control

@onready var player_spr: AnimatedSprite2D = $Player_Sprite
@onready var player_turn_ind :GPUParticles2D = $Player_Turn_Indicator
@onready var emitter: GPUParticles2D = $Hit_Indicator
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")
var player_stats: Dictionary = PlayerData.stat_data

func _ready() -> void:
	SignalBus.connect("hit_player", Callable(self,"on_hit"))
	SignalBus.connect("miss_player", Callable(self,"on_miss"))
	SignalBus.connect("end_enemy_turn", Callable(self,"ready_player_turn"))

func ready_player_turn():
	SignalBus.turn_start.emit(name)
	player_spr.play("idle")
	player_turn_ind.visible = true

func player_attack_action():
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	
	print(CombatData.combatants_data[CombatData.selected_enemy])
	
	if roll_stat("Accuracy") == true:
		SignalBus.combat_action.emit("on_hit", roll_damage())
	else:
		SignalBus.combat_action.emit("on_miss", 0)
	player_finish_turn()

func player_finish_turn():
	await player_spr.animation_finished
	player_turn_ind.visible = false
	player_spr.play("idle")
	SignalBus.turn_finished.emit()

func roll_damage() -> int:
	randomize()
	return randi_range(\
	PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength(),\
	PlayerData.stat_data["Total_equipped_damage_max"] + PlayerData.get_total_stength())

func roll_stat(stat: String) -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if roll >= PlayerData.stat_data[stat]:
		return false
	else:
		return true

func on_hit(damage: int):
	if(roll_stat("Evasion")):
		var text = floating_text.instantiate()
		text.amount = "EVADED"
		text.type = "damage"
		player_spr.add_child(text)
		$player_miss.playing = true
	else:
		#midigate damage
		damage = roundi(float(damage) * (1.0 - float(PlayerData.stat_data["PDR"])/100.0))
		if(damage < 0): damage = 0
		#deal damage
		PlayerData.stat_data["Current_hp"] -= damage
		#update hp label
		SignalBus.player_hp_changed.emit()
		#animate floating text
		var text = floating_text.instantiate()
		text.amount = damage
		text.type = "damage"
		player_spr.add_child(text)
		#play damage sprite animation
		player_spr.play("damaged")
		#vfx 1shot
		emitter.emitting = true
		#sfx play
		get_node("player_hit").playing = true
		await player_spr.animation_finished
		player_spr.play("idle")

func on_miss():
	var text = floating_text.instantiate()
	text.amount = "miss"
	text.type = "damage"
	player_spr.add_child(text)
	$player_miss.playing = true

func _on_player_sprite_animation_finished() -> void:
	player_spr.play("idle")
