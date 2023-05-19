extends Node2D

class_name Battlefield

signal completed
signal lost

var FOURFOUR_SIMPLE = [ U.BEAT.NOOP, U.BEAT.SHOW, U.BEAT.SHOW, U.BEAT.MOVE ]
var TRACKS = [[ MusicLoop.TRACKS.START_60BPM, FOURFOUR_SIMPLE, 60 ]]

onready var player = $Player
onready var goal = $Goal
onready var foreground = $ForegroundHolder/Foreground

var track = TRACKS[0]
var dead_enemies = {}
var goal_reached = false
var won = false

func fade_foreground(start_color, end_color, time_to_take):
	var t = Tween.new()
	t.interpolate_property(foreground, "color", start_color, end_color, time_to_take, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	add_child(t)
	t.start()

func gently_fade(time_to_take):
	fade_foreground(C.WHITE_TRANSPARENT, C.WHITE, time_to_take)

func fade_in(time_to_take, initial_load):
	if initial_load:
		fade_foreground(C.BLACK, C.BLACK_TRANSPARENT, time_to_take)
	else:
		fade_foreground(C.WHITE, C.WHITE_TRANSPARENT, time_to_take)

func level_won():
	var all_enemies_gone = (len(get_live_enemies()) == 0)
	return goal_reached and all_enemies_gone

func tick(beat):
	broadcast_tick(beat)
	# Maybe we should clear dead enemies here?
	clear_dead_enemies()

	match beat:
		U.BEAT.NOOP:
			pass
		U.BEAT.SHOW: 
			pass
		U.BEAT.MOVE:
			if won:
				pass
			else:
				move_player()
				move_enemies()
				clear_move_state()
	
	if not won and level_won():
		won = true
		player.state = player.S.FINISHED
		emit_signal("completed")
	
func handle_player_died():
	if true:
		print("The player died. Eventually we'll game over here, but that'd be bad for testing.")
	else:
		emit_signal("lost")

func broadcast_tick(beat):
	for enemy in get_enemies():
		enemy.tick(beat)

	for trap in get_traps():
		trap.tick(beat)
		
	player.tick(beat)

func clear_move_state():
	player.clear_move_state()
	for enemy in get_enemies():
		enemy.clear_move_state()

func move_player():
	var moves = player.get_moves()
	move(player, moves)

func clear_dead_enemies():
	for enemy in dead_enemies:
		enemy.die()
	dead_enemies = {}
 
func handle_enemy_died(enemy):
	dead_enemies[enemy] = true

func move_enemies():
	for enemy in get_enemies():
		move(enemy, enemy.get_moves())

func init_moveables():
	player.connect("died", self, "handle_player_died")
	for enemy in get_enemies():
		enemy.init(player)
		enemy.connect("died", self, "handle_enemy_died", [enemy])

func teleport_node(node):
	node.position = U.pos_to_world(node.teleport_to)
	node.set_has_been_teleported()

func move(node, moves):
	# Kinda feels like we should put this in moveable! but alas
	if len(moves) == 0: return

	var total_time = U.beat_time / 2
	var each_move_time = total_time / len(moves)
	var pos = U.pos_(node)
	var t = Tween.new()
	add_child(t)

	var i = 0
	for move in moves:

		if node in dead_enemies:
			break
		
		if node.should_teleport_on_next_move():
			pos = node.teleport_to
			teleport_node(node)

		# There's a chance that we need to wait some amount of time here to avoid false positives for the one-ways?
		# But I think this is fine.
		node.direction_right_this_second = move

		var new_pos = pos + U.d(move)
		var clamped = new_pos
		clamped.x = clamp(new_pos.x, 0, C.WIDTH - 1)
		clamped.y = clamp(new_pos.y, 0, C.HEIGHT - 1)

		if U.is_blocked(clamped):
			continue

		var move_to = U.pos_to_world(clamped)
		t.interpolate_property(node, "position", null, move_to, each_move_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		i += 1
		if i < len(moves):
			var next_move = moves[i]
			# Spin 270 degrees clockwise on all turns. Looks kinda neat?
			# It'd be nice if we did this counterclockwise for counterclockwise turns?
			var target_rotation = U.rotation(next_move)
			var current_rotation = U.rotation(move)
			var diff = abs(current_rotation - target_rotation)
			if 0 < diff and diff < 270:
				if current_rotation < target_rotation:
					current_rotation += 360
				else:
					target_rotation += 360

			t.interpolate_property(node.sprite, "rotation_degrees", current_rotation, target_rotation, each_move_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		t.start()
		yield(t, "tween_all_completed")
		pos = new_pos
	
	if node.should_teleport_on_next_move():
		# A teleporter was the last tile that we reached while moving
		teleport_node(node)

	t.call_deferred("queue_free")

func get_enemies():
	var e = []
	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			e.append(enemy)
	return e

func get_live_enemies():
	var e = []
	for enemy in get_enemies():
		if not enemy.dead:
			e.append(enemy)
	return e

func get_traps():
	var t = []
	for trap in get_children():
		if trap.is_in_group("trap"):
			t.append(trap)
	return t

func handle_goal_status_update(status):
	goal_reached = status

func _ready():
	init_moveables()
	goal.connect("goal_status", self, "handle_goal_status_update")
