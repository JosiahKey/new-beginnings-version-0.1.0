extends CanvasLayer

@onready var btn := $N/V/confirm_reward

func _ready() -> void:
	SignalBus.connect("update_reward_item", Callable(self, "update_reward_item"))

func update_reward_item(item_id):
	var item_name = GameData.item_data[item_id]["item_name"]
	$N/V/item_reward/TextureRect.texture = load("res://Assets/item_assets/"+ item_name +".png")
	$N/V/item_reward/Label.text = GameData.item_data[item_id]["item_name"]
	await get_tree().create_timer(1.5).timeout
	btn.visible = true

func _on_confirm_reward_pressed() -> void:
		visible = false
		btn.visible = false
