extends Node2D

#the item genreation below is(should be) totally static and could be 
# in any script file just testing it here for now
func _ready() -> void:
	SignalBus.connect("item_generated", Callable(self, "generate_item"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debuggenerateitem"):
		generate_item("Mainhand")

func generate_item(slot: String = ""):
	var new_item = ItemGeneration(slot)
	var item_id: int = new_item.keys()[0]
	GameData.item_data.merge(new_item)
	SignalBus.update_reward_item.emit(item_id)
	for i in PlayerData.inv_data.keys():
			if PlayerData.inv_data[i]["Item"] == 0:
				PlayerData.inv_data[i]["Item"] = item_id
				SignalBus.item_collected.emit()
				SignalBus.item_added.emit()
				break

func ItemGeneration(slot: String = "") -> Dictionary:
	var new_item: Dictionary = {}
	var new_item_dict: Dictionary = {}
	new_item["item_id"] = ItemDetermineType(slot)
	new_item["item_rarity"] = ItemDetermineRarity()
	new_item["item_name"] = ItemDetermineName(new_item["item_id"], new_item["item_rarity"])
	new_item["equipmentSlot"] = GameData.base_item_data[new_item["item_id"]]["equipmentSlot"]
	for i in GameData.item_stats:
		if GameData.base_item_data[new_item["item_id"]][i] != null:
			new_item[i] = ItemDetermineStats(new_item["item_id"], new_item["item_rarity"], i)
	new_item = RandomizeStats(new_item)
	var item_rarity_id = ItemDetermineUniqueId(new_item)
	new_item.erase("item_id")
	new_item_dict[item_rarity_id] = new_item
	return new_item_dict

func ItemDetermineType(slot: String = "") -> String:
	var new_item_type: String
	var item_types: Array = GameData.base_item_data.keys()
	if slot == "":
		randomize()
		new_item_type = item_types[randi() % item_types.size()]
		return new_item_type
	else:
		var specified_item_type: Array = []
		for i in GameData.base_item_data.keys():
			if GameData.base_item_data[i]["equipmentSlot"] == slot:
				specified_item_type.append(i)
		randomize()
		new_item_type = item_types[randi() % specified_item_type.size()]
		return new_item_type

func ItemDetermineRarity() -> String:
	var new_item_rarity: String
	var item_rarities: Array = GameData.item_rarity_ditribution.keys()
	randomize()
	var rarity_roll: float = randf_range(0.0, 100)
	for i in item_rarities:
		if rarity_roll <= GameData.item_rarity_ditribution[i]:
			new_item_rarity = i
			break
		else:
			rarity_roll -=GameData.item_rarity_ditribution[i]
	return new_item_rarity

func RandomizeStats(item: Dictionary) -> Dictionary:
	var result: Dictionary = item
	var stats_deleted = 0
	var item_stats = []
	for i in GameData.item_randomized_stats:
		if item[i] != 0:
			item_stats.append(i)
	randomize()
	if(item["item_rarity"] == "common"): stats_deleted = 3
	if(item["item_rarity"] == "uncommon"): stats_deleted = randi_range(2,3)
	if(item["item_rarity"] == "rare"): stats_deleted = randi_range(1,2)
	if(item["item_rarity"] == "epic"): stats_deleted = randi_range(0,1)
	while(stats_deleted > 0):
		randomize()
		var random_stat = item_stats[randi_range(0, item_stats.size()-1)]
		if stats_deleted == item_stats.size(): #have at least 1 stat
			stats_deleted -= 1
		elif item[random_stat] !=0:
			if random_stat == "Accuracy" and item["equipmentSlot"] == "Mainhand":
				pass #always have accuracy on mainhand
			else:
				item[random_stat] = 0
				stats_deleted -= 1
	return result

func ItemDetermineStats(item_id, item_rarity, stat) -> float:
	var stat_value: float
	if GameData.item_scaling_stats.has(stat):
		stat_value = GameData.base_item_data[item_id][stat] * GameData.base_item_data[item_id][item_rarity + "Multi"]
	else:
		stat_value = GameData.base_item_data[item_id][stat]
	return stat_value

func ItemDetermineUniqueId(item :Dictionary) -> int:
	var new_item_type_int = int(item["item_id"])
	var item_rarities: Array = GameData.item_rarity_ditribution.keys()
	if(item["item_rarity"] != "common"):
		for i in item_rarities:
			new_item_type_int += 1000
			if item["item_rarity"] == i:
				break
	while(GameData.item_data.has(new_item_type_int)):
		new_item_type_int += 1
	return new_item_type_int

func ItemDetermineName(base_item_id: String, rarity: String) -> String:
	var item_name: String
	item_name =  str(GameData.base_item_data[base_item_id]["name"]) + "_" + rarity
	return item_name
