extends Control
@onready var master_slider = $MainContainer/HBoxContainer/VBoxContainer/HSlider

func _ready():
	master_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
