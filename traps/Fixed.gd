extends GenericTrap

func pulse(_amount=U.v(0.9, 0.9)):
	.pulse(U.v(0.9, 0.9))

func tick(beat):
	match beat:
		U.BEAT.NOOP: 
			pulse()
		U.BEAT.SHOW: 
			pulse()
		U.BEAT.MOVE:
			pulse()

func _ready():
	U.add_blocked_square(self)
	$PulseTween.final_amount = $Sprite.scale

func _process(_delta):
	if Input.is_action_just_pressed("DEBUG_pulse"):
		pulse()
