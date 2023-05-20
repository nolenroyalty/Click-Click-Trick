extends Node

func v(x, y): return Vector2(x, y)

enum D { NONE = 1, UP = 2, DOWN = 3, LEFT = 4, RIGHT = 5 }
enum BEAT { NOOP = 1, SHOW = 2, MOVE = 3 }


var bpm = 0 setget set_bpm
var beat_time = 0
var PATHING
var blocked_squares = {}
var single_traps = {}
var teleporter_positions = {}

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

func is_single_trap(pos):
	return pos in single_traps

func is_teleporter(pos):
	return pos in teleporter_positions

func add_teleporter(node):
	teleporter_positions[pos_(node)] = node

func get_other_teleporter(pos):
	for teleporter in teleporter_positions:
		if teleporter != pos:
			return teleporter_positions[teleporter]

func add_single_trap(node):
	single_traps[pos_(node)] = true

func clear_tracked_squares():
	blocked_squares = {}
	single_traps = {}
	teleporter_positions = {}

func pathing_id(pos):
	return (int(pos.x) << 8) | int(pos.y)

func pathing_id_to_pos(id):
	return v(int(id) >> 8, int(id) & 0xFF)
