extends HSlider

@export var channel : String = "Master"

	
func _value_changed(new_value):
	if new_value <= -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(channel), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(channel), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(channel), new_value)
	
	
