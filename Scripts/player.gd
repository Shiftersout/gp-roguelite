extends CharacterBody2D

## The speed of the character.
@export var move_speed : float = 128
@onready var sprite = $AnimatedSprite2D
@onready var weapon = $Weapon
@onready var raycast = $RayCast2D
@onready var weapon_animation = $Weapon/WeaponAnimationPlayer
@onready var particles = $Weapon/WeaponNode/GPUParticles2D

var h_direction = 1

func _physics_process(_delta):
	move()
	flipSprite()
	rotateWeapon()
	move_and_slide()
	attack()

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

func attack():
	if Input.is_action_just_pressed("attack"):
		weapon_animation.play("charge")
	elif Input.is_action_just_released("attack"):
		if weapon_animation.is_playing() and weapon_animation.current_animation == "charge":
			weapon_animation.play("cancel_attack")
		elif particles.emitting:
			weapon_animation.play("attack")
	
	if weapon_animation.current_animation == "attack" and !weapon_animation.is_playing():
		weapon_animation.play("cancel_attack")


func _on_weapon_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		weapon_animation.play("cancel_attack")
