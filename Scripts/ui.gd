extends Control

@onready var life1 = $HBoxContainer/Life1
@onready var life2 = $HBoxContainer/Life2
@onready var life3 = $HBoxContainer/Life3

@onready var label = $HBoxContainer2/LabelCoins

@onready var weapon = $TextureRect/TextureRectWeapon

@onready var heart_full = load("res://Sprites/ui/hearth_complete.png")
@onready var heart_half = load("res://Sprites/ui/hearth_half.png")
@onready var heart_zero = load("res://Sprites/ui/hearth_zero.png")

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player.connect("hp_updated", _on_player_hp_updated)
	player.connect("coins_updated", _on_player_coins_updated)
	player.connect("weapon_changed", _on_player_weapon_changed)

## Uma das coisas mais horrorosas que eu ja fiz na minha vida.
func _on_player_hp_updated(hp):
	if hp <= 2:
		life1.texture = heart_full
		if hp <= 1:
			life1.texture = heart_half
			if hp <= 0:
				life1.texture = heart_zero
		life2.texture = heart_zero
		life3.texture = heart_zero
		
	elif hp <= 4:
		life2.texture = heart_full
		if hp <= 3:
			life2.texture = heart_half
		life1.texture = heart_full
		life3.texture = heart_zero
		
	elif hp <= 6:
		life3.texture = heart_full
		if hp <= 5:
			life3.texture = heart_half
		life1.texture = heart_full
		life2.texture = heart_full
	
func _on_player_coins_updated(c_value):
	label.text = "x " + c_value.to_string()

func _on_player_weapon_changed(weapon_image):
	weapon.texture = weapon_image
