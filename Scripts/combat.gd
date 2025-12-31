extends CanvasLayer

@onready var health_bar: TextureProgressBar = $Background_Image/Sub_Menus/HP_Bar/MarginContainer/Health_Prog
@onready var exp_bar: TextureProgressBar = $Reward/N/V/exp_reward/expbar
@onready var exp_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/EXP
@onready var health_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/Combat_Hp_Label
@onready var player_spr: AnimatedSprite2D = $Background_Image/Player/Player_Sprite
@onready var player_turn_ind :GPUParticles2D = $Background_Image/Player/Player_Turn_Indicator
@onready var emitter: GPUParticles2D = $Background_Image/Player/Hit_Indicator
@onready var actions_container := $Background_Image/Sub_Menus/Action_Panel/Actions_Container
@onready var damage_label := $Background_Image/Sub_Menus/Action_Panel/Info_Panels/Info/VBoxContainer/damage
@onready var hit_label := $Background_Image/Sub_Menus/Action_Panel/Info_Panels/Info/VBoxContainer/hit_chance
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")
@onready var enemy_res := preload("res://Scenes/Templates/Enemy.tscn")
var enemy: Node
var players_turn: bool = true
var action_points = PlayerData.get_total_speed()

func _ready() -> void:
	GameState.state = "Combat"
	
	$Background_Image/Enemy_Sprites.add_child(enemy_res.instantiate())
	enemy = $Background_Image/Enemy_Sprites.get_child(0)
	
	SignalBus.connect("hit_player", Callable(self,"on_hit"))
	SignalBus.connect("miss_player", Callable(self,"on_miss"))
	SignalBus.connect("end_enemy_turn", Callable(self,"ready_player_turn"))
	SignalBus.connect("combat_victory", Callable(self, "combat_victory"))
	SignalBus.connect("check_for_levelup", Callable(self, "check_for_levelup")) 
	
	damage_label.text = "Damage: "+ str(
		PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength()) + "-" + str(
		PlayerData.stat_data["Total_equipped_damage_max"] + PlayerData.get_total_stength())
	hit_label.text = "Chance to hit: " + str(PlayerData.stat_data["Accuracy"]) + "%"
	exp_label.text = "EXP: " + str(PlayerData.stat_data["Experience"]) + " / " + str(PlayerData.stat_data["Exp_to_next_level"])
	health_bar.max_value = PlayerData.stat_data["Total_hp"]
	health_bar.value = PlayerData.stat_data["Current_hp"]
	exp_bar.max_value = PlayerData.stat_data["Exp_to_next_level"]
	exp_bar.value = PlayerData.stat_data["Experience"]
	health_label.text = "HP: " + str(PlayerData.stat_data["Current_hp"]) + " / " + str(PlayerData.stat_data["Total_hp"])
	ready_player_turn()

func combat_victory(experience: float):
	#play fanfare
	AudioManager.pause()
	get_node("fanfare").playing = true
	await get_tree().create_timer(1).timeout
	#victory dance
	#reward popup + EXP gain animation
	$Reward.visible = true
	SignalBus.item_generated.emit()
	check_for_levelup(experience)
	SignalBus.update_stat_panel.emit()

func check_for_levelup(experience: float = 0.0):
	exp_bar.max_value = PlayerData.stat_data["Exp_to_next_level"]
	var exptween = get_tree().create_tween()
	var newexp = PlayerData.stat_data["Experience"] + experience
	PlayerData.stat_data["Experience"] += experience
	
	if(PlayerData.stat_data["Experience"] >= PlayerData.stat_data["Exp_to_next_level"]):
		PlayerData.stat_data["Level"] += 1
		PlayerData.stat_data["Exp_to_next_level"] = float(int(PlayerData.stat_data["Exp_to_next_level"] * log(PlayerData.stat_data["Exp_to_next_level"])))
		exptween.tween_property(exp_bar, "value", exp_bar.max_value, 1.5).set_ease(Tween.EASE_OUT)
		await exptween.finished
		SignalBus.levelup.emit()
	else:
		exptween.tween_property(exp_bar, "value", newexp, 1.5).set_ease(Tween.EASE_OUT)
	$Reward/N/V/exp_reward/Lvl_Text/stat_label.text = "Level " + str(PlayerData.stat_data["Level"])

func ready_player_turn():
	if PlayerData.stat_data["Current_hp"] > 0:
		action_points = PlayerData.get_total_speed()
		actions_container.visible = true
		player_turn_ind.visible = true
		players_turn = true
	else:
		SignalBus.game_over.emit()

func _on_confirm_btn_pressed() -> void:
	if players_turn:
		players_turn = false
		get_node("select").playing = true
		player_attack_action()
		$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = false

func player_attack_action():
	player_turn_ind.visible = false
	actions_container.visible = false
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	if roll_to_hit() == true:
		randomize()
		enemy.on_hit(randi_range(PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength(),
								PlayerData.stat_data["Total_equipped_damage_max"]+ PlayerData.get_total_stength()))
	else:
		enemy.on_miss()
	await get_tree().create_timer(0.3).timeout
	if(action_points > enemy.get_stats()["Speed"]):
		action_points -= 5
		player_attack_action()
	else:
		SignalBus.start_enemy_turn.emit()
		action_points = PlayerData.get_total_speed()

func roll_to_hit() -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if roll >= PlayerData.stat_data["Accuracy"]:
		return false
	else:
		return true

func roll_to_evade() -> bool:
	randomize()
	var roll: int = randi_range(0,100)
	if roll >= PlayerData.stat_data["Evasion"]:
		return false
	else:
		return true

func on_hit(damage: int):
	if(roll_to_evade()):
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
		health_label.text = "HP: " + str(PlayerData.stat_data["Current_hp"]) + " / " + str(PlayerData.stat_data["Total_hp"])
		#move hp bar
		var hptween = get_tree().create_tween()
		var newhp = PlayerData.stat_data["Current_hp"]
		hptween.tween_property(health_bar, "value", newhp, 0.5)
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

func _on_back_pressed() -> void:
	$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = false

func _on_action_button_pressed() -> void:
	if players_turn:
		damage_label.text = "Damage: "+ str(
		PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength()) + "-" + str(
		PlayerData.stat_data["Total_equipped_damage_max"] + PlayerData.get_total_stength())
		hit_label.text = "Chance to hit: " + str(PlayerData.stat_data["Accuracy"]) + "%"
		$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = true

func _on_reward_visibility_changed() -> void:
	if $Reward.visible == false:
		AudioManager.change_to_precombat_song()
		GameState.state = ""
		#fade out
		#SignalBus.combat_exited.emit()
		#cleanup
		self.queue_free()
