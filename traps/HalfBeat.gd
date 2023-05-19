extends GenericTrap

# Originally this fired on the and of four (thus HalfBeat) but I realized that firing on 1 was almost as good
# and much easier to reason about. It'd still be cool to add some kind of timing element to the game though.

onready var grid_tween = $GridTween
onready var grid_color_tween = $GridColorTween
onready var center_color_tween = $CenterColorTween

var penalized = {}
var tracking = {}
var firing = false

func pulse(_amount=null):
	.pulse(U.v(1.25, 1.25))
	grid_tween.pulse(U.v(0.9, 0.9))

func pulse_center_red():
	grid_tween.pulse(U.v(1.25, 1.25))
	.pulse(U.v(1.25, 1.25))
	grid_color_tween.pulse(C.RED)
	center_color_tween.pulse(C.RED)
	
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
		U.BEAT.NOOP:
			clear_penalties()
			firing = true
			pulse_center_red()
		U.BEAT.SHOW:
			firing = false
			pulse()
		U.BEAT.MOVE:
			firing = false
			pulse()

func _ready():
	pulse_tween.target = $Center
	grid_tween.target = $Grid
	
	grid_color_tween.target = $Grid
	grid_color_tween.property = "modulate"
	grid_color_tween.final_amount = C.BLUE

	center_color_tween.target = $Center
	center_color_tween.property = "modulate"
	center_color_tween.final_amount = C.BLUE

	var _ignore = $Area2D.connect("area_entered", self, "entered")
	_ignore = $Area2D.connect("area_exited", self, "exited")

func _process(_delta):
	if firing: penalize_if_present()
