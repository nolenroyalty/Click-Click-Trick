extends Battlefield

enum STAGE 	{ PASS_THROUGH_TELEPORTER,
	REACH_GOAL
}

enum STATE { SHOULD_DISPLAY, DISPLAYING }
var stage = STAGE.PASS_THROUGH_TELEPORTER
var first = true

func handle_goal_status_update(status):
	.handle_goal_status_update(status)
	if stage == STAGE.REACH_GOAL and status == true:
		display_directive("tutorial over. good luck")

func tick(beat):
	.tick(beat)

	if first:
		display_directive("pass through teleporter")
		first = false

	var pos = U.pos_(player)
	if pos.x >= 7 and pos.y <= 1 and stage == STAGE.PASS_THROUGH_TELEPORTER:
		stage = STAGE.REACH_GOAL
		display_directive("reach goal")