extends Node2D

onready var outline = $Outline
onready var pulse_tween = $PulseTween
# We add a 2 pixel wide white border and 2 pixels of black space around the battlefield
const TOTAL_BORDER_SIZE = 4 * 2

func _ready():
	pulse_tween.target = outline
	pulse_tween.property = "rect_scale"
	var x = int(outline.rect_size.x)
	var y = int(outline.rect_size.y)
	assert((x - TOTAL_BORDER_SIZE) % C.CELL_SIZE == 0, "Border width must be a multiple of cell size")
	assert((y - TOTAL_BORDER_SIZE) % C.CELL_SIZE == 0, "Border height must be a multiple of cell size")
	# At this point this is probably just a fixed value, but hey, what if we want to change it.
	# We'll never change it.
	U.WIDTH = (x - TOTAL_BORDER_SIZE) / C.CELL_SIZE
	U.HEIGHT = (y - TOTAL_BORDER_SIZE) / C.CELL_SIZE

func pulse():
	pulse_tween.pulse(U.v(1.05, 1.05))

func tick(beat):
	match beat:
		U.BEAT.NOOP: pass
		U.BEAT.SHOW: pass
		U.BEAT.MOVE: pulse()
