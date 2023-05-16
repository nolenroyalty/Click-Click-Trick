extends Node2D

onready var color_rect = $ColorRect
const PLAYER_COLOR = Color("#786b7636")
const ENEMY_COLOR = Color("#788e3a47")

enum COLOR { PLAYER, ENEMY }

func set_color(c):
	match c:
		COLOR.PLAYER: color_rect.color = PLAYER_COLOR
		COLOR.ENEMY: color_rect.color = ENEMY_COLOR
