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
@onready var enemy_sprites_container = $Background_Image/Enemy_Sprites
var players_turn: bool = false
var action_points = PlayerData.get_total_speed()

func _ready() -> void:
	GameState.state = "Combat"

	SignalBus.connect("combat_victory", Callable(self, "combat_victory"))
	SignalBus.connect("check_for_levelup", Callable(self, "check_for_levelup")) 
	SignalBus.connect("turn_start", Callable(self, "player_turn"))
	
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


func _on_confirm_btn_pressed() -> void:
	get_node("select").playing = true
	$Background_Image/Player.player_attack_action()
	$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = false
	players_turn = false


func player_turn(combatant: String = ""):
	if combatant == "Player":
		players_turn = true
		actions_container.visible = true
	else:
		actions_container.visible = false

func _on_back_pressed() -> void:
	$Background_Image/Sub_Menus/Action_Panel/Info_Panels.visible = false

func _on_action_button_pressed() -> void:
	if players_turn== true:
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
