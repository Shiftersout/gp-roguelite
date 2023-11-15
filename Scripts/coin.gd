extends Node2D

@onready var obtained = false
@onready var audio = $AudioStreamPlayer2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not obtained:
		obtained = true
		body.obtain_coin()
		audio.play()
		hide()

func _on_audio_stream_player_2d_finished():
	queue_free()
