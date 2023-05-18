extends GenericTrap

onready var grid_pulse_tween = $GridPulseTween

func entered(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	
	if success_or_fail(moveable):
		moveable.damage()
		pulse(U.v(1.1, 1.1))
		grid_pulse_tween.pulse(U.v(1.15, 1.15))
		

func tick(beat):
	match beat:
		U.BEAT.NOOP: pass
		U.BEAT.SHOW: pulse()
		U.BEAT.MOVE: pass

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")
	grid_pulse_tween.target = $Grid
