extends State

#Meelee attack logic

@export_group("Nodes")
@export var animation : AnimationPlayer

func Enter():
	#on entering state, play warning animation
	print_debug("Attack")
	animation.play("warning")

#changes animation to attack if warning finished or change state to chase when attack ends
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "warning":
		animation.play("attack")
	
	if anim_name == "attack":
		animation.play("RESET")
		Transitioned.emit(self, "Chase")
