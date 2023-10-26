extends CharacterBody2D

@export_group("status")
@export var move_speed : float = 128
@export var health_points : int = 6

@onready var sprite = $AnimatedSprite2D
@onready var hand = $Hand
@onready var raycast = $RayCast2D
@onready var animation = $AnimationPlayer

var h_direction = 1
var weapon : Node2D
var weapon_animation : AnimationPlayer
var weapon_particles : GPUParticles2D

func _ready():
	weapon = hand.get_child(0)
	weapon_animation = weapon.get_node("AnimationPlayer")
	weapon_particles = weapon.get_node("WeaponNode/GPUParticles2D")

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
	hand.look_at(get_global_mouse_position())
	raycast.look_at(get_global_mouse_position())

func attack():
	if Input.is_action_just_pressed("attack"):
		weapon_animation.play("charge")
	elif Input.is_action_just_released("attack"):
		if weapon_animation.is_playing() and weapon_animation.current_animation == "charge":
			weapon_animation.play("RESET")
		elif weapon_particles.emitting:
			weapon_animation.play("attack")

func take_damage(damage):
	health_points -= damage
	animation.play("take_damage")

func _on_hurt_box_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		take_damage(area.damage)
		
