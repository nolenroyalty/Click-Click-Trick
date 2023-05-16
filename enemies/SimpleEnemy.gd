extends Node2D

var PathingSquare = preload("res://effects/PathingSquare.tscn")

onready var sprite = $Sprite
onready var pulse_tween = $PulseTween
var player : Node2D
var direction = U.D.NONE
var number_of_moves = 2
var moves = []
var current_pathing_squares = []

func init(player_):
	player = player_

func d_player():
	var my_pos = U.pos_(self)
	var player_pos = U.pos_(player)
	return player_pos - my_pos

func moves_to_take_to_player():
	var d = d_player()
	# For our first move, we look at whether the distance in the x or y distance is larger and shrink that.
	# For additional moves we adjust the weighting of dx or dy based on past moves, so that we don't just
	# do a bunch of moves up or moves to the right since that'd be boring
	var default_weight = pow(2, number_of_moves)
	var weight = U.v(default_weight, default_weight)

	var next_moves = []

	for _i in range(number_of_moves):
		if d == Vector2.ZERO: 
			return next_moves

		var xabs = abs(d.x) * weight.x
		var yabs = abs(d.y) * weight.y

		if xabs > yabs:
			weight = weight * U.v(0.5, 1)
			if d.x > 0:
				next_moves.append(U.D.RIGHT)
				d.x -= 1
			else:
				next_moves.append(U.D.LEFT)
				d.x += 1
		else:
			weight = weight * U.v(1, 0.5)
			if d.y > 0:
				next_moves.append(U.D.DOWN)
				d.y -= 1
			else:
				next_moves.append(U.D.UP)
				d.y += 1
	return next_moves

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

func get_moves():
	return moves

func pulse():
	pulse_tween.pulse()

func clear_pathing():
	for square in current_pathing_squares:
		square.call_deferred("queue_free")
	current_pathing_squares = []

func clear_move_state():
	clear_pathing()
	moves = []

func sum_d_moves():
	var sum = Vector2()
	for move in moves:
		sum += U.d(move)
	return sum

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
			square.set_color(square.COLOR.ENEMY)
			current_pathing_squares.append(square)
			pos = d

func tick(beat):
	match beat:
		U.BEAT.NOOP:
			orient_for_first_move()
		U.BEAT.SHOW:
			moves = moves_to_take_to_player()
			orient_for_first_move()
			display_pathing()
			pulse()
		U.BEAT.MOVE:
			pass