extends CanvasLayer

func _ready() -> void:
	SignalBus.connect("update_reward_item", Callable(self, "update_reward_item"))

func update_reward_item(item_id):
	var item_name = GameData.item_data[item_id]["item_name"]
	$N/V/item_reward/TextureRect.texture = load("res://Assets/item_assets/"+ item_name +".png")
	$N/V/item_reward/Label.text = GameData.item_data[item_id]["item_name"]
	
	var ui_iterator = 1
	for i in range(GameData.item_stats.size()):
			var stat_name = GameData.item_stats[i]
			var stat_readable = GameData.item_stats_readable[i]
			if GameData.item_data[item_id][stat_name] != 0:
				var stat_value = GameData.item_data[item_id][stat_name]
				get_node("N/V/item_stat" + str(ui_iterator)).text = stat_readable + ": +" + str(stat_value)
				ui_iterator += 1

func _on_confirm_reward_pressed() -> void:
		get_tree().paused = false
		visible = false
