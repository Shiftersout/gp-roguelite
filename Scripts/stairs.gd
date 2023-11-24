extends Node2D

@export var sprite : Sprite2D
signal end_game

func on_interact(player):
	var end = get_tree().get_first_node_in_group("end")
	end.visible = true
	get_tree().paused = true

func on_inspection():
	sprite.use_parent_material = true

func on_stop_inspection():
	sprite.use_parent_material = false

func on_consuming(player):
	pass
