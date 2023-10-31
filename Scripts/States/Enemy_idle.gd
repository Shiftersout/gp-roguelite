extends State

#Idle logic

@export_group("Nodes")
@export var enemy : CharacterBody2D
@export var sprite : AnimatedSprite2D

@export_group("Customizables")
@export var detection_range : int = 100

var timer : Timer
var player : CharacterBody2D

func Enter():
	#upon entering, starts a timer
	timer = Timer.new()
	#print_debug("Idle")
	player = get_tree().get_first_node_in_group("player")
	sprite.play("idle")
	add_child(timer)
	timer.wait_time = randf_range(1.0, 3.0)
	timer.connect("timeout", _on_timer_timeout)
	timer.start()
	
func Exit():
	#deletes the timer upon exiting
	timer.queue_free()
	
func Physics_Update(_delta: float):
	#if it finds a player, transitions to chase
	if player:
		var direction = player.global_position - enemy.global_position
		if direction.length() < detection_range:
			Transitioned.emit(self, "Chase")

#when timer ends, transition to patrol
func _on_timer_timeout():
	Transitioned.emit(self, "Patrol")
