extends Node

func v(x, y): return Vector2(x, y)

enum D { NONE, UP, DOWN, LEFT, RIGHT }
enum BEAT { NOOP, SHOW, EXECUTE }

func d(d_):
	match d_:
		D.NONE: return v(0, 0)
		D.UP: return v(0, -1)
		D.DOWN: return v(0, 1)
		D.LEFT: return v(-1, 0)
		D.RIGHT: return v(1, 0)

func pos_(node):
	# Account for the fact that our proper grid starts at 1, 1
	var p = node.position - C.GRID_OFFSET
	var x = int(p.x / C.CELL_SIZE)
	var y = int(p.y / C.CELL_SIZE)
	return v(x, y)
