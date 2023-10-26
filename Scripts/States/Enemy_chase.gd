extends State

@export_group("Nodes")
@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var navigation: NavigationAgent2D
@export var attack : Node2D

@export_group("Customizables")
@export var move_speed := 30.0

var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func Enter():
	print_debug("Chase")
	sprite.play("chase")
	navigation.target_desired_distance = 32.0
	navigation.target_position = player.global_position

func Exit():
	pass
	
func Physics_Update(_delta: float):
	if not player:
		Transitioned.emit(self, "Idle")
	
	attack.look_at(player.global_position)
	if navigation.is_target_reached():
		Transitioned.emit(self, "Attack")
		return
	
	navigation.target_position = player.global_position
	var new_velocity = (navigation.get_next_path_position() - enemy.global_position).normalized()
	new_velocity = new_velocity * move_speed
	enemy.velocity = new_velocity
	if enemy.velocity.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	enemy.move_and_slide()
