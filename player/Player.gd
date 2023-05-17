extends Moveable

class_name Player

enum S { RECORDING, MOVING }

var state = S.RECORDING

# Tweaks:
# * Don't allow queuing up an invalid move, just reject it
# * Fix d_moves logic now that we're using 3 moves

func add_move(move):
	match move:
		U.D.NONE: moves = [ U.D.NONE ]
		var other:
			if moves == [ U.D.NONE ]: moves = [ move ]
			elif len(moves) >= 3: moves = [ other ]
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

func sum_d_moves():
	var sum = Vector2()
	for move in moves:
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
