extends Node2D

onready var label = $CenterContainer/Label
onready var text_tween = $TextTween


func fade_out_text():
	text_tween.interpolate_property(label, "modulate:a", 1, 0, U.beat_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	text_tween.start()
	yield(text_tween, "tween_completed")
	label.text = ""
	
func set_text(text):
	if text == null: 
		fade_out_text()
	else:
		text_tween.stop_all()
		label.modulate.a = 1
		label.text = text

func tick(beat):
	match beat:
		U.BEAT.SHOW, U.BEAT.NOOP: pass
		U.BEAT.MOVE: pass
			# $PulseTween.pulse(U.v(1.1, 1.1))

func _ready():
	$PulseTween.target = self
	$PulseTween.property = "scale"
	# $PulseTween.final_amount