extends State

#patrol logic

@export_group("Nodes")
@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var navigation: NavigationAgent2D

@export_group("Customizables")
@export var move_speed := 20.0
@export var detection_range : int = 100

var desired_position : Vector2
var player : CharacterBody2D
var room_position : Vector2
var room_size : Vector2

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
func Enter():
	#upon entering, randomizes a coordinate in the room to walk to
	#print_debug("Patrol")
	sprite.play("chase")
	room_position = enemy.room_position
	room_size = enemy.room_size
	
	var des_x = randf_range(room_position.x, room_position.x + room_size.x)
	var des_y = randf_range(room_position.y, room_position.y + room_size.y)
	desired_position = Vector2(des_x, des_y)
	navigation.target_desired_distance = 0.0
	navigation.target_position = desired_position

func Physics_Update(_delta: float):
	if player:
		#if it finds a player, transition to chase
		var direction = player.global_position - enemy.global_position
		if direction.length() < detection_range:
			Transitioned.emit(self, "Chase")
			return
		
		#if the navigation finishes, transition to idle
		if navigation.is_navigation_finished():
			Transitioned.emit(self, "Idle")
			return
	
	#move towards desired coordinates with navigation
	var new_velocity = (navigation.get_next_path_position() - enemy.global_position).normalized()
	new_velocity = new_velocity * move_speed
	enemy.velocity = new_velocity
	
	#flips sprite
	if enemy.velocity.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	enemy.move_and_slide()
	
