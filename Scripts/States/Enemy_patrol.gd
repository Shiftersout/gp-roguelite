extends State

@export_group("Nodes")
@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var navigation: NavigationAgent2D

@export_group("Customizables")
@export var move_speed := 40.0

var desired_position

func Enter():
	sprite.play("chase")
	
