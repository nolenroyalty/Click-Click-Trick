extends Node2D

onready var sprite = $Sprite

func set_color(is_player):
	if is_player: sprite.frame = 0
	else: sprite.frame = 1
	
func pulse():
	$PulseTween.pulse(U.v(1.2, 1.2))