extends Control

func _ready():
	$VBox/NewGameBtn.pressed.connect(_on_new_game)
	$VBox/LoadGameBtn.pressed.connect(_on_load_game)
	$VBox/SettingsBtn.pressed.connect(_on_settings)
	$VBox/QuitBtn.pressed.connect(_on_quit)
	$NewGameDialog/DialogVBox/StartBtn.pressed.connect(_on_start_game)
	$NewGameDialog/DialogVBox/CancelBtn.pressed.connect(_on_cancel_dialog)

	# Disable load button if no save exists
	if not SaveManager.has_save():
		$VBox/LoadGameBtn.disabled = true
		$VBox/LoadGameBtn.tooltip_text = "No saved game found"


func _on_new_game():
	$NewGameDialog.visible = true


func _on_start_game():
	var hospital_name = $NewGameDialog/DialogVBox/NameInput.text.strip_edges()
	if hospital_name.is_empty():
		hospital_name = "General Hospital"
	var game_scene = preload("res://scenes/game/game_world.tscn").instantiate()
	game_scene.hospital_name = hospital_name
	get_tree().root.add_child(game_scene)
	queue_free()


func _on_cancel_dialog():
	$NewGameDialog.visible = false


func _on_load_game():
	var state = SaveManager.load_game()
	if state.is_empty():
		return
	var game_scene = preload("res://scenes/game/game_world.tscn").instantiate()
	game_scene.loaded_state = state
	get_tree().root.add_child(game_scene)
	queue_free()


func _on_settings():
	# Settings placeholder - could open a settings dialog in the future
	pass


func _on_quit():
	get_tree().quit()
