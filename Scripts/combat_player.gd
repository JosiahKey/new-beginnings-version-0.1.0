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
	SignalBus.turn_start.emit()
	if PlayerData.stat_data["Current_hp"] > 0:
		#signal to ui --> actions_container.visible = true
		player_turn_ind.visible = true
	else:
		SignalBus.game_over.emit()

func _on_confirm_btn_pressed() -> void:
	#audio sfx
	get_node("select").playing = true
	#this can handle selecting different actions in the future
	player_attack_action()
	#signal to ui --> 
	#!!!#actions_container.visible = true
	player_turn_ind.visible = false

func player_attack_action():
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	if roll_stat("Accuracy") == true:
		pass#!!!#on_hit(target enemy, damage calculation)
	else:
		pass#!!!#on_miss(target enemey)
	await get_tree().create_timer(0.3).timeout
	SignalBus.turn_finished.emit()

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
		#!!!# signal to ui to update hp bars
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

func on_miss():
	var text = floating_text.instantiate()
	text.amount = "miss"
	text.type = "damage"
	player_spr.add_child(text)
	$player_miss.playing = true

func _on_player_sprite_animation_finished() -> void:
	player_spr.play("idle")
