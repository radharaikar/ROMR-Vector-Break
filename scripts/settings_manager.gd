class_name SettingsManager
extends RefCounted

# ==============================================================================
# VECTOR//BREAK — SETTINGS & AUDIO/VIDEO PERSISTENCE
# Handles Master/Music/SFX volume, Window mode, Resolution, Screen Shake,
# and Aim Sensitivity. Persisted safely to user://settings.cfg.
# ==============================================================================

const SETTINGS_PATH: String = "user://settings.cfg"

static var settings: Dictionary = {
	"master_volume": 0.85,
	"music_volume": 0.80,
	"sfx_volume": 0.90,
	"fullscreen": false,
	"resolution_w": 1280,
	"resolution_h": 720,
	"screen_shake": true,
	"aim_sensitivity": 1.0
}

static var _loaded: bool = false

static func get_settings() -> Dictionary:
	if not _loaded:
		load_settings()
	return settings

static func load_settings() -> void:
	_loaded = true
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		settings["master_volume"] = config.get_value("audio", "master_volume", 0.85)
		settings["music_volume"] = config.get_value("audio", "music_volume", 0.80)
		settings["sfx_volume"] = config.get_value("audio", "sfx_volume", 0.90)
		settings["fullscreen"] = config.get_value("video", "fullscreen", false)
		settings["resolution_w"] = config.get_value("video", "resolution_w", 1280)
		settings["resolution_h"] = config.get_value("video", "resolution_h", 720)
		settings["screen_shake"] = config.get_value("gameplay", "screen_shake", true)
		settings["aim_sensitivity"] = config.get_value("gameplay", "aim_sensitivity", 1.0)
	apply_all()

static func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", settings["master_volume"])
	config.set_value("audio", "music_volume", settings["music_volume"])
	config.set_value("audio", "sfx_volume", settings["sfx_volume"])
	config.set_value("video", "fullscreen", settings["fullscreen"])
	config.set_value("video", "resolution_w", settings["resolution_w"])
	config.set_value("video", "resolution_h", settings["resolution_h"])
	config.set_value("gameplay", "screen_shake", settings["screen_shake"])
	config.set_value("gameplay", "aim_sensitivity", settings["aim_sensitivity"])
	config.save(SETTINGS_PATH)

static func set_master_volume(val: float) -> void:
	settings["master_volume"] = clampf(val, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(max(0.0001, settings["master_volume"])))
		AudioServer.set_bus_mute(bus_idx, settings["master_volume"] <= 0.01)
	save_settings()

static func set_music_volume(val: float) -> void:
	settings["music_volume"] = clampf(val, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(max(0.0001, settings["music_volume"])))
	save_settings()

static func set_sfx_volume(val: float) -> void:
	settings["sfx_volume"] = clampf(val, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(max(0.0001, settings["sfx_volume"])))
	save_settings()

static func set_fullscreen(enabled: bool) -> void:
	settings["fullscreen"] = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

static func set_resolution(w: int, h: int) -> void:
	settings["resolution_w"] = w
	settings["resolution_h"] = h
	if not settings["fullscreen"]:
		DisplayServer.window_set_size(Vector2i(w, h))
	save_settings()

static func set_screen_shake(enabled: bool) -> void:
	settings["screen_shake"] = enabled
	save_settings()

static func set_aim_sensitivity(val: float) -> void:
	settings["aim_sensitivity"] = clampf(val, 0.2, 2.5)
	save_settings()

static func apply_all() -> void:
	set_master_volume(settings["master_volume"])
	set_music_volume(settings["music_volume"])
	set_sfx_volume(settings["sfx_volume"])
	set_fullscreen(settings["fullscreen"])
	set_screen_shake(settings["screen_shake"])
	set_aim_sensitivity(settings["aim_sensitivity"])
