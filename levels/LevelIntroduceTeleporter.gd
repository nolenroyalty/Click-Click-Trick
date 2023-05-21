extends Battlefield

var first = true

func tick(beat):
	.tick(beat)

	if first:
		display_directive("reach goal")
		first = false