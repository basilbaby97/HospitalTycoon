extends Node

const SAVE_DIR := "user://saves/"
const AUTOSAVE_FILE := "autosave.json"

func _ready():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(state: Dictionary, filename: String = "manual_save.json"):
	var save_data = {
		"version": 1,
		"saved_at": Time.get_datetime_string_from_system(),
		"game_state": state
	}
	var json_string = JSON.stringify(save_data, "  ")
	var file = FileAccess.open(SAVE_DIR + filename, FileAccess.WRITE)
	if file:
		file.store_string(json_string)

func load_game(filename: String = "manual_save.json") -> Dictionary:
	var file = FileAccess.open(SAVE_DIR + filename, FileAccess.READ)
	if file == null:
		return {}
	var json_string = file.get_as_text()
	var json = JSON.new()
	var result = json.parse(json_string)
	if result != OK:
		return {}
	var data = json.data
	if data is Dictionary and data.has("game_state"):
		return data["game_state"]
	return {}

func autosave(state: Dictionary):
	save_game(state, AUTOSAVE_FILE)

func has_save(filename: String = "manual_save.json") -> bool:
	return FileAccess.file_exists(SAVE_DIR + filename)

func list_saves() -> Array[String]:
	var saves: Array[String] = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				saves.append(file_name)
			file_name = dir.get_next()
	return saves

func delete_save(filename: String):
	DirAccess.remove_absolute(SAVE_DIR + filename)
