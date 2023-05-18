extends Node2D

onready var battlefield = $Battlefield
onready var counter = $Counter
onready var beat_timer = $BeatTimer

enum S { WAIT, TICKING }
var FOURFOUR_SIMPLE = [ U.BEAT.NOOP, U.BEAT.SHOW, U.BEAT.SHOW, U.BEAT.MOVE ]
var TRACKS = [[ MusicLoop.TRACKS.START_60BPM, FOURFOUR_SIMPLE, 60 ]]

var track = TRACKS[0]
var beat_count = 0
var state = S.WAIT

func execute_tick():
	match state:
		S.WAIT: return
		S.TICKING: pass
	
	var beat = get_beat()
	incr_beat()
	battlefield.tick(beat)
	counter.tick(beat)

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

var started = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and not started:
		start_music()
		started = true

func _ready():
	VisualServer.set_default_clear_color(Color("#1b1b17"))
	U.set_bpm(_bpm())
	counter.init(len(_beats()))

func incr_beat():
	beat_count = (beat_count + 1) % len(_beats())

func get_beat():
	return _beats()[beat_count]
	
func _music():
	return track[0]

func _beats():
	return track[1]

func _bpm(): 
	return track[2]
