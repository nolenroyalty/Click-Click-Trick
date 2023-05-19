extends Node2D

# We add a 2 pixel wide white border and 8 pixels of black space around the battlefield
const TOTAL_BORDER_SIZE = 20

onready var outline = $BattlefieldOutline
onready var counter = $Counter
onready var beat_timer = $BeatTimer
onready var reset_button = $ResetButton
onready var directive = $Directive

enum S { LOADING, WAIT, TICKING, COMPLETED }
var LEVEL_POSITION

var track
var beat_count
var state
var level_index = 5
var level
var initial_load = true
  
var LEVELS = [
	preload("res://levels/Sandbox.tscn"),
	preload("res://levels/Level1.tscn"), # 1
	preload("res://levels/LevelIntroduceDefeatEnemy.tscn"),
	preload("res://levels/LevelIntroduceTeleporter.tscn"),
	preload("res://levels/LevelIntroduceTeleportEnemy.tscn"),
	preload("res://levels/LevelTeleportEnemyOut.tscn"), # 5
	preload("res://levels/LevelWin.tscn") # HANDLE WINNING THE GAME
]

func gently_fade(number_of_beats):
	var time_to_take = U.beat_time * number_of_beats
	level.gently_fade(time_to_take * ((float(number_of_beats) - 1) / float(number_of_beats)))
	MusicLoop.gently_fade(time_to_take)
	counter.stop_in_this_many_beats = number_of_beats

func stop_music_and_free_level():
	state = S.COMPLETED
	stop_music()
	beat_timer.stop()
	level.call_deferred("queue_free")
	# It's ugly that we do this here instead of in Battlefield, but it ensures that we do this
	# after prior resources have loaded and before the next ones do
	U.clear_tracked_squares()

func handle_level_completed(index):
	print("Level %s completed" % [index])

	# var number_of_beats = len(_beats())
	# var time_to_take = U.beat_time * number_of_beats
	# level.gently_fade(time_to_take * ((float(number_of_beats) - 1) / float(number_of_beats)))
	# MusicLoop.gently_fade(time_to_take)
	# counter.stop_in_this_many_beats = len(_beats())
	gently_fade(len(_beats()))
	yield(get_tree().create_timer(U.beat_time * len(_beats())), "timeout")
	stop_music_and_free_level()

	level_index += 1
	if level_index >= len(LEVELS):
		print("WON THE GAME!!!")
		# Do Something Here
		return

	load_level(level_index, false)

func handle_level_reset():
	match state:
		S.WAIT, S.LOADING, S.COMPLETED: return
		S.TICKING: pass
	
	state = S.LOADING

	print("Level %s reset" % [level_index])
	gently_fade(2)
	yield(get_tree().create_timer(U.beat_time), "timeout")

	stop_music_and_free_level()
	load_level(level_index, true)


func load_level(index, is_reset):
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
	if is_reset: fade_in_time = 0.5
	
	level.fade_in(fade_in_time, initial_load)
	if initial_load:
		initial_load = false
		
	yield(get_tree().create_timer(fade_in_time), "timeout")
	
	U.set_bpm(_bpm())
	level.connect("completed", self, "handle_level_completed", [index])
	state = S.WAIT
	directive.set_text("space to start")
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
	reset_button.tick(beat)
	directive.tick(beat)

func start_ticking():
	directive.set_text("")
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
	if Input.is_action_just_pressed("game_start") and state == S.WAIT:
		start_ticking()

func _ready():
	LEVEL_POSITION = $BattlefieldOutline.position + (U.v(TOTAL_BORDER_SIZE, TOTAL_BORDER_SIZE) / 2)
	VisualServer.set_default_clear_color(Color("#1b1b17"))
	beat_timer.connect("timeout", self, "execute_tick")
	load_level(level_index, false)
	reset_button.connect("reset", self, "handle_level_reset")

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
