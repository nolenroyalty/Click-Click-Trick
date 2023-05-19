extends Moveable

class_name Player

const NUMBER_OF_MOVES_WE_CAN_TAKE = 3

onready var audio = $AudioStreamPlayer2D
var move_fail_sound = preload("res://sounds/unable-to-perform.wav")

enum S { LOADING, RECORDING, MOVING, FINISHED }
var state = S.LOADING

func this_would_put_us_out_of_bounds(moves_):
	var summed = sum_d_moves(moves_)
	summed += U.pos_(self)
	return  not U.in_bounds(summed)

func this_move_cancels_the_last_one(move):
	if len(moves) == 0: return false
	var last_move = moves[-1]
	return sum_d_moves([last_move, move]) == Vector2.ZERO

func play_bonk():
	audio.stream = move_fail_sound
	audio.play()

func add_move(move):
	match move:
		U.D.NONE: moves = []
		var new_move:
			var proposed_moves = []
			
			if this_move_cancels_the_last_one(new_move):
				# This move cancels out our last move
				# In another world we'd allow this to happen, and it could be interesting,
				# But I think it's easier to disallow it for now.
				moves.pop_back()
				return
			else:
				if moves == [ U.D.NONE ] or moves == [] or len(moves) >= NUMBER_OF_MOVES_WE_CAN_TAKE:
					proposed_moves = [ new_move ]
				else:
					proposed_moves = moves + [ new_move ]
				
				if this_would_put_us_out_of_bounds(proposed_moves):
					#  It'd be great if this respected teleportation!
					play_bonk()
				else:
					moves = proposed_moves

func get_move():
	if Input.is_action_just_pressed("player_up"): return U.D.UP
	elif Input.is_action_just_pressed("player_down"): return U.D.DOWN
	elif Input.is_action_just_pressed("player_left"): return U.D.LEFT
	elif Input.is_action_just_pressed("player_right"): return U.D.RIGHT
	elif Input.is_action_just_pressed("player_cancel"): return U.D.NONE
	else: return null

func sum_d_moves(moves_):
	var sum = Vector2()
	for move in moves_:
		sum += U.d(move)
	return sum

func tick(beat):
	match beat:
		U.BEAT.NOOP:
			direction_right_this_second = U.D.NONE
			state = S.RECORDING
			orient_for_first_move()
		U.BEAT.SHOW:
			pulse()
		U.BEAT.MOVE:
			state = S.MOVING

func _process(_delta):
	match state:
		S.LOADING: pass
		S.MOVING: pass
		S.RECORDING:
			var move = get_move()
			if move != null: 
				add_move(move)
				orient_for_first_move()
				display_pathing()
		S.FINISHED:
			pass

func _ready():
	health = 2
	is_player = true
