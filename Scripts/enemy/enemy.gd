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
@export var audio : AudioStreamPlayer2D

var coin_scene = load("res://Scenes/Itens/coin.tscn")
var heart_scene = load("res://Scenes/Itens/heart.tscn")
	
#on take damage
func take_damage(damage:int):
	animation_hit.play("hit")
	health_points -= damage
	if health_points <= 0:
		if randi_range(1, 5) == 5:
			var parent = get_parent()
			call_deferred("add_heart", parent, position)
			
			
		if randi_range(1, 3) == 3:
			var parent = get_parent()
			call_deferred("add_coin", parent, position)
			
		queue_free()

func add_heart(node, des_pos):
	var new_heart = heart_scene.instantiate()
	new_heart.position = des_pos
	node.add_child(new_heart)

func add_coin(node, des_pos):
	var new_coin = coin_scene.instantiate()
	new_coin.position = des_pos
	node.add_child(new_coin)

#if its hit by the player, take damage
func _on_hurt_box_area_entered(area):
	if area.is_in_group("player_hitbox"):
		take_damage(area.damage)
