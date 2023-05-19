extends Node2D

onready var outline = $Outline
onready var pulse_tween = $PulseTween


func _ready():
	pulse_tween.target = outline
	pulse_tween.property = "rect_scale"

func pulse():
	pulse_tween.pulse(U.v(1.05, 1.05))

func tick(beat):
	match beat:
		U.BEAT.NOOP: pass
		U.BEAT.SHOW: pass
		U.BEAT.MOVE: pulse()
