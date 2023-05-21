extends Node2D

onready var label = $CenterContainer/Label
onready var text_tween = $TextTween
var pulsing = false

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

func allow_pulsing():
	pulsing = true

func tick(beat):
	match beat:
		U.BEAT.SHOW, U.BEAT.NOOP: pass
		U.BEAT.MOVE:
			if pulsing:
				$PulseTween.pulse(0)

func make_yellow():
	label.set("custom_colors/font_color", C.YELLOW)

func _ready():
	$PulseTween.target = self
	$PulseTween.property = "modulate:a"
	# $PulseTween.amount = 0.1
	$PulseTween.final_amount = 1
	# $PulseTween.final_amount
