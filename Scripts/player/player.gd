extends CharacterBody2D

@export_group("status")
@export var move_speed : float = 128
@export var health_points : int = 6
@export var coins : int = 0

@onready var sprite = $AnimatedSprite2D
@onready var hand = $Hand
@onready var raycast = $RayCast2D
@onready var animation = $AnimationPlayer
@onready var camera = $Camera2D

var h_direction = 1
var weapon : Node2D
var current_weapon = 0
var weapon_animation : AnimationPlayer
var weapon_particles : GPUParticles2D

var current_interactible

func _ready():
	var map = get_tree().get_first_node_in_group("tilemap")
	camera.limit_bottom = (map.map_h*16)
	camera.limit_right = (map.map_w*16)
	
	weapon = hand.get_child(current_weapon)
	weapon_animation = weapon.get_node("AnimationPlayer")
	weapon_particles = weapon.get_node("WeaponNode/GPUParticles2D")

func _physics_process(_delta):
	move()
	flipSprite()
	rotateWeapon()
	attack()
	cast_ray()
	move_and_slide()

## Handles basic character movement
func move():
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))

	velocity = input_direction.normalized() * move_speed

## Flips sprite to correct direction
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

## Play animation if player attacks
func attack():
	if Input.is_action_just_pressed("attack"):
		weapon_animation.play("charge")
	elif Input.is_action_just_released("attack"):
		if weapon_animation.is_playing() and weapon_animation.current_animation == "charge":
			weapon_animation.play("RESET")
		elif weapon_particles.emitting:
			weapon_animation.play("attack")

## Take damage
func take_damage(damage):
	health_points -= damage
	animation.play("take_damage")
	
	if health_points <= 0:
		print_debug("GAME OVER!")
	
	
func _input(event):
	if event.is_action_pressed("change_weapon"):
		current_weapon+=1
		if current_weapon > 1: current_weapon = 0
		change_weapon()
	
	if event.is_action_pressed("interact") and raycast.is_colliding():
		current_interactible = raycast.get_collider()
		if current_interactible .is_in_group("interactible"):
			current_interactible.on_interact(self)
			
func cast_ray():
	if raycast.is_colliding():
		current_interactible = raycast.get_collider()
		if current_interactible:
			if current_interactible.is_in_group("interactible"):
				current_interactible .on_inspection()
	else:
		if current_interactible and current_interactible.is_in_group("interactible"):
			current_interactible.on_stop_inspection()
		current_interactible = null
	
	
func trade_weapon(scene):
	if hand.get_child_count() < 2:
		hand.add_child(scene.instantiate())
		current_weapon = 1
		change_weapon()
	else:
		hand.get_child(current_weapon).queue_free()
		hand.add_child(scene.instantiate())
		current_weapon = 1
		weapon = hand.get_child(current_weapon)
		weapon_animation = weapon.get_node("AnimationPlayer")
		weapon_particles = weapon.get_node("WeaponNode/GPUParticles2D")

## Changes the weapon to current selected
func change_weapon():
	if hand.get_child_count() < 2:
		return false
		
	weapon.process_mode = Node.PROCESS_MODE_DISABLED
	weapon.visible = false
	weapon = hand.get_child(current_weapon)
	weapon.process_mode = Node.PROCESS_MODE_INHERIT
	weapon.visible = true
	weapon_animation = weapon.get_node("AnimationPlayer")
	weapon_particles = weapon.get_node("WeaponNode/GPUParticles2D")
	return true

## Take damage if hit by enemy 
func _on_hurt_box_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		take_damage(area.damage)
		
