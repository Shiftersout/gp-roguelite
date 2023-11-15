extends Control

var music_controller

@onready var paused = false
@onready var game_over = false

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	player.connect("game_over", _on_player_game_over)
	music_controller = get_tree().get_first_node_in_group("music")

func _input(event):
	if event.is_action_pressed("pause") and not game_over:
		pause()

func pause():
	paused = not paused
	get_tree().paused = paused
	visible = paused

func _on_player_game_over():
	game_over = true

func _on_back_button_pressed():
	pause()

func _on_menu_button_pressed():
	get_tree().paused = false
	music_controller.play_menu_music()
	get_tree().change_scene_to_file("res://Scenes/Menus/menu.tscn")
