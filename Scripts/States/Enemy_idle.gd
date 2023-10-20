extends State

@export_group("Nodes")
@export var enemy : CharacterBody2D
@export var sprite : AnimatedSprite2D

@export_group("Customizables")
@export var detection_range : int = 100

var timer : Timer
var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func Enter():
	timer = Timer.new()
	print_debug("Idle")
	sprite.play("idle")
	add_child(timer)
	timer.wait_time = randf_range(1.0, 3.0)
	timer.connect("timeout", _on_timer_timeout)
	timer.start()

func Physics_Update(_delta: float):
	var direction = player.global_position - enemy.global_position
	if direction.length() < detection_range:
		Transitioned.emit(self, "Chase")

func _on_timer_timeout():
	Transitioned.emit(self, "Patrol")
