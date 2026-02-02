extends CanvasLayer

@onready var heal_label = $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container/action_button2/Label
@onready var hp_bar: TextureProgressBar = $Background_Image/Sub_Menus/HP_Bar/MarginContainer/Health_Prog
@onready var exp_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/EXP
@onready var hp_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/Combat_Hp_Label
@onready var armor_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/Armor
@onready var evasion_label: Label = $Background_Image/Sub_Menus/Player_Panel/VBoxContainer/Evasion
@onready var player_spr: AnimatedSprite2D = $Background_Image/Player/Player_Sprite
@onready var emitter: GPUParticles2D = $Background_Image/Player/Hit_Indicator
@onready var actions_container := $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container
@onready var floating_text := preload("res://Scenes/UI/floating_text.tscn")
@onready var enemy_sprites_container = $Background_Image/Enemy_Sprites
@onready var enemy_info := $Background_Image/Sub_Menus/Enemy_Panel/V
@onready var banner_anim := $Background_Image/Turn_Banner/AnimationPlayer
@onready var banner_label := $Background_Image/Turn_Banner/Label
@onready var action1 = $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container/action_button
@onready var action2 = $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container/action_button2
@onready var action3 = $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container/action_button3
@onready var action4 = $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container/action_button4
@onready var action5 = $Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container/action_button5

var players_turn: bool = false
var action_points = PlayerData.get_total_speed()

var num_of_heals = 2

func _ready() -> void:
	GameState.state = "Combat"
	$Background_Image.texture = load("res://Assets/art_assets/battleback_"+ GameState.biome +".png")

	SignalBus.connect("turn_start", Callable(self, "toggle_action_ui"))
	SignalBus.connect("player_hp_changed", Callable(self, "update_hp"))
	SignalBus.connect("num_enemies_changed", Callable(self, "update_enemy_info"))
	
	heal_label.text = "Heal - " + str(num_of_heals) + " left"
	exp_label.text = "EXP: " + str(int(PlayerData.stat_data["Experience"])) + " / " + str(int(PlayerData.stat_data["Exp_to_next_level"]))
	hp_bar.max_value = PlayerData.stat_data["Total_hp"]
	hp_bar.value = PlayerData.stat_data["Current_hp"]
	hp_label.text = "HP: " + str(int(PlayerData.stat_data["Current_hp"])) + " / " + str(int(PlayerData.stat_data["Total_hp"]))
	armor_label.text = "Armor: " + str(int(PlayerData.stat_data["PDR"])) + "%"
	evasion_label.text = "Evasion: " + str(int(PlayerData.stat_data["Evasion"])) + "%"
	set_tooltips()

func set_tooltips():
	action1.tooltip_text = "Attack one enemy once... or twice..."\
	+ "\nDamage: " + str(PlayerData.get_min_damage()) + "-" + str(PlayerData.get_max_damage())\
	+ "\nChance to hit: " + str(int(PlayerData.stat_data["Accuracy"])) + "%"
	action2.tooltip_text = "Recover HP \nHeal: 20% (" + str(int(PlayerData.get_total_hp()*0.2))\
	+ ") - 25% (" + str(int(PlayerData.get_total_hp()*0.25)) + ") Max HP"
	action3.tooltip_text = "Attack all enemies once for 1/3 damage"\
	+ "\nDamage: " + str(int(PlayerData.get_min_damage()/3.0)) + "-" + str(int(PlayerData.get_max_damage()/3.0))\
	+ "\nChance to hit: " + str(int(PlayerData.stat_data["Accuracy"])) + "%"
	action4.tooltip_text = "Don't do it you coward"
	action5.tooltip_text = "Reduces HP by 20% of max HP"\
	+ "\nAttack one enemy once for 2x damage with 20% less accuracy"\
	+ "\nDamage: " + str(int(PlayerData.get_min_damage()*2.0)) + "-" + str(int(PlayerData.get_max_damage()*2.0))\
	+ "\nChance to hit: " + str(int(PlayerData.stat_data["Accuracy"]-20)) + "%"

func update_hp():
	var tween = get_tree().create_tween()
	tween.tween_property(hp_bar, "value", PlayerData.stat_data["Current_hp"], 0.5)
	hp_label.text = "HP: " + str(int(PlayerData.stat_data["Current_hp"])) + " / " + str(int(PlayerData.stat_data["Total_hp"]))

func toggle_action_ui(combatant: String = ""):
	if combatant == "Player":
		await get_tree().create_timer(0.5).timeout
		players_turn = true
		actions_container.visible = true
		banner_label.text = "Player Turn"
		banner_anim.play("fadeout")
	else:
		actions_container.visible = false

func _on_reward_visibility_changed() -> void:
	if $Reward.visible == false:
		GameState.state = ""
		SignalBus.combat_exited.emit()
		self.queue_free()

func update_enemy_info():
	var enemies = []
	for i in enemy_info.get_children():
		i.text = ""
	for e in enemy_sprites_container.get_children():
		if e.visible == true:
			enemies.append(CombatData.combatants_data[e.name]["enemy_name"])
	for i in range(0,enemies.size()):
		get_node("Background_Image/Sub_Menus/Enemy_Panel/V/Label" + str(i+1)).text = enemies[i]

func _on_action_button_pressed() -> void:
	get_node("select").playing = true
	$Background_Image/Player.player_attack_action()
	actions_container.visible = false
	players_turn = false

func _on_action_button_2_pressed() -> void:
	if num_of_heals >= 1:
		num_of_heals -= 1
		heal_label.text = "Heal - " + str(num_of_heals) + " left"
		get_node("select").playing = true
		$Background_Image/Player.player_heal_action()
		actions_container.visible = false
		players_turn = false
	if num_of_heals <= 0:
		action2.disabled = true


func _on_action_button_3_pressed() -> void:
	get_node("select").playing = true
	$Background_Image/Player.player_aoe_action()
	actions_container.visible = false
	players_turn = false

func _on_action_button_4_pressed() -> void:
	get_node("select").playing = true
	$Background_Image/Player.player_run_action()
	actions_container.visible = false
	players_turn = false

func _on_action_button_5_pressed() -> void:
	get_node("select").playing = true
	$Background_Image/Player.player_all_in_action()
	actions_container.visible = false
	players_turn = false
