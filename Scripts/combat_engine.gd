extends Node2D

@onready var enemies_ref = $Combat/Background_Image/Enemy_Sprites
@onready var player = $Combat/Background_Image/Player
@onready var enemy_res := preload("res://Scenes/Templates/Enemy.tscn")
var action_queue = []
var selected_enemy: Control
var selected_mult_enemies: Array[Control]
var combat_finished = false
var deleted_item_texture: Texture = null

func _ready() -> void:
	SignalBus.connect("turn_start", Callable(self, "pop_and_requeue"))
	SignalBus.connect("enemy_selected", Callable(self, "select_enemy"))
	SignalBus.connect("combat_action", Callable(self, "combat_action"))
	SignalBus.connect("combat_exited", Callable(self, "clean_up"))
	SignalBus.connect("gameover_item_deleted", Callable(self, "set_deleted_item_texture"))
	SignalBus.connect("player_action_selected", Callable(self, "attack_action"))

	generate_combatants()
	if(GameState.biome == "Boss"):
		enemies_ref.global_position += Vector2(40,-160)
	await get_tree().create_timer(1.2).timeout
	roll_initiative()

func _process(_delta: float) -> void:
	if PlayerData.stat_data["Current_hp"] <= 0:
		if !combat_finished:
			combat_finished = true
			SignalBus.player_died.emit() #goes to equip panel to delete an item
			$Combat/GameOver/ColorRect/VBoxContainer/HBoxContainer/Texture_Rect.texture = deleted_item_texture
			$Combat/GameOver.visible = true
	if CombatData.number_of_enemies == 0:
		if !combat_finished:
			$Combat/Background_Image/Sub_Menus/Action_Panel/ScrollContainer/Actions_Container.visible = false
			SignalBus.combat_victory.emit(CombatData.reward_data[0],CombatData.reward_data[1])
			combat_finished = true
			if(GameState.biome == "Boss"):
				GameState.biome = "Ruins"

func enqueue(action: Callable):
	action_queue.push_back(action)

func pop_and_requeue(_combatant: String = ""):
	await SignalBus.turn_finished
	var action = action_queue.front()
	if !action_queue.is_empty():
		action_queue.pop_front().call()
		enqueue(action)

func clear():
	action_queue.clear()

func sort_descending(a, b):
	if a[0] == "player" and a[1] == b[1]:
		return true
	elif a[1] > b[1]:
		return true
	return false

func roll_initiative():
	var turn_order: Array[Array] = []
	for c in CombatData.combatants_data.keys():
		if c == "player":
			turn_order.push_front([c, int(PlayerData.get_total_speed())])
		else:
			turn_order.push_front([c, int(CombatData.combatants_data[c]["Speed"])])
	turn_order.sort_custom(sort_descending)
	for t in turn_order:
		if t[0] == "player":
			enqueue(Callable(player, "ready_player_turn"))
		else:
			enqueue(Callable(enemies_ref.get_node(t[0]), "ready_enemy_turn"))
	
	for t in turn_order:
		if t[0] != "player":
			pop_and_requeue(t[0])
			break
	SignalBus.turn_finished.emit()

func generate_combatants():
	var new_node := enemy_res.instantiate()
	var enemy_stats = GameData.generate_enemy()
	var max_enemies = GameData.biome_data[GameState.biome][enemy_stats["enemy_name"]]
	randomize()
	var rand = 0
	if max_enemies == 1:
		rand = 1
	else:
		rand = max_enemies #randi_range(2,max_enemies)
	for r in rand:
		CombatData.add_combatant(enemy_stats)
		enemies_ref.add_child(new_node.duplicate(), true)
		selected_enemy = new_node
	for c in enemies_ref.get_children():
		c.init()

func select_enemy(enemy: Control):
	selected_enemy = enemy

func combat_action(method: String, arg: Variant):
	if selected_enemy.visible == false:
		for e in enemies_ref.get_children():
			if e.visible == true:
				selected_enemy = e
	if arg != null:
		Callable(selected_enemy, method).call(arg)

func clean_up():
	AudioManager.pause()
	AudioManager.change_to_precombat_song()
	GameState.state = ""
	action_queue = []
	selected_enemy = null
	combat_finished = false
	CombatData.clear_data()
	self.queue_free()

######################
func attack_action(attack_all: bool = false):
	var target_enemy = CombatData.selected_enemy
	var target_spd = CombatData.combatants_data[target_enemy.name]["Speed"]
	var action_points = 1 + floori(float(PlayerData.get_total_speed() - target_spd) / 4.0)
	
	if attack_all:
		await get_tree().create_timer(0.7).timeout
		$Combat/Background_Image/Player.player_action()
		var all_enemies = enemies_ref.get_children()
		for e in all_enemies:
			if e.visible == false:
				pass
			else:
				SignalBus.enemy_selected.emit(e)
				if roll_stat("Accuracy", +5) == true:
					SignalBus.combat_action.emit("on_hit", ceili(roll_damage()/3.0))
				else:
					SignalBus.combat_action.emit("on_miss", 0)
	else:
		if(action_points <= 0): action_points = 1
		for a in action_points:
			await get_tree().create_timer(0.7).timeout
			$Combat/Background_Image/Player.player_action()
			SignalBus.enemy_selected.emit(target_enemy)
			if roll_stat("Accuracy") == true:
				combat_action("on_hit", roll_damage())
			else:
				combat_action("on_miss", 0)
	$Combat/Background_Image/Player.player_finish_turn()
	
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

func roll_damage() -> int:
	randomize()
	return randi_range(\
	PlayerData.stat_data["Total_equipped_damage_min"] + PlayerData.get_total_stength() * 10,\
	PlayerData.stat_data["Total_equipped_damage_max"] + PlayerData.get_total_stength() * 10)
#####################

func _on_button_pressed() -> void:
	clean_up()
	PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
	GameState.game_over_reset_flags()
	self.queue_free()
	SignalBus.load_area_entered.emit("Home")

func set_deleted_item_texture(item_texture):
	deleted_item_texture = item_texture
