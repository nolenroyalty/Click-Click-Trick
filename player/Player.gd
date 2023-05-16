extends Node2D

enum S { RECORDING, MOVING }

onready var sprite = $Sprite
onready var anim = $AnimationPlayer

var state = S.RECORDING
var direction = U.D.NONE

func display_current_move():
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
		
func record_move():
	if Input.is_action_just_pressed("player_up"): 
		direction = U.D.UP
	elif Input.is_action_just_pressed("player_down"):
		direction = U.D.DOWN
	elif Input.is_action_just_pressed("player_left"):
		direction = U.D.LEFT
	elif Input.is_action_just_pressed("player_right"):
		direction = U.D.RIGHT
	elif Input.is_action_just_pressed("player_cancel"):
		direction = U.D.NONE

func record():
	direction = U.D.NONE
	state = S.RECORDING
	display_current_move()

func execute():
	state = S.MOVING

func _process(_delta):
	match state:
		S.MOVING: pass

		S.RECORDING:
			var prior_direction = direction
			record_move()
			# Not sure if we should only display this on music ticks
			if prior_direction != direction:
				display_current_move()
	
	if C.DEBUG:
		if Input.is_action_just_pressed("DEBUG_pulse"):
			pulse()
		
func pulse():
	anim.play("pulse")