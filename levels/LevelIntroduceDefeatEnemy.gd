extends Battlefield

enum STAGE 	{ TRICK_ENEMY,
	REACH_GOAL
}

enum STATE { SHOULD_DISPLAY, DISPLAYING }
var stage = STAGE.TRICK_ENEMY
var state = STATE.SHOULD_DISPLAY

func display_tutorial_text():
	match stage:
		STAGE.TRICK_ENEMY:
			display_directive("trick enemy")
		STAGE.REACH_GOAL:
			display_directive("reach goal")

func handle_enemy_died(enemy):
	.handle_enemy_died(enemy)
	match stage:
		STAGE.TRICK_ENEMY:
			stage = STAGE.REACH_GOAL
			state = STATE.SHOULD_DISPLAY
			display_directive(null)
		STAGE.REACH_GOAL:
			pass

func handle_goal_status_update(status):
	.handle_goal_status_update(status)
	if stage == STAGE.REACH_GOAL and status == true:
		display_directive("good luck")

func tick(beat):
	.tick(beat)

	if beat == U.BEAT.NOOP and state == STATE.SHOULD_DISPLAY:
		display_tutorial_text()
		state = STATE.DISPLAYING