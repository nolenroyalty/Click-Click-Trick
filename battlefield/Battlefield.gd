extends Node2D

onready var player = $Player
onready var beat_timer = $BeatTimer

enum S { WAIT, TICKING }
var FOURFOUR_SIMPLE = [ U.BEAT.NOOP, U.BEAT.SHOW, U.BEAT.SHOW, U.BEAT.MOVE ]
var TRACKS = [[ MusicLoop.TRACKS.START_60BPM, FOURFOUR_SIMPLE, 60 ]]

var track = TRACKS[0]
var beat_count = 0
var state = S.WAIT
var width = 0
var height = 0

func get_beat():
	return _beats()[beat_count]

func incr_beat():
	beat_count = (beat_count + 1) % len(_beats())

func execute_tick():
	match state:
		S.TICKING:
			pass
		_: return
	
	var beat = get_beat()
	incr_beat()
	tick_enemies(beat)
	tick_traps(beat)

	match beat:
		U.BEAT.NOOP:
			player.record()
			# Remove dead enemies
		U.BEAT.SHOW:
			# Pulse enemies
			# Show each enemies' next move
			player.pulse()
		U.BEAT.MOVE:
			move_player()
			move_enemies()
			player.execute()
			# Collision won't fire on this frame, so we can't handle
			# collisions here. We can either handle them on the next beat
			# (probably awkward from a gameplay perspective) or we can
			# handle them in the relevant trap code as they trigger.
			# I think the latter is the better option.

func move_player():
	var moves = player.get_moves()
	for move in moves:
		move(player, U.d(move))
			
func _process(_delta):
	match state:
		S.WAIT:
			pass
		S.TICKING:
			pass

func move_enemies():
	for enemy in get_enemies():
		for direction in enemy.get_directions():
			move(enemy, U.d(direction))

func tick_enemies(beat):
	for enemy in get_enemies():
		enemy.tick(beat)

func init_enemies():
	for enemy in get_enemies():
		enemy.init(player)

func tick_traps(beat):
	for trap in get_traps():
		trap.tick(beat)

func start_music():
	state = S.TICKING
	beat_timer.wait_time = U.beat_time
	beat_timer.connect("timeout", self, "execute_tick")
	MusicLoop.start(_music())
	execute_tick()
	beat_timer.start()

func stop_music():
	state = S.WAIT
	beat_timer.stop()
	MusicLoop.stop()

func move(node, d):
	var pos = U.pos_(node)
	var new_pos = pos + d
	var clamped = new_pos
	clamped.x = clamp(new_pos.x, 0, width - 1)
	clamped.y = clamp(new_pos.y, 0, height - 1)
	node.position = clamped * C.CELL_SIZE + C.GRID_OFFSET
	if clamped != new_pos: return false
	else: return true

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
	U.set_bpm(_bpm())
	start_music()
	init_enemies()
	width = $Grid.width
	height = $Grid.height
	U.WIDTH = width
	U.HEIGHT = height


func _music():
	return track[0]

func _beats():
	return track[1]

func _bpm(): 
	return track[2]
