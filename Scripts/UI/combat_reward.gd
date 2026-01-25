extends CanvasLayer

@onready var btn := $N/V/confirm_reward
var exp_finished_flag = false
var ui_iterator = 1

func _ready() -> void:
	SignalBus.connect("update_reward_item", Callable(self, "update_reward_items"))
	SignalBus.connect("exp_finished", Callable(self, "allow_button"))
	for i in range(1,7):
			get_node("N/V/item_reward"+ str(i) + "/Label/TextureRect").texture = null
			get_node("N/V/item_reward"+ str(i) + "/Label").text = ""
	btn.visible = true

func update_reward_items(item_id):
	var item_name = GameData.item_data[item_id]["item_name"]
	get_node("N/V/item_reward"+ str(ui_iterator) + "/Label/TextureRect").texture = load("res://Assets/item_assets/"+ item_name +".png")
	get_node("N/V/item_reward"+ str(ui_iterator) + "/Label").text = GameData.item_data[item_id]["item_name"]
	ui_iterator += 1
	

func _on_confirm_reward_pressed() -> void:
	if(exp_finished_flag):
		for i in range(1,7):
			get_node("N/V/item_reward"+ str(i) + "/Label/TextureRect").texture = null
			get_node("N/V/item_reward"+ str(i) + "/Label").text = ""
		AudioManager.change_to_precombat_song()
		visible = false
		btn.visible = false
		exp_finished_flag = false
		ui_iterator = 1

func allow_button():
	exp_finished_flag = true
