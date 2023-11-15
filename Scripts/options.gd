extends Control
@onready var master_slider = $MainContainer/HBoxContainer/VBoxContainer/MasterHSlider
@onready var music_slider = $MainContainer/HBoxContainer/VBoxContainer/MusicHSlider
@onready var sounds_slider = $MainContainer/HBoxContainer/VBoxContainer/SoundsHSlider
@onready var audio = $AudioStreamPlayer

func _ready():
	master_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sounds_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/menu.tscn")


func _on_sounds_h_slider_drag_ended(value_changed):
	audio.play()
