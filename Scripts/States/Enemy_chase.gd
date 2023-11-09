extends State

#Chase logic

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
	#set target and distance upon entering state
	sprite.play("chase")
	navigation.target_desired_distance = 32.0
	navigation.target_position = player.global_position

func Physics_Update(_delta: float):
	#returns to idle if there is no player
	if not player:
		Transitioned.emit(self, "Idle")
		return
	
	#changes the attack direction
	attack.look_at(player.global_position)
	
	#transition to attack upon reaching target
	if navigation.is_target_reached():
		Transitioned.emit(self, "Attack")
		return
	
	#sets target to current player location and move towards it with navigation
	navigation.target_position = player.global_position
	var new_velocity = (navigation.get_next_path_position() - enemy.global_position).normalized()
	new_velocity = new_velocity * move_speed
	enemy.velocity = new_velocity
	
	#flips sprite
	if enemy.velocity.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	enemy.move_and_slide()
