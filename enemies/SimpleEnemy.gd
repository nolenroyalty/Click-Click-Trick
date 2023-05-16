extends Node2D

onready var sprite = $Sprite
var player : Node2D
var direction = U.D.NONE

func init(player_):
	player = player_

func player_direction():
	var my_pos = U.pos_(self)
	var player_pos = U.pos_(player)
	var dir = player_pos - my_pos

	if dir == Vector2.ZERO:
		return U.D.NONE

	var xabs = abs(dir.x)
	var yabs = abs(dir.y)

	if xabs > yabs:
		if dir.x > 0: return U.D.RIGHT
		else: return U.D.LEFT
	else:
		if dir.y > 0: return U.D.DOWN
		else: return U.D.UP

func display_current_move():
	# Copy-pasted!
	match direction:
		U.D.NONE:
			sprite.frame = 0
			sprite.rotation_degrees = 0
		U.D.UP:
			sprite.frame = 1
			sprite.rotation_degrees = 0
		U.D.DOWN:
			sprite.frame = 1
			sprite.rotation_degrees = 180
		U.D.LEFT:
			sprite.frame = 1
			sprite.rotation_degrees = -90
		U.D.RIGHT:
			sprite.frame = 1
			sprite.rotation_degrees = 90

func get_directions():
	return [direction]

func tick(beat):
	match beat:
		U.BEAT.NOOP:
			direction = U.D.NONE
		U.BEAT.SHOW:
			direction = player_direction()
			# Pulse?
		U.BEAT.EXECUTE:
			pass
	display_current_move()
