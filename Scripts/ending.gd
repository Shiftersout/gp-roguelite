extends Control

var music_controller

func _ready():
	music_controller = get_tree().get_first_node_in_group("music")

func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	music_controller.play_menu_music()
	get_tree().change_scene_to_file("res://Scenes/Menus/menu.tscn")
