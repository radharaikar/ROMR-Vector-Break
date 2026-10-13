class_name SaveManager
extends RefCounted

# ==============================================================================
# VECTOR//BREAK — PERSISTENT SAVE / LOAD SYSTEM
# Manages user progression, currency, unlocks, skins, and campaign state.
# Saved to Godot's safe user data path: user://save_data.json
# ==============================================================================

const SAVE_PATH: String = "user://save_data.json"
const SAVE_VERSION: int = 1

# Default persistent data structure
static func get_default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"currency": 0,
		"reconstruction_cores": 1,
		"campaign_act": 1,
		"campaign_mission": 1,
		"unlocked_acts": [1],
		"completed_acts": [],
		"completed_missions": [],
		"unlocked_skins": ["skin_default"],
		"equipped_skin": "skin_default",
		"unlocked_biomes": ["neon_graveyard"],
		"selected_biome": "neon_graveyard",
		"unlocked_upgrades": {
			"upgrade_capacitor": false,
			"upgrade_nanocell": false,
			"upgrade_frame": false,
			"upgrade_targeting": false
		},
		"story_flags": {
			"saw_prologue": false,
			"oracle_warned": false,
			"mira_contacted": false
		},
		"stats": {
			"total_kills": 0,
			"total_ricochets": 0,
			"total_score": 0
		}
	}

# In-memory working cache
static var current_data: Dictionary = {}
static var _is_initialized: bool = false

static func get_data() -> Dictionary:
	if not _is_initialized or current_data.is_empty():
		load_data()
	return current_data

static func load_data(custom_path: String = SAVE_PATH) -> bool:
	_is_initialized = true
	if not FileAccess.file_exists(custom_path):
		current_data = get_default_data()
		return false
	
	var file = FileAccess.open(custom_path, FileAccess.READ)
	if not file:
		current_data = get_default_data()
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		# Corrupted or malformed file: Fall back to safe defaults
		current_data = get_default_data()
		return false
	
	var loaded = json.data
	if typeof(loaded) != TYPE_DICTIONARY:
		current_data = get_default_data()
		return false
	
	# Merge with defaults to ensure missing keys in older saves are filled
	current_data = _merge_with_defaults(loaded)
	return true

static func save_data(custom_path: String = SAVE_PATH) -> bool:
	if current_data.is_empty():
		current_data = get_default_data()
	
	var file = FileAccess.open(custom_path, FileAccess.WRITE)
	if not file:
		return false
	
	var json_string = JSON.stringify(current_data, "\t")
	file.store_string(json_string)
	file.close()
	return true

static func reset_data(custom_path: String = SAVE_PATH) -> void:
	current_data = get_default_data()
	save_data(custom_path)

static func has_active_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var data = get_data()
	var missions: Array = data.get("completed_missions", [])
	return missions.size() > 0 or get_story_flag("saw_prologue") or data.get("campaign_act", 1) > 1

static func reset_campaign_only(custom_path: String = SAVE_PATH) -> void:
	var data = get_data()
	data["campaign_act"] = 1
	data["campaign_mission"] = 1
	data["unlocked_acts"] = [1]
	data["completed_acts"] = []
	data["completed_missions"] = []
	data["story_flags"] = {
		"saw_prologue": false,
		"oracle_warned": false,
		"mira_contacted": false
	}
	save_data(custom_path)

# --- Currency Helpers ---

static func get_currency() -> int:
	return get_data().get("currency", 0)

static func add_currency(amount: int) -> int:
	if amount <= 0:
		return get_currency()
	var data = get_data()
	data["currency"] = data.get("currency", 0) + amount
	save_data()
	return data["currency"]

static func spend_currency(amount: int) -> bool:
	if amount <= 0:
		return true
	var data = get_data()
	var current = data.get("currency", 0)
	if current < amount:
		return false
	data["currency"] = current - amount
	save_data()
	return true

# --- Skin Helpers ---

static func is_skin_unlocked(skin_id: String) -> bool:
	var list: Array = get_data().get("unlocked_skins", [])
	return skin_id in list

static func unlock_skin(skin_id: String) -> bool:
	var data = get_data()
	var list: Array = data.get("unlocked_skins", [])
	if skin_id not in list:
		list.append(skin_id)
		data["unlocked_skins"] = list
		save_data()
		return true
	return false

