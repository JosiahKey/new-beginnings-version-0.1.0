extends Node2D

#the item genreation below is(should be) totally static and could be 
# in any script file just testing it here for now
func _ready() -> void:
	SignalBus.connect("item_generated", Callable(self, "generate_item"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debuggenerateitem"):
		generate_item()

func generate_item():
	if(GameData.item_data.size() >0):
		for i in PlayerData.inv_data.keys():
				if PlayerData.inv_data[i]["Item"] == null:
					PlayerData.inv_data[i]["Item"] = ItemGeneration()["item_id"]
					SignalBus.item_collected.emit()
					SignalBus.item_added.emit()
					break

func ItemGeneration() -> Dictionary:
	var new_item: Dictionary = {}
	new_item["item_id"] = ItemDetermineType()
	new_item["item_rarity"] = ItemDetermineRarity()
	print(new_item["item_rarity"])
	new_item["item_name"] = ItemDetermineName(new_item["item_id"])
	for i in GameData.item_stats:
		if GameData.item_data[new_item["item_id"]][i] != null:
			new_item[i] = ItemDetermineStats(new_item["item_id"], new_item["item_rarity"], i)
	
	print(new_item)
	return new_item

func ItemDetermineType() -> String:
	var new_item_type: String
	var item_types: Array = GameData.item_data.keys()
	randomize()
	new_item_type = item_types[randi() % item_types.size()]
	return new_item_type

func ItemDetermineRarity() -> String:
	var new_item_rarity: String
	var item_rarities: Array = GameData.item_rarity_ditribution.keys()
	randomize()
	var rarity_roll: int = randi() % 100 +1
	for i in item_rarities:
		if rarity_roll <= GameData.item_rarity_ditribution[i]:
			new_item_rarity = i
			break
		else:
			rarity_roll -=GameData.item_rarity_ditribution[i]
	return new_item_rarity

func ItemDetermineStats(item_id, item_rarity, stat) -> float:
	var stat_value: float
	if GameData.item_scaling_stats.has(stat):
		stat_value = GameData.item_data[item_id][stat] * GameData.item_data[item_id][item_rarity + "Multi"]
	else:
		stat_value = GameData.item_data[item_id][stat]
	return stat_value

func ItemDetermineName(item_id) -> String:
	var item_name: String
	item_name = str(GameData.item_data[item_id]["name"])
	return item_name
