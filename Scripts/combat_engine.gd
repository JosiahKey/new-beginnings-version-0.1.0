extends Node2D

@onready var enemies = $Combat/Background_Image/Enemy_Sprites
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

	generate_combatants()
	if(GameState.biome == "Boss"):
		enemies.global_position += Vector2(40,-160)
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
			enqueue(Callable(enemies.get_node(t[0]), "ready_enemy_turn"))
	
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
		enemies.add_child(new_node.duplicate(), true)
		selected_enemy = new_node
	for c in enemies.get_children():
		c.init()

func select_enemy(enemy: Control):
	selected_enemy = enemy

func combat_action(method: String, arg: Variant):
	if selected_enemy.visible == false:
		for e in enemies.get_children():
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

func _on_button_pressed() -> void:
	clean_up()
	PlayerData.stat_data["Current_hp"] = PlayerData.stat_data["Total_hp"]
	self.queue_free()
	SignalBus.load_area_entered.emit("Home")

func set_deleted_item_texture(item_texture):
	deleted_item_texture = item_texture
