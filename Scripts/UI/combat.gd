extends CanvasLayer

@onready var health_bar: TextureProgressBar = $Background_Image/Sub_Menus/HP_Bar/MarginContainer/Health_Prog
@onready var health_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/Combat_Hp_Label
@onready var player_spr: AnimatedSprite2D = $Background_Image/Player/Player_Sprite
@onready var player_turn_ind :GPUParticles2D = $Background_Image/Player/Player_Turn_Indicator
@onready var emitter: GPUParticles2D = $Background_Image/Player/Hit_Indicator
@onready var enemy := $Background_Image/Enemy_Sprites/Enemy
@onready var actions_container := $Background_Image/Sub_Menus/Action_Panel/Actions_Container
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")
var players_turn: bool = true

func _ready() -> void:
	GameState.state = "Combat"
	
	SignalBus.connect("hit_player", Callable(self,"on_hit"))
	SignalBus.connect("miss_player", Callable(self,"on_miss"))
	SignalBus.connect("end_enemy_turn", Callable(self,"ready_player_turn"))
	SignalBus.connect("combat_victory", Callable(self, "combat_victory"))
	
	health_bar.max_value = PlayerData.stat_data["Total_hp"]
	health_bar.value = PlayerData.stat_data["Current_hp"]
	health_label.text = "HP: " + str(PlayerData.stat_data["Total_hp"]) + " / " + str(PlayerData.stat_data["Current_hp"])
	ready_player_turn()

func combat_victory():
	#play fanfare
	AudioManager.pause()
	get_node("fanfare").playing = true
	await get_tree().create_timer(1.9).timeout
	#victory dance
	#reward popup
	#press button on pupup to end combat
	#cleanup
	#fade out
	#SignalBus.combat_exited.emit()
	AudioManager.change_to_precombat_song()
	GameState.state = ""
	self.queue_free()

func ready_player_turn():
	if PlayerData.stat_data["Current_hp"] > 0:
		actions_container.visible = true
		player_turn_ind.visible = true
		players_turn = true
	else:
		SignalBus.game_over.emit()

func _on_confirm_btn_pressed() -> void:
	if players_turn:
		players_turn = false
		player_attack_action()
		$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = false

func player_attack_action():
	get_node("select").playing = true
	player_turn_ind.visible = false
	actions_container.visible = false
	await get_tree().create_timer(0.7).timeout
	player_spr.play("attack")
	await get_tree().create_timer(0.3).timeout
	if roll_to_hit() == true:
		randomize()
		enemy.on_hit(randi_range(PlayerData.stat_data[
			"Total_equipped_damage_min"],PlayerData.stat_data["Total_equipped_damage_max"]))
		await get_tree().create_timer(0.3).timeout
		SignalBus.start_enemy_turn.emit()
	else:
		enemy.on_miss()
		await get_tree().create_timer(0.3).timeout
		SignalBus.start_enemy_turn.emit()

func roll_to_hit() -> bool:
	randomize()
	var roll: float = randf_range(0.0,1.0)
	if GameData.item_data.has(PlayerData.equipment_data["Mainhand"]):
		if roll > GameData.item_data[PlayerData.equipment_data["Mainhand"]]["Accuracy"]:
			return false
		else:
			return true
	else:
		return false

func on_hit(damage: int):
	#deal damage
	PlayerData.stat_data["Current_hp"] -= damage
	#update hp label
	health_label.text = "HP: " + str(PlayerData.stat_data["Total_hp"]) + " / " + str(PlayerData.stat_data["Current_hp"])
	#move hp bar
	var tween = get_tree().create_tween()
	var newhp = PlayerData.stat_data["Current_hp"]
	print(str(newhp) + "  " + str(health_bar.value))
	tween.tween_property(health_bar, "value", newhp, 0.5)
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
	pass

func _on_player_sprite_animation_finished() -> void:
	player_spr.play("idle")

func _on_back_pressed() -> void:
	$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = false

func _on_action_button_pressed() -> void:
	if players_turn:
		$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = true
