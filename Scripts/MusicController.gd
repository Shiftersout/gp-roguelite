extends Node

var menu_music = load("res://Font/testeSom.mp3")

func _ready():
	play_music()
	
func play_music():
	$Music.stream = menu_music
	$Music.play()
