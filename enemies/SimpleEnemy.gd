extends Moveable

var player : Node2D
var direction = U.D.NONE
var number_of_moves = 2
onready var audio = $AudioStreamPlayer
var sound_fail = preload("res://sounds/fail-2.wav")

func init(player_):
	player = player_

func d_player():
	var my_pos = U.pos_(self)
	var player_pos = U.pos_(player)
	return player_pos - my_pos

# func calculate_weightings(moves):
# 	var start_weight = pow(2, number_of_moves)
# 	var weights = U.v()

func pick_a_move(pos, player_pos):
	var d = player_pos - pos
	var xabs = abs(d.x)
	var yabs = abs(d.y)

	if xabs > yabs:
		if d.x > 0:
			return U.D.RIGHT
		else:
			return U.D.LEFT
	else:
		if d.y > 0:
			return U.D.DOWN
		else:
			return U.D.UP

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

func pathing_moves():
	var my_pos = U.pos_(self)
	var player_pos = U.pos_(player)
	var path = U.PATHING.get_point_path(U.pathing_id(my_pos), U.pathing_id(player_pos))

	var next_moves = []
	
	var current_pos = my_pos
	for point in path:
		var d = point - current_pos
		var dir = U.D.NONE
		var should_continue = false

		match [int(d.x), int(d.y)]:
			[0, 0]:
				should_continue = true
			[0, -1]: dir = U.D.UP
			[0, 1]: dir = U.D.DOWN
			[-1, 0]: dir = U.D.LEFT
			[1, 0]: dir = U.D.RIGHT
			_:
				print("BUG: Unexpected pathing info received %s -> %s : (%s, %s)" % [current_pos, point, d.x, d.y])
				should_continue = true
		
		if should_continue: continue
		
		if dir != U.D.NONE:
			current_pos = point
			next_moves.append(dir)
			if len(next_moves) >= number_of_moves:
				break
	
	return next_moves



func die():
	# Sound effect?
	var t = Tween.new()
	var final = Color(1, 1, 1, 0)
	t.interpolate_property(sprite, "modulate", null, final, U.beat_time / 2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	add_child(t)
	t.start()
	yield(t, "tween_completed")
	self.call_deferred("queue_free")

func tick(beat):
	if dead: return
	match beat:
		U.BEAT.NOOP:
			direction_right_this_second = U.D.NONE
			orient_for_first_move()
		U.BEAT.SHOW:
			# moves = moves_to_take_to_player()
			moves = pathing_moves()
			orient_for_first_move()
			display_pathing()
			pulse()
		U.BEAT.MOVE:
			pass

func player_entered_hurtbox(area):
	var p = area.get_parent()
	if not (p is Player):
		print("BUG: non-player entered hurtbox of %s" % [self])
		return

	player.damage()

	pulse(U.v(2.0, 2.0))

	audio.stream = sound_fail
	audio.play()

func _ready():
	._ready()
	$Hurtbox.connect("area_entered", self, "player_entered_hurtbox")
