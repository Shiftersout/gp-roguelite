extends Node

var menu_music = load("res://Audio/music/Abstraction - Three Red Hearts - Pixel War 1.ogg")
var game_music = load("res://Audio/music/Abstraction - Three Red Hearts - Penultimate.ogg")

func _ready():
	play_menu_music()
	
func play_menu_music():
	$Music.stream = menu_music
	$Music.play()

func play_game_music():
	$Music.stream = game_music
	$Music.play()
