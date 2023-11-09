extends Control

#func _ready():
	#MusicController.play_music()
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
	

func _on_quit_pressed():
	get_tree().quit()

