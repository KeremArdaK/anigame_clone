extends Control



func _on_start_btn_pressed() -> void:
	SaveManager.load_game()
	get_tree().change_scene_to_file("res://Scenes/Menus/god_menu.tscn")

func _on_options_btn_pressed() -> void:
	pass # Replace with function body.

func _on_index_btn_pressed() -> void:
	pass # Replace with function body.


func _on_achievements_btn_pressed() -> void:
	pass # Replace with function body.

func _on_quit_btn_pressed() -> void:
	get_tree().quit()


