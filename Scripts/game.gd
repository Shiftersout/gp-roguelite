extends Node2D

var music_controller

func _ready():
	music_controller = get_tree().get_first_node_in_group("music")
	music_controller.play_game_music()
