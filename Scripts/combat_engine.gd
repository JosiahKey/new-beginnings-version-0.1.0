extends Node2D

@onready var enemies = $Combat/Background_Image/Enemy_Sprites
@onready var player = $Combat/Background_Image/Player
@onready var enemy_res := preload("res://Scenes/Templates/Enemy.tscn")
var action_queue = []

func _ready() -> void:
	SignalBus.connect("turn_start", Callable(self, "pop_and_requeue"))
	enemies.add_child(enemy_res.instantiate())

	roll_initiative()
	pop_and_requeue()

func enqueue(action: Callable):
	action_queue.push_back(action)

func pop_and_requeue():
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
