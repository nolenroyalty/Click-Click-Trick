extends Battlefield

enum STAGE 	{ MOVE_ONCE,
	MOVE_THRICE_DIFFERENT_DIRECTIONS,
	CANCEL_MOVE,
	HIT_SPACE,
	REACH_GOAL
}

enum STATE { SHOULD_DISPLAY, DISPLAYING }

var stage = STAGE.MOVE_ONCE
var state = STATE.SHOULD_DISPLAY
var tutorial_complete = false
onready var audio = $AudioStreamPlayer
var sound_success = preload("res://sounds/success-2.wav")

func next_stage():
	match stage:
		STAGE.MOVE_ONCE:
			stage = STAGE.MOVE_THRICE_DIFFERENT_DIRECTIONS
			state = STATE.SHOULD_DISPLAY
		STAGE.MOVE_THRICE_DIFFERENT_DIRECTIONS:
			stage = STAGE.CANCEL_MOVE
			state = STATE.SHOULD_DISPLAY
		STAGE.CANCEL_MOVE:
			stage = STAGE.HIT_SPACE
		STAGE.HIT_SPACE:
			stage = STAGE.REACH_GOAL
			tutorial_complete = true


func level_won():
	var other_conditions_met = .level_won()
	return (tutorial_complete and other_conditions_met)

func display_tutorial_text():
	match stage:
		STAGE.MOVE_ONCE:
			display_directive("move: down")
		STAGE.MOVE_THRICE_DIFFERENT_DIRECTIONS:
			display_directive("move more: right right up")
		STAGE.CANCEL_MOVE:
			display_directive("cancel move: down up")
		STAGE.HIT_SPACE:
			display_directive("cancel all: down left space")
		STAGE.REACH_GOAL:
			display_directive("reach goal")
	
func tick(beat):
	.tick(beat)

	if beat == U.BEAT.NOOP and state == STATE.SHOULD_DISPLAY:
		display_tutorial_text()
		state = STATE.DISPLAYING

func has_desired_moves(moves):
	match stage:
		STAGE.MOVE_ONCE:
			return U.D.DOWN in moves
		STAGE.MOVE_THRICE_DIFFERENT_DIRECTIONS:
			return len(moves) > 1 and U.D.RIGHT in moves and U.D.UP in moves
			# return [U.D.RIGHT, U.D.RIGHT, U.D.UP] == moves
	
	return null

func handle_moves_canceled_out(first, second):
	if stage == STAGE.CANCEL_MOVE:
		if (first == U.D.UP and second == U.D.DOWN) or (first == U.D.DOWN and second == U.D.UP):
			display_directive(null)
			yield(get_tree().create_timer(U.beat_time), "timeout")
			next_stage()
			state = STATE.DISPLAYING
			display_tutorial_text()

func handle_space_pressed():
	if stage == STAGE.HIT_SPACE:
		display_directive(null)
		yield(get_tree().create_timer(U.beat_time), "timeout")
		state = STATE.DISPLAYING
		next_stage()
		display_tutorial_text()

func maybe_complete_movement_tutorial(moves):
	if has_desired_moves(moves) == true:
		next_stage()

func move_player():
	maybe_complete_movement_tutorial(player.get_moves())
	.move_player()

func _ready():
	player.connect("moves_canceled_out", self, "handle_moves_canceled_out")
	player.connect("canceled_all_moves", self, "handle_space_pressed")
