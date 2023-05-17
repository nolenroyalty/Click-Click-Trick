extends Moveable

var player : Node2D
var direction = U.D.NONE
var number_of_moves = 2

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
			orient_for_first_move()
		U.BEAT.SHOW:
			moves = moves_to_take_to_player()
			orient_for_first_move()
			display_pathing()
			pulse()
		U.BEAT.MOVE:
			pass
