extends Node2D

onready var player = $Player

var FOURFOUR_SIMPLE = [ U.BEAT.NOOP, U.BEAT.SHOW, U.BEAT.SHOW, U.BEAT.MOVE ]
var TRACKS = [[ MusicLoop.TRACKS.START_60BPM, FOURFOUR_SIMPLE, 60 ]]

var track = TRACKS[0]
var beat_count = 0
var width = 0
var height = 0
var dead_enemies = {}

func tick(beat):
	player.tick(beat)
	tick_enemies(beat)
	tick_traps(beat)

	match beat:
		U.BEAT.NOOP:
			clear_dead_enemies()
			# Maybe reset music if it's way off?
			pass
		U.BEAT.SHOW: 
			pass
			# $Grid.pulse()
		U.BEAT.MOVE:
			$Grid.pulse()
			move_player()
			move_enemies()
			clear_move_state()
			# Collision won't fire on this frame, so we can't handle
			# collisions here. We can either handle them on the next beat
			# (probably awkward from a gameplay perspective) or we can
			# handle them in the relevant trap code as they trigger.
			# I think the latter is the better option.

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

func tick_enemies(beat):
	for enemy in get_enemies():
		enemy.tick(beat)

func init_enemies():
	for enemy in get_enemies():
		enemy.init(player)
		enemy.connect("died", self, "handle_enemy_died", [enemy])

func tick_traps(beat):
	for trap in get_traps():
		trap.tick(beat)

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
		clamped.x = clamp(new_pos.x, 0, width - 1)
		clamped.y = clamp(new_pos.y, 0, height - 1)

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

func get_traps():
	var t = []
	for trap in get_children():
		if trap.is_in_group("trap"):
			t.append(trap)
	return t

func _ready():
	init_enemies()
	width = $Grid.width
	height = $Grid.height
	U.WIDTH = width
	U.HEIGHT = height
