extends CharacterBody2D

#Enemy logic

@export_group("room_info")
@export var room_position : Vector2
@export var room_size : Vector2

@export_group("status")
@export var health_points : int = 2

#on take damage (ADD ANIMATION (and audio, if there ever is going to be one)
func take_damage(damage:int):
	health_points -= damage
	if health_points <= 0:
		queue_free()

#if its hit by the player, take damage
func _on_hurt_box_area_entered(area):
	if area.is_in_group("player_hitbox"):
		take_damage(area.damage)
