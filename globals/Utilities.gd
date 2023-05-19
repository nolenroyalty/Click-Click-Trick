extends Node

func v(x, y): return Vector2(x, y)

enum D { NONE = 1, UP = 2, DOWN = 3, LEFT = 4, RIGHT = 5 }
enum BEAT { NOOP = 1, SHOW = 2, MOVE = 3 }


var bpm = 0 setget set_bpm
var beat_time = 0
var PATHING
var blocked_squares = {}
var path_through = {}

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
	var x = int(node.position.x / C.CELL_SIZE)
	var y = int(node.position.y / C.CELL_SIZE)
	return v(x, y)

func center_in_world(pos):
	return pos + v(1, 1) * C.CELL_SIZE / 2

func pos_to_world(pos):
	return pos * C.CELL_SIZE

func in_bounds(pos):
	return pos.x >= 0 and pos.x < C.WIDTH and pos.y >= 0 and pos.y < C.HEIGHT and not is_blocked(pos)

func set_bpm(bpm_):
	bpm = bpm_
	beat_time = 60.0 / bpm

func add_blocked_square(node):
	blocked_squares[pos_(node)] = true

func is_blocked(pos):
	return pos in blocked_squares

# We encourage the enemy to path through teleporters
func should_try_to_path_through(pos):
	return pos in path_through

func add_should_try_to_path_through(node):
	path_through[pos_(node)] = true

func clear_tracked_squares():
	blocked_squares = {}
	path_through = {}

func pathing_id(pos):
	return (int(pos.x) << 8) | int(pos.y)

func pathing_id_to_pos(id):
	return v(int(id) >> 8, int(id) & 0xFF)
