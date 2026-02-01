extends TextureButton


func _on_button_down() -> void:
	print(name)
	match name:
		"StartButton":
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
		"SettingButton":
			pass
		"ExitButton":
			get_tree().quit()
