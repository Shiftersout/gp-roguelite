extends CharacterBody2D

## The speed of the character.
@export var move_speed : float = 128
@onready var sprite = $AnimatedSprite2D
@onready var weapon = $Weapon
@onready var raycast = $RayCast2D

var h_direction = 1

func _physics_process(_delta):
	move()
	flipSprite()
	rotateWeapon()
	move_and_slide()

## Handles basic character movement
func move():
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))

	velocity = input_direction.normalized() * move_speed

## Flips sprite to the right direction
func flipSprite():
	if velocity == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walking")
		
	if velocity.x > 0:
		h_direction = 1
	elif velocity.x < 0:
		h_direction = -1
		
	sprite.scale.x = h_direction
	
## Rotates the weapon
func rotateWeapon():
	weapon.look_at(get_global_mouse_position())
	raycast.look_at(get_global_mouse_position())
