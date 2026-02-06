extends Control

@onready var player_spr: AnimatedSprite2D = $Player_Sprite
@onready var emitter: GPUParticles2D = $Hit_Indicator
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")
var player_stats: Dictionary = PlayerData.stat_data
var action_points = 0
var target_spd = 0

func _ready() -> void:
	SignalBus.connect("hit_player", Callable(self,"on_hit"))
	SignalBus.connect("miss_player", Callable(self,"on_miss"))
	SignalBus.connect("end_enemy_turn", Callable(self,"ready_player_turn"))

func ready_player_turn():
	SignalBus.turn_start.emit(name)
	player_spr.play("idle")

func player_attack_action():
	var target_enemy = CombatData.selected_enemy
	target_spd = CombatData.combatants_data[target_enemy.name]["Speed"]
	action_points = 1 + floori(float(PlayerData.get_total_speed() - target_spd) / 4.0)
	
	if(action_points <= 0): action_points = 1
	for a in action_points:
		await get_tree().create_timer(0.7).timeout
		player_spr.play("attack")
		await get_tree().create_timer(0.3).timeout
		SignalBus.enemy_selected.emit(target_enemy)
		if roll_stat("Accuracy") == true:
			SignalBus.combat_action.emit("on_hit", roll_damage())
		else:
			SignalBus.combat_action.emit("on_miss", 0)
	player_finish_turn()

func player_aoe_action():
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	
	var enemies = $"../Enemy_Sprites".get_children()
	for e in enemies:
		if e.visible == false:
			pass
		else:
			SignalBus.enemy_selected.emit(e)
			if roll_stat("Accuracy", +5) == true:
				SignalBus.combat_action.emit("on_hit", ceili(roll_damage()/3.0))
			else:
				SignalBus.combat_action.emit("on_miss", 0)
	player_finish_turn()

func player_heal_action():
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	randomize()
	var heal_roll = randi_range(ceili(0.20 * PlayerData.stat_data["Total_hp"]),ceili(0.25 * PlayerData.stat_data["Total_hp"]))
	on_heal(heal_roll)
	player_finish_turn()

func player_all_in_action():
	if (PlayerData.stat_data["Current_hp"] - PlayerData.stat_data["Total_hp"]*0.1) >= 1:
		PlayerData.stat_data["Current_hp"] -= PlayerData.stat_data["Total_hp"]*0.1
	else:
		PlayerData.stat_data["Current_hp"] = 1
	#update hp label
	SignalBus.player_hp_changed.emit()
	var target_enemy = CombatData.selected_enemy
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	SignalBus.enemy_selected.emit(target_enemy)
	if roll_stat("Accuracy", -20) == true: 
		SignalBus.combat_action.emit("on_hit", roll_damage() + PlayerData.get_total_stength() * 25)
	else:
		SignalBus.combat_action.emit("on_miss", 0)
	player_finish_turn()

func player_run_action():
	randomize()
	var roll = randi_range(1,100)
	if roll > 50:
		SignalBus.combat_exited.emit()
	else:
		on_miss()
		player_spr.play("attack")
		player_finish_turn()

func player_finish_turn():
	await player_spr.animation_finished
	player_spr.play("idle")
	SignalBus.turn_finished.emit()

func roll_damage() -> int:
	randomize()
	return randi_range(\
	PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength() * 10,\
	PlayerData.stat_data["Total_equipped_damage_max"] + PlayerData.get_total_stength() * 10)

func roll_stat(stat: String, adjusted_accuracy: int = 0) -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if stat == "Accuracy" and adjusted_accuracy != 0:
		if roll >= PlayerData.stat_data[stat]+adjusted_accuracy:
			return false
		else:
			return true
	else:
		if roll >= PlayerData.stat_data[stat]:
			return false
		else:
			return true

func on_hit(damage: int):
	if(roll_stat("Evasion")):
		var text = floating_text.instantiate()
		text.amount = "Evaded"
		text.type = "evade"
		player_spr.add_child(text)
		$player_miss.playing = true
	else:
		#midigate damage
		var mitigation = damage - roundi(float(damage) * (1.0 - float(PlayerData.stat_data["PDR"])/100.0))
		damage = roundi(float(damage) * (1.0 - float(PlayerData.stat_data["PDR"])/100.0))
		if mitigation > 0:
			var text2 = floating_text.instantiate()
			text2.amount = mitigation
			text2.type = "block"
			player_spr.add_child(text2)
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
	text.type = "miss"
	player_spr.add_child(text)
	$player_miss.playing = true

func on_heal(heal: int):
	var adjusted_heal = heal
	#heal damage
	if(PlayerData.stat_data["Current_hp"] + heal > PlayerData.stat_data["Total_hp"]):
		adjusted_heal = PlayerData.stat_data["Total_hp"] - PlayerData.stat_data["Current_hp"]
		PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
	else:
		PlayerData.stat_data["Current_hp"] += heal
	#update hp label
	SignalBus.player_hp_changed.emit()
	#sfx
	$player_heal.playing = true
	#floating text
	var text = floating_text.instantiate()
	text.amount = adjusted_heal
	text.type = "heal"
	player_spr.add_child(text)
	await player_spr.animation_finished
	player_spr.play("idle")

func _on_player_sprite_animation_finished() -> void:
	player_spr.play("idle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("run_away"):
		SignalBus.combat_exited.emit()
