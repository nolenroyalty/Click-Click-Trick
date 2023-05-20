extends GenericTrap

class_name GenericMovingZone

onready var top = $Top
onready var center = $Center
onready var center_sprite = $Center/CenterSprite
onready var bottom = $Bottom
onready var top_pulse_tween = $TopPulseTween
onready var bottom_pulse_tween = $BottomPulseTween
onready var top_color_tween = $TopColorTween
onready var bottom_color_tween = $BottomColorTween

export var distance = 2
export var center_position = 1
export var moving_down = true

func pick_pos_tween(is_top):
	if is_top:
		return top_pulse_tween
	else:
		return bottom_pulse_tween

func pick_color_tween(is_top):
	if is_top:
		return top_color_tween
	else:
		return bottom_color_tween

func safe_pulse(tween):
	tween.pulse(U.v(0.9, 0.9))

func danger_pulse(pos_tween, color_tween):
	pos_tween.pulse(U.v(1.25, 1.25))
	color_tween.pulse(C.RED)

func pulse_all_safe():
	safe_pulse(top_pulse_tween)
	safe_pulse(bottom_pulse_tween)

func tick_and_calculate_direction():
	if moving_down:
		center_position += 1

		if center_position == distance:
			# We're moving into the bottom position
			safe_pulse(top_pulse_tween)
			danger_pulse(bottom_pulse_tween, bottom_color_tween)
			moving_down = false
		else:
			pulse_all_safe()

		return U.D.DOWN
	else:
		center_position -= 1
		if center_position == 0:
			# We're moving into the top position
			moving_down = true
			safe_pulse(bottom_pulse_tween)
			danger_pulse(top_pulse_tween, top_color_tween)
		else:
			pulse_all_safe()
		return U.D.UP

func move_center():
	var direction = tick_and_calculate_direction()
	center.position = U.d(direction) * C.CELL_SIZE + center.position

func entered(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	
	if success_or_fail(moveable):
		moveable.damage()
		pulse(U.v(2.0, 2.0))
		# Maybe this should pulse the bottom or top if applicable too, idk

func tick(beat):
	move_center()
	match beat:
		U.BEAT.NOOP: pulse(U.v(1.25, 1.25))
		U.BEAT.SHOW: pulse(U.v(1.25, 1.25))
		U.BEAT.MOVE: pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pulse_tween.target = center_sprite
	top_pulse_tween.target = $Top
	bottom_pulse_tween.target = $Bottom
	top_color_tween.target = $Top
	bottom_color_tween.target = $Bottom
	top_color_tween.property = "modulate"
	bottom_color_tween.property = "modulate"
	top_color_tween.final_amount = C.BLUE
	bottom_color_tween.final_amount = C.BLUE

	var half_cell = int(C.CELL_SIZE / 2.0)
	center.position = U.v(center.position.x, half_cell + center_position * C.CELL_SIZE)

	var _ignore = $Center/Area2D.connect("area_entered", self, "entered")