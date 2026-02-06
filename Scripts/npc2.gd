extends Area2D

@onready var sprite_ref := $AnimatedSprite

var in_range: bool = false
var collected: bool = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		in_range = true
		#if PlayerData.equipment_data["Mainhand"] != 0:
			#if GameData.item_data[PlayerData.equipment_data["Mainhand"]]["item_rarity"] == "rare" or "epic" or "legendary":
				#$Dialouge/MarginContainer/Label.text = "Nice Weapon!"
			#else:
				#$Dialouge/MarginContainer/Label.text = "This place is too dangerous. Go ask the Smith for a better weapon."

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCursor"):
		in_range = false
		$Dialouge.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if in_range:
			$Dialouge.visible = true
			GameState.quest1_blachsmith_flag = true
