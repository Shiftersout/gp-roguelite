extends Node2D

@export var weapon_scene : Resource
@export var sprite : Sprite2D
@export var damage : int = 1

func on_interact(player):
	player.trade_weapon(weapon_scene, damage)
	get_parent().queue_free()

func on_inspection():
	sprite.use_parent_material = true

func on_stop_inspection():
	sprite.use_parent_material = false

func on_consuming(player):
	pass
