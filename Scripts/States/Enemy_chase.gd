extends State

@export_group("Nodes")
@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var navigation: NavigationAgent2D

@export_group("Customizables")
@export var move_speed := 30.0

var player : CharacterBody2D

func Enter():
	print_debug("Chase")
	sprite.play("chase")
	player = get_tree().get_first_node_in_group("player")
	navigation.target_desired_distance = 16.0
