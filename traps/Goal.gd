extends GenericTrap

onready var grid_tween = $GridTween

signal goal_status(reached)

func entered(area):
	var moveable = moveable_of_area(area)
	if not (moveable is Player):
		print("BUG: Non-player entered goal!")
		return
	
	pulse(U.v(1.5, 1.5))
	emit_signal("goal_status", true)
	# We need a different sound for reaching the goal, maybe
	play_success()

func exited(area):
	var moveable = moveable_of_area(area)
	if not (moveable is Player):
		print("BUG: Non-player exited goal!")
		return
	
	emit_signal("goal_status", false)

func pulse_standard():
	pulse(U.v(0.9, 0.9))
	grid_tween.pulse(U.v(0.9, 0.9))

# Called when the node enters the scene tree for the first time.
func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")
	_ignore = $Area2D.connect("area_exited", self, "exited")
	grid_tween.target = $Grid