extends GenericTrap

func entered(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	
	if success_or_fail(moveable):
		moveable.damage()
		pulse(U.v(1.5, 1.5))
		

func tick(beat):
	match beat:
		U.BEAT.NOOP: pulse()
		U.BEAT.SHOW: pulse()
		U.BEAT.MOVE: pass

func pulse(_amount=null):
	.pulse(U.v(1.25, 1.25))

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")
	U.is_single_trap(self)
