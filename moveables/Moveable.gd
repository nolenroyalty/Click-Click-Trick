extends Node2D

class_name Moveable

signal died

enum TELEPORT_STATE { NONE, SHOULD_TELEPORT, HAS_BEEN_TELEPORTED }

var PathingSquare = preload("res://effects/PathingSquare.tscn")
onready var sprite = $Sprite
onready var pulse_tween = $PulseTween

var moves = []
var current_pathing_squares = []
var health = 1
var dead = false
var teleport_to = null
var teleport_state = TELEPORT_STATE.NONE
var is_player = false
var direction_right_this_second = U.D.NONE

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
	var i = 0

	for move in moves:
		if move == U.D.NONE: continue
		var d = pos + U.d(move)
		if U.in_bounds(d):
			var square = PathingSquare.instance()
			var next_move = null

			if i + 1 < len(moves):
				var movement_for_next_move = U.d(moves[i + 1])
				if U.in_bounds(d + movement_for_next_move): next_move = moves[i+1]
			
			square.position = U.pos_to_world(d)
			get_parent().add_child(square)
			square.init(is_player, move, next_move)
			current_pathing_squares.append(square)
			pos = d
		
		i += 1

func handle_teleport_to(pos):
	teleport_to = pos
	# Maybe??
	pulse_tween.pulse()

func should_teleport_on_next_move():
	match teleport_state:
		TELEPORT_STATE.NONE: return false
		TELEPORT_STATE.SHOULD_TELEPORT: return true
		TELEPORT_STATE.HAS_BEEN_TELEPORTED: return false

func set_teleport_postiion_if_possible(pos):
	match teleport_state:
		TELEPORT_STATE.NONE:
			teleport_to = pos
			teleport_state = TELEPORT_STATE.SHOULD_TELEPORT
			return true
		TELEPORT_STATE.SHOULD_TELEPORT, TELEPORT_STATE.HAS_BEEN_TELEPORTED:
			return false

func set_has_been_teleported():
	match teleport_state:
		TELEPORT_STATE.NONE, TELEPORT_STATE.HAS_BEEN_TELEPORTED:
			print("LIkely bug - set_has_been_teleported called when state is not SHOULD_TELEPORT %s" % [self])
		TELEPORT_STATE.SHOULD_TELEPORT:
			teleport_state = TELEPORT_STATE.HAS_BEEN_TELEPORTED

func has_been_teleported():
	return teleport_state == TELEPORT_STATE.HAS_BEEN_TELEPORTED

func clear_teleportation_state():
	teleport_to = null
	teleport_state = TELEPORT_STATE.NONE

func get_moves():
	return moves

func pulse():
	pulse_tween.pulse(U.v(1.2, 1.2))
	for square in current_pathing_squares:
		square.pulse()

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
	
