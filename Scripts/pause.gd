extends Control

@onready var paused = false

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
	paused = not paused
	get_tree().paused = paused
	visible = paused


func _on_back_button_pressed():
	pause()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/menu.tscn")
