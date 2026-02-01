extends TextureButton


func _on_button_down() -> void:
	match name:
		"StartButton":
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
			LevelManager.start_level(0)
			LevelManager.set_level_state(LevelManager.LevelState.PLAYING)
		"SettingButton":
			get_tree().change_scene_to_file("res://Scenes/setting.tscn")
		"ExitButton":
			get_tree().quit()
