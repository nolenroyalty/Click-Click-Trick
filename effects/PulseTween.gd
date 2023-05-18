extends Tween

# Attach to any node with a Sprite child and call pulse() to make it pulse.
var target = null
var property = "scale"

func interp(time, start, end):
	var _ignore = interpolate_property(target, property, start, end, time, TRANS_QUAD, EASE_OUT)

func pulse(amount = U.v(1.1, 1.1)):
	# I don't quite understand why, but this doesn't look right if we divide time by 2.0 as you'd expect.
	# My bet is that there's a race and we call pulse a frame too early or late, so we're still in the
	# last frame of the prior animation when we call our next pulse. Or something. The behavior does
	# change if we don't provide "null" and instead provide 1, 1 or amount. Anyway, it's not a huge deal
	# and pulsing like this kinda looks nicer anyway so I'm not going to worry about it.
	var time = U.beat_time / 3.0
	interp(time, null, amount)
	var _ignore = start()
	yield(self, "tween_completed")
	interp(time, null, U.v(1, 1))
	_ignore = start()

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	if parent.has_node("Sprite") and target == null:
		target = parent.get_node("Sprite")
