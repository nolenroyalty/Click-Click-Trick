extends Node2D

onready var sprite = $Sprite

func orient_and_set_color(is_player, direction, is_next_move):
	if is_player:
		sprite.frame = 0
	else:
		sprite.frame = 1
	
	var rot = 0

	match direction:
		U.D.UP:
			rot = 180
		U.D.RIGHT:
			rot = 270
		U.D.DOWN:
			rot = 0
		U.D.LEFT:
			rot = 90

	if is_next_move: rot += 180
	
	rotation_degrees = rot
