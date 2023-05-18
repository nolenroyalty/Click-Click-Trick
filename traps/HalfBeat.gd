extends GenericTrap

onready var grid_tween = $GridTween
onready var half_beat_tween = $HalfBeatTween

const BLUE_TRANSPARENT = Color("#9630408c")
const RED_TRANSPARENT = Color("#968e3a47")

var penalized = {}
var tracking = {}
var firing = false

func pulse(_amount=null):
	.pulse(U.v(1.2, 1.2))
	grid_tween.pulse()

func tween_half(property, start, end, duration, delay):
	half_beat_tween.interpolate_property($Center, property, start, end, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, delay)

func pulse_center_red():
	var half_beat = U.beat_time / 2
	var quarter_beat = U.beat_time / 4
	var full = U.v(1, 1)
	var double = U.v(2, 2)
	# grid_tween.pulse()
	tween_half("scale", full, double, quarter_beat, half_beat)
	tween_half("modulate", BLUE_TRANSPARENT, RED_TRANSPARENT, quarter_beat, half_beat)
	tween_half("scale", double, full, quarter_beat, quarter_beat + half_beat)
	tween_half("modulate", RED_TRANSPARENT, BLUE_TRANSPARENT, quarter_beat, quarter_beat + half_beat)
	half_beat_tween.start()
	yield(get_tree().create_timer(half_beat), "timeout")
	firing = true
	yield(get_tree().create_timer(half_beat), "timeout")
	firing = false

func clear_penalties():
	penalized = {}

func entered(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	tracking[moveable] = true

func exited(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	tracking.erase(moveable)

func penalize_if_present():
	if not firing: return

	for moveable in tracking.keys():
		if moveable in penalized: continue
		
		if success_or_fail(moveable):
			penalized[moveable] = true
			moveable.damage()

func tick(beat):
	match beat:
		U.BEAT.NOOP: pulse()
		U.BEAT.SHOW: pulse()
		U.BEAT.MOVE:
			clear_penalties()
			pulse_center_red()

func _ready():
	pulse_tween.target = $Center
	grid_tween.target = $Grid
	var _ignore = $Area2D.connect("area_entered", self, "entered")
	_ignore = $Area2D.connect("area_exited", self, "exited")

func _process(_delta):
	if firing: penalize_if_present()