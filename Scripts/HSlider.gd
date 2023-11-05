extends HSlider


	
func _value_changed(new_value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_value)
	
