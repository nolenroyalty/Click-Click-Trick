extends Node2D

# We add a 2 pixel wide white border and 8 pixels of black space around the battlefield
const TOTAL_BORDER_SIZE = 20

onready var outline = $BattlefieldOutline
onready var counter = $Counter
onready var beat_timer = $BeatTimer

enum S { LOADING, WAIT, TICKING, COMPLETED }
var LEVEL_POSITION

var track
var beat_count
var state
var level_index = 0
var level
var initial_load = true

var LEVELS = [
	preload("res://levels/Sandbox.tscn"),
	preload("res://levels/Level1.tscn"),
]

func handle_level_completed(index):
	print("Level %s completed" % [index])

	var number_of_beats = len(_beats())
	var time_to_take = U.beat_time * number_of_beats
	level.gently_fade(time_to_take * ((float(number_of_beats) - 1) / float(number_of_beats)))
	MusicLoop.gently_fade(time_to_take)
	counter.stop_in_this_many_beats = len(_beats())
	yield(get_tree().create_timer(time_to_take), "timeout")

	state = S.COMPLETED
	stop_music()
	beat_timer.stop()
	level.call_deferred("queue_free")

	level_index += 1
	if level_index >= len(LEVELS):
		level_index = 0
	
	load_level(level_index)

func load_level(index):
	state = S.LOADING
	stop_music()

	if level != null:
		level.call_deferred("queue_free")

	level = LEVELS[index].instance()
	track = level.track
	beat_count = 0
	level.position = LEVEL_POSITION
	add_child(level)
	var fade_in_time = 1.0
	
	level.fade_in(fade_in_time, initial_load)
	if initial_load:
		initial_load = false
		
	yield(get_tree().create_timer(fade_in_time), "timeout")
	
	U.set_bpm(_bpm())
	level.connect("completed", self, "handle_level_completed", [index])
	state = S.WAIT
	# reset counter? <- WHAT does that comment mean

func execute_tick():
	match state:
		S.WAIT, S.LOADING, S.COMPLETED: return
		S.TICKING: pass
	
	var beat = get_beat()
	incr_beat()
	level.tick(beat)
	counter.tick(beat)	
	outline.tick(beat)

func start_ticking():
	state = S.TICKING
	beat_timer.wait_time = U.beat_time
	counter.init(len(_beats()))
	MusicLoop.start(_music())
	execute_tick()
	beat_timer.start()

func stop_music():
	beat_timer.stop()
	MusicLoop.stop()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and state == S.WAIT:
		start_ticking()

func _ready():
	LEVEL_POSITION = $BattlefieldOutline.position + (U.v(TOTAL_BORDER_SIZE, TOTAL_BORDER_SIZE) / 2)
	VisualServer.set_default_clear_color(Color("#1b1b17"))
	beat_timer.connect("timeout", self, "execute_tick")
	load_level(level_index)

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
