extends Node2D

onready var player = $Player
onready var beat_timer = $BeatTimer

enum BEAT { NOOP, SHOW, EXECUTE }
enum S { WAIT, TICKING }
const FOURFOUR_SIMPLE = [ BEAT.NOOP, BEAT.SHOW, BEAT.SHOW, BEAT.EXECUTE ]
const TRACKS = [[ MusicLoop.TRACKS.START_60BPM, FOURFOUR_SIMPLE, 60 ]]

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

	match beat:
		BEAT.NOOP:
			player.record()
		BEAT.SHOW:
			# Pulse enemies
			# Show each enemies' next move
			player.pulse()
		BEAT.EXECUTE:
			player.execute()
			# Move the player
			move(player, U.d(player.direction))
			move_enemies()
			# Move the enemies
			# Penalize enemies that fell for a trap
			# Remove dead enemies
			# Handle collisions for enemies / projectiles after removing dead ones

func _process(_delta):
	match state:
		S.WAIT:
			pass
		S.TICKING:
			pass

func move_enemies():
	for enemy in get_enemies():
		for direction in enemy.get_directions():
			print(direction)
			var d = U.d(direction)
			print(d)
			move(enemy, d)

func tick_enemies(beat):
	for enemy in get_enemies():
		enemy.tick(beat)

func init_enemies():
	for enemy in get_enemies():
		enemy.init(player)

func start_music():
	state = S.TICKING
	beat_timer.wait_time = 60.0 / _bpm()
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
	# print("%s | %s | %s | %s" % [pos_(node), pos, new_pos, clamped])
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

func _ready():
	start_music()
	init_enemies()
	width = $Grid.width
	height = $Grid.height

func _music():
	return track[0]

func _beats():
	return track[1]

func _bpm(): 
	return track[2]
