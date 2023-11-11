extends Control

#func _ready():
	#MusicController.play_music()
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/credits.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/options.tscn")
	

func _on_quit_pressed():
	get_tree().quit()

