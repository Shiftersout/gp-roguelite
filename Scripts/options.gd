extends Control
@onready var master_slider = $MainContainer/HBoxContainer/VBoxContainer/MasterHSlider
@onready var music_slider = $MainContainer/HBoxContainer/VBoxContainer/MusicHSlider
@onready var sounds_slider = $MainContainer/HBoxContainer/VBoxContainer/SoundsHSlider


func _ready():
	master_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sounds_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
