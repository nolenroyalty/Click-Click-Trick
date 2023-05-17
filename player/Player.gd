extends Moveable

class_name Player

enum S { RECORDING, MOVING }

var state = S.RECORDING

# Tweaks:
# * Don't allow queuing up an invalid move, just reject it
# * Fix d_moves logic now that we're using 3 moves

func this_would_put_us_out_of_bounds(move):
	var summed = sum_d_moves(moves)
	summed += U.d(move)
	summed += U.pos_(self)
	return  not U.in_bounds(summed)

func this_move_cancels_the_last_one(move):
	if len(moves) == 0: return false
	var last_move = moves[-1]
	return sum_d_moves([last_move, move]) == Vector2.ZERO

func add_move(move):
	match move:
		U.D.NONE: moves = []
		var new_move:
			if moves == [ U.D.NONE ] or moves == []:
				moves = [ new_move ]
			elif len(moves) >= 3:
				moves = [ new_move ]
			elif this_would_put_us_out_of_bounds(new_move):
				# It'd be great if this could respect teleportation!
				return
			elif this_move_cancels_the_last_one(new_move):
				# This move cancels out our last move
				# In another world we'd allow this to happen, and it could be interesting,
				# But I think it's easier to disallow it for now.
				moves.pop_back()
			else:
				moves.append(new_move)

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
			state = S.RECORDING
			orient_for_first_move()
		U.BEAT.SHOW:
			pulse()
		U.BEAT.MOVE:
			state = S.MOVING

func _process(_delta):
	match state:
		S.MOVING: pass
		S.RECORDING:
			var move = get_move()
			if move != null: 
				add_move(move)
				orient_for_first_move()
				display_pathing()

func _ready():
	health = 2
	is_player = true
