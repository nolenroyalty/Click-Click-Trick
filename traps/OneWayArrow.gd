extends GenericTrap

# We could revisit this later and have these rotate in other directions

export(int, 0, 180) var INITIAL_ROTATION = 0
onready var flip_tween = $FlipTween
onready var grid_tween = $GridTween
onready var sprite = $Sprite

var current_rotation
var direction
var penalized = {}
var tracking = {}
var skip_first_flip = true

func set_direction_for_rotation():
	if current_rotation == 0 or current_rotation == 360:
		direction = U.D.RIGHT
	else:
		direction = U.D.LEFT

func flip():
	if skip_first_flip:
		skip_first_flip = false
		return
	
	var desired_rotation
	
	if current_rotation == 0:
		desired_rotation = 180
	elif current_rotation == 180:
		desired_rotation = 360
	elif current_rotation == 360:
		current_rotation = 0
		desired_rotation = 180
	
	var time = U.beat_time / 2
	var biggest = U.v(1, 1)
	var smallest = U.v(0.25, 0.25)
	flip_tween.interpolate_property(sprite, "rotation_degrees", current_rotation, desired_rotation, time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	flip_tween.interpolate_property(sprite, "scale", null, smallest, time / 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	flip_tween.interpolate_property(sprite, "scale", smallest, biggest, time / 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, time / 2.0)
	flip_tween.start()
	
	current_rotation = desired_rotation
	set_direction_for_rotation()

func begin_tracking(area):
	var moveable = moveable_of_area(area)
	if moveable == null:
		return
	if moveable in penalized:
		return
	tracking[moveable] = true

func stop_tracking(area):
	var moveable = moveable_of_area(area)
	if moveable == null:
		return
	if not tracking.erase(moveable):
		print("Potential bug: stopped tracking %s but we weren't tracking it! - %s" % [moveable, self])

func pulse_red():
	var time = U.beat_time / 3
	flip_tween.interpolate_property(self, "modulate", C.BLUE, C.RED, time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	flip_tween.interpolate_property(self, "modulate", C.RED, C.BLUE, time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, time)
	flip_tween.start()

func on_fail():
	play_fail()
	pulse()
	pulse_red()

func on_success():
	play_success()
	pulse()
	pulse_red()

func penalize_wrong_directions():
	for moveable in tracking.keys():
		if moveable in penalized:
			# We've already hurt this one!
			continue
		if moveable.direction_right_this_second != direction and moveable.direction_right_this_second != U.D.NONE:
			# We allow None because it allows a player to stop *on* the arrow and then bop out of it on the
			# next turn.
			if success_or_fail(moveable):
				penalized[moveable] = true
				moveable.damage()

func clear_penalties():
	penalized = {}

func _ready():
	sprite.rotation_degrees = INITIAL_ROTATION
	current_rotation = INITIAL_ROTATION
	set_direction_for_rotation()
	grid_tween.target = $Grid
	var _ignore = $Area2D.connect("area_entered", self, "begin_tracking")
	_ignore = $Area2D.connect("area_exited", self, "stop_tracking")

func _process(_delta):
	penalize_wrong_directions()

func tick(beat):
	match beat:
		U.BEAT.NOOP:
			flip()
		U.BEAT.SHOW:
			grid_tween.pulse(U.v(0.9, 0.9))
			pulse()
		U.BEAT.MOVE:
			grid_tween.pulse(U.v(0.9, 0.9))
			clear_penalties()
