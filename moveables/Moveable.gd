extends Node2D

class_name Moveable

var PathingSquare = preload("res://effects/PathingSquare.tscn")
onready var sprite = $Sprite
onready var pulse_tween = $PulseTween
var pathing_square_instance_for_stupid_hack = PathingSquare.instance()

var moves = []
var current_pathing_squares = []

func get_pathing_color():
	# SUrely there's a better way to do this
	return pathing_square_instance_for_stupid_hack.COLOR.ENEMY

func orient_for_first_move():
	var first_move
	if len(moves) == 0: first_move = U.D.NONE
	else: first_move = moves[0]
	
	match first_move:
		U.D.NONE:
			sprite.frame = 0
			sprite.rotation_degrees = 0
		U.D.UP:
			sprite.frame = 1
			sprite.rotation_degrees = 0
		U.D.DOWN:
			sprite.frame = 1
			sprite.rotation_degrees = 180
		U.D.LEFT:
			sprite.frame = 1
			sprite.rotation_degrees = -90
		U.D.RIGHT:
			sprite.frame = 1
			sprite.rotation_degrees = 90

func clear_pathing():
	for square in current_pathing_squares:
		square.call_deferred("queue_free")
	current_pathing_squares = []

func clear_move_state():
	clear_pathing()
	moves = []

func display_pathing():
	clear_pathing()
	var pos = U.pos_(self)
	for move in moves:
		if move == U.D.NONE: continue
		var d = pos + U.d(move)
		if U.in_bounds(d):
			var square = PathingSquare.instance()
			square.position = d * C.CELL_SIZE
			get_parent().add_child(square)
			var color = get_pathing_color()
			square.set_color(color)
			current_pathing_squares.append(square)
			pos = d

func get_moves():
	return moves

func pulse():
	pulse_tween.pulse()
