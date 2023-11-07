extends CharacterBody2D

#Enemy logic

@export_group("room_info")
@export var room_top_left : Vector2
@export var room_size: Vector2
@export var room_index : int

@export_group("status")
@export var health_points : int = 2

@export_group("nodes")
@export var animation_hit : AnimationPlayer

#on take damage
func take_damage(damage:int):
	animation_hit.play("hit")
	health_points -= damage
	if health_points <= 0:
		queue_free()

#if its hit by the player, take damage
func _on_hurt_box_area_entered(area):
	if area.is_in_group("player_hitbox"):
		
		take_damage(area.damage)