static func equip_skin(skin_id: String) -> bool:
	if not is_skin_unlocked(skin_id):
		return false
	var data = get_data()
	data["equipped_skin"] = skin_id
	save_data()
	return true

static func get_equipped_skin() -> String:
	return get_data().get("equipped_skin", "skin_default")

# --- Upgrade Helpers ---

static func is_upgrade_unlocked(upgrade_id: String) -> bool:
	var upgrades: Dictionary = get_data().get("unlocked_upgrades", {})
	return upgrades.get(upgrade_id, false)

static func unlock_upgrade(upgrade_id: String) -> bool:
	var data = get_data()
	var upgrades: Dictionary = data.get("unlocked_upgrades", {})
	upgrades[upgrade_id] = true
	data["unlocked_upgrades"] = upgrades
	save_data()
	return true

# --- Revive Cores ---

static func get_reconstruction_cores() -> int:
	return get_data().get("reconstruction_cores", 0)

static func add_reconstruction_core(count: int = 1) -> void:
	var data = get_data()
	data["reconstruction_cores"] = data.get("reconstruction_cores", 0) + count
	save_data()

static func use_reconstruction_core() -> bool:
	var data = get_data()
	var count = data.get("reconstruction_cores", 0)
	if count <= 0:
		return false
	data["reconstruction_cores"] = count - 1
	save_data()
	return true

# --- Campaign & Act Unlocks ---

static func is_act_unlocked(act_number: int) -> bool:
	var acts: Array = get_data().get("unlocked_acts", [1])
	for a in acts:
		if int(a) == act_number:
			return true
	return false

static func unlock_act(act_number: int) -> void:
	var data = get_data()
	var acts: Array = data.get("unlocked_acts", [1])
	if not is_act_unlocked(act_number):
		acts.append(act_number)
		data["unlocked_acts"] = acts
		save_data()

static func complete_act(act_number: int) -> void:
	var data = get_data()
	var completed: Array = data.get("completed_acts", [])
	if not is_act_completed(act_number):
		completed.append(act_number)
		data["completed_acts"] = completed
	unlock_act(act_number + 1)
	if act_number + 1 <= 5:
		data["campaign_act"] = act_number + 1
	save_data()

static func is_act_completed(act_number: int) -> bool:
	var completed: Array = get_data().get("completed_acts", [])
	for a in completed:
		if int(a) == act_number:
			return true
	return false

# --- Story & Campaign Flags ---

static func set_story_flag(flag_name: String, value: bool = true) -> void:
	var data = get_data()
	var flags: Dictionary = data.get("story_flags", {})
	flags[flag_name] = value
	data["story_flags"] = flags
	save_data()

static func get_story_flag(flag_name: String) -> bool:
	var flags: Dictionary = get_data().get("story_flags", {})
	return flags.get(flag_name, false)

# --- Biome Progression & Unlocks ---

static func get_unlocked_biomes() -> Array:
	return get_data().get("unlocked_biomes", ["neon_graveyard"])

static func is_biome_unlocked(biome_id: String) -> bool:
	if biome_id == "neon_graveyard":
		return true
	var list: Array = get_unlocked_biomes()
	return biome_id in list

static func unlock_biome(biome_id: String) -> bool:
	if is_biome_unlocked(biome_id):
		return true
	var cost = BiomeData.get_biome_cost(biome_id)
	if get_currency() < cost:
		return false
	if spend_currency(cost):
		var data = get_data()
		var list: Array = data.get("unlocked_biomes", ["neon_graveyard"])
		if biome_id not in list:
			list.append(biome_id)
			data["unlocked_biomes"] = list
			save_data()
		return true
	return false

static func get_selected_biome() -> String:
	return get_data().get("selected_biome", "neon_graveyard")

static func set_selected_biome(biome_id: String) -> void:
	if is_biome_unlocked(biome_id):
		var data = get_data()
		data["selected_biome"] = biome_id
		save_data()

# --- Safe Migration Helper ---

static func _merge_with_defaults(loaded: Dictionary) -> Dictionary:
	var defaults = get_default_data()
	for key in defaults.keys():
		if not loaded.has(key):
			loaded[key] = defaults[key]
		elif typeof(defaults[key]) == TYPE_DICTIONARY and typeof(loaded[key]) == TYPE_DICTIONARY:
			for sub_key in defaults[key].keys():
				if not loaded[key].has(sub_key):
					loaded[key][sub_key] = defaults[key][sub_key]
	return loaded
