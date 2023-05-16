extends Node2D

onready var border = $Border
# We add 1 pixel on each side to make our squares even, but we ignore that for width and height
const TOTAL_BORDER_SIZE = 2
var width
var height

func _ready():
	var x = int(border.rect_size.x)
	var y = int(border.rect_size.y)
	assert((x - TOTAL_BORDER_SIZE) % C.CELL_SIZE == 0, "Border width must be a multiple of cell size")
	assert((y - TOTAL_BORDER_SIZE) % C.CELL_SIZE == 0, "Border height must be a multiple of cell size")
	width = (x - TOTAL_BORDER_SIZE) / C.CELL_SIZE
	height = (y - TOTAL_BORDER_SIZE) / C.CELL_SIZE
