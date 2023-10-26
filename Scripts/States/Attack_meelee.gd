extends State

@export_group("Nodes")
@export var animation : AnimationPlayer

func Enter():
	print_debug("Attack")
	animation.play("warning")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "warning":
		animation.play("attack")
	
	if anim_name == "attack":
		animation.play("RESET")
		Transitioned.emit(self, "Chase")
