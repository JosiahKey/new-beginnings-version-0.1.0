extends Node2D

@onready var enemies = $Combat/Background_Image/Enemy_Sprites
@onready var player = $Combat/Background_Image/Player
@onready var enemy_res := preload("res://Scenes/Templates/Enemy.tscn")
var action_queue = []
var selected_enemy: Control
var combat_finished = false

func _ready() -> void:
	SignalBus.connect("turn_start", Callable(self, "pop_and_requeue"))
	SignalBus.connect("enemy_selected", Callable(self, "select_enemy"))
	SignalBus.connect("combat_action", Callable(self, "combat_action"))
	SignalBus.connect('combat_exited', Callable(self, "clean_up"))

	generate_combatants()
	roll_initiative()

	pop_and_requeue("enemy1")
	SignalBus.turn_finished.emit()

func _process(_delta: float) -> void:
	if PlayerData.stat_data["Current_hp"] <= 0:
		SignalBus.game_over.emit()
	if CombatData.number_of_enemies == 0:
		if !combat_finished:
			SignalBus.combat_victory.emit(CombatData.reward_data[0])
			combat_finished = true

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

func roll_initiative():
	var turn_order = []
	for i in CombatData.combatants_data.keys():
		if turn_order.is_empty():
			turn_order.push_front(i)
		elif CombatData.combatants_data[i]["Speed"] <= CombatData.combatants_data\
														[turn_order.front()]["Speed"]:
			turn_order.push_back(i)
		else:
			turn_order.push_front(i)
	for t in turn_order:
		if t == "player":
			enqueue(Callable(player, "ready_player_turn"))
		else:
			enqueue(Callable(enemies.get_node(t), "ready_enemy_turn"))

func generate_combatants():
	randomize()
	var rand = randi_range(1,3)
	var new_node := enemy_res.instantiate()
	for r in rand:
		enemies.add_child(new_node.duplicate(DUPLICATE_SCRIPTS), true)
		selected_enemy = new_node

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
	action_queue = []
	selected_enemy = null
	combat_finished = false
	self.queue_free()
