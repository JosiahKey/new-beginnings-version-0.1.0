extends Node2D

@onready var enemies = $Combat/Background_Image/Enemy_Sprites
@onready var player = $Combat/Background_Image/Player
@onready var enemy_res := preload("res://Scenes/Templates/Enemy.tscn")
var action_queue = []
var selected_enemy: Control

func _ready() -> void:
	SignalBus.connect("turn_start", Callable(self, "pop_and_requeue"))
	SignalBus.connect("enemy_selected", Callable(self, "select_enemy"))
	SignalBus.connect("combat_action", Callable(self, "combat_action"))

	generate_enemies()
	generate_enemies()
	generate_enemies()
	generate_enemies()
	generate_enemies()
	roll_initiative()
	print(action_queue)
	pop_and_requeue("enemy1")
	SignalBus.turn_finished.emit()
	print(action_queue)

func enqueue(action: Callable):
	action_queue.push_back(action)

func pop_and_requeue(_combatant: String = ""):
	print(_combatant)
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
			turn_order.push_front(i)
		else:
			turn_order.push_front(i)
	for t in turn_order:
		if t == "player":
			enqueue(Callable(player, "ready_player_turn"))
		else:
			enqueue(Callable(enemies.get_node(t), "ready_enemy_turn"))

func generate_enemies():
	var new_node := enemy_res.instantiate()
	enemies.add_child(new_node)

func select_enemy(enemy: Control):
	selected_enemy = enemy

func combat_action(method: String, arg: Variant):
	if arg != null:
		Callable(selected_enemy, method).call(arg)
