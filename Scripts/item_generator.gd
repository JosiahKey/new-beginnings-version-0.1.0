extends Node2D

#the item genreation below is(should be) totally static and could be 
# in any script file just testing it here for now
func _ready() -> void:
	SignalBus.connect("item_generated", Callable(self, "generate_item"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debuggenerateitem"):
		generate_item()

func generate_item():
	var new_item = ItemGeneration()
	var item_id: int = new_item.keys()[0]
	GameData.item_data.merge(new_item)
	SignalBus.update_reward_item.emit(item_id)
	for i in PlayerData.inv_data.keys():
			if PlayerData.inv_data[i]["Item"] == 0:
				PlayerData.inv_data[i]["Item"] = item_id
				SignalBus.item_collected.emit()
				SignalBus.item_added.emit()
				break

func ItemGeneration() -> Dictionary:
	var new_item: Dictionary = {}
	var new_item_dict: Dictionary = {}
	new_item["item_id"] = ItemDetermineType()
	new_item["item_rarity"] = ItemDetermineRarity()
	new_item["item_name"] = ItemDetermineName(new_item["item_id"], new_item["item_rarity"])
	new_item["equipmentSlot"] = GameData.base_item_data[new_item["item_id"]]["equipmentSlot"]
	for i in GameData.item_stats:
		if GameData.base_item_data[new_item["item_id"]][i] != null:
			new_item[i] = ItemDetermineStats(new_item["item_id"], new_item["item_rarity"], i)
	var item_rarity_id = ItemDetermineRarityId(new_item["item_id"], new_item["item_rarity"])
	new_item.erase("item_id")
	new_item_dict[item_rarity_id] = new_item
	return new_item_dict

func ItemDetermineType() -> String:
	var new_item_type: String
	var item_types: Array = GameData.base_item_data.keys()
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
		stat_value = GameData.base_item_data[item_id][stat] * GameData.base_item_data[item_id][item_rarity + "Multi"]
	else:
		stat_value = GameData.base_item_data[item_id][stat]
	return stat_value

func ItemDetermineRarityId(new_item_type:String, rarity: String) -> int:
	#if item is uncommon or higher, generate new id
	var new_item_type_int = int(new_item_type)
	var item_rarities: Array = GameData.item_rarity_ditribution.keys()
	if(rarity != "common"):
		for i in item_rarities:
			new_item_type_int += 1000
			if rarity == i:
				break
		return new_item_type_int
	else:
		return int(new_item_type)

func ItemDetermineName(base_item_id: String, rarity: String) -> String:
	var item_name: String
	item_name =  str(GameData.base_item_data[base_item_id]["name"]) + "_" + rarity
	return item_name
