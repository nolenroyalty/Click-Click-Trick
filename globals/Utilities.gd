extends Node

func v(x, y): return Vector2(x, y)

enum D { NONE = 1, UP = 2, DOWN = 3, LEFT = 4, RIGHT = 5 }
enum BEAT { NOOP = 1, SHOW = 2, MOVE = 3 }
# Gross
var WIDTH
var HEIGHT

var bpm = 0 setget set_bpm
var beat_time = 0

func d(d_):
	match d_:
		D.NONE: return v(0, 0)
		D.UP: return v(0, -1)
		D.DOWN: return v(0, 1)
		D.LEFT: return v(-1, 0)
		D.RIGHT: return v(1, 0)

func rotation(d):
	match d:
		D.NONE: return 0
		D.UP: return 0
		D.DOWN: return 180
		D.LEFT: return 270
		D.RIGHT: return 90

func pos_(node):
	# Account for the fact that our proper grid starts at 1, 1
	var p = node.position - C.GRID_OFFSET
	var x = int(p.x / C.CELL_SIZE)
	var y = int(p.y / C.CELL_SIZE)
	return v(x, y)

func in_bounds(pos):
	return pos.x >= 0 and pos.x < WIDTH and pos.y >= 0 and pos.y < HEIGHT

func set_bpm(bpm_):
	bpm = bpm_
	beat_time = 60.0 / bpm
