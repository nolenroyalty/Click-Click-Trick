extends Node2D

class_name Moveable

signal died

var PathingSquare = preload("res://effects/PathingSquare.tscn")
onready var sprite = $Sprite
onready var pulse_tween = $PulseTween
var pathing_square_instance_for_stupid_hack = PathingSquare.instance()

var moves = []
var current_pathing_squares = []
var health = 1
var dead = false

func get_pathing_color():
	# SUrely there's a better way to do this
	return pathing_square_instance_for_stupid_hack.COLOR.ENEMY

func set_frame_for_move(move):
	var frame = 0
	match move:
		U.D.NONE: frame = 0
		U.D.UP: frame = 1
		U.D.DOWN: frame = 1
		U.D.LEFT: frame = 1
		U.D.RIGHT: frame = 1
	sprite.frame = frame

func set_rotation_for_move(move, amount=1):
	var rotation = U.rotation(move)
	rotation *= amount
	sprite.rotation_degrees = rotation

func orient_for_first_move():
	var first_move
	if len(moves) == 0: first_move = U.D.NONE
	else: first_move = moves[0]
	
	set_frame_for_move(first_move)
	set_rotation_for_move(first_move)

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
			square.position = d * C.CELL_SIZE + C.GRID_OFFSET
			get_parent().add_child(square)
			var color = get_pathing_color()
			square.set_color(color)
			current_pathing_squares.append(square)
			pos = d

func get_moves():
	return moves

func pulse():
	pulse_tween.pulse(U.v(1.2, 1.2))

func emit_died():
	print("I died! %s" % [ self ])
	dead = true
	emit_signal("died")

func damage():
	pulse()
	if health > 0:
		health -= 1
	if health <= 0:
		emit_died()
	
