extends Node2D

onready var border = $Border
onready var pulse_tween = $PulseTween
# We add 1 pixel on each side to make our squares even, but we ignore that for width and height
const TOTAL_BORDER_SIZE = 2
var width
var height

func _ready():
	pulse_tween.target = border
	pulse_tween.property = "rect_scale"
	var x = int(border.rect_size.x)
	var y = int(border.rect_size.y)
	assert((x - TOTAL_BORDER_SIZE) % C.CELL_SIZE == 0, "Border width must be a multiple of cell size")
	assert((y - TOTAL_BORDER_SIZE) % C.CELL_SIZE == 0, "Border height must be a multiple of cell size")
	width = (x - TOTAL_BORDER_SIZE) / C.CELL_SIZE
	height = (y - TOTAL_BORDER_SIZE) / C.CELL_SIZE

func pulse():
	# This needs to pulse everything on the grid for it to work
	# pulse_tween.pulse(U.v(0.98, 0.98))
	pass
