extends Node2D

enum S { RECORDING, MOVING }

var PathingSquare = preload("res://effects/PathingSquare.tscn")

onready var sprite = $Sprite
onready var pulse_tween = $PulseTween

var state = S.RECORDING
var direction = U.D.NONE

var moves = [ U.D.NONE ]
var current_pathing_squares = []

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

func add_move(move):
	match move:
		U.D.NONE: moves = [ U.D.NONE ]
		var other:
			if moves == [ U.D.NONE ]: moves = [ move ]
			elif len(moves) >= 2: moves = [ other ]
			else: moves.append(other)
			
			# Lets you cancel an "UP" by inputting a "DOWN" right after
			if sum_d_moves() == Vector2.ZERO: moves = []

func get_move():
	if Input.is_action_just_pressed("player_up"): return U.D.UP
	elif Input.is_action_just_pressed("player_down"): return U.D.DOWN
	elif Input.is_action_just_pressed("player_left"): return U.D.LEFT
	elif Input.is_action_just_pressed("player_right"): return U.D.RIGHT
	elif Input.is_action_just_pressed("player_cancel"): return U.D.NONE
	else: return null

func clear_pathing():
	for square in current_pathing_squares:
		square.call_deferred("queue_free")
	current_pathing_squares = []

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
		print("Me: %s | Square: %s | D: %s" % [pos, d, U.d(move)])
		if U.in_bounds(d):
			var square = PathingSquare.instance()
			square.position = d * C.CELL_SIZE
			get_parent().add_child(square)
			square.set_color(square.COLOR.PLAYER)
			current_pathing_squares.append(square)
			pos = d
		
func record():
	direction = U.D.NONE
	state = S.RECORDING

func execute():
	state = S.MOVING
	moves = []
	clear_pathing()

func get_moves(): return moves

func _process(_delta):
	match state:
		S.MOVING: pass

		S.RECORDING:
			var move = get_move()
			if move != null: 
				add_move(move)
				orient_for_first_move()
				display_pathing()
	
	if C.DEBUG:
		if Input.is_action_just_pressed("DEBUG_pulse"):
			pulse()
		
func pulse():
	pulse_tween.pulse()
