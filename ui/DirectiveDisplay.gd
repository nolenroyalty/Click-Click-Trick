extends Node2D

onready var label = $CenterContainer/Label

func set_text(text):
	if text == null: label.text = ""
	else: label.text = text

func tick(beat):
	match beat:
		U.BEAT.SHOW, U.BEAT.NOOP: pass
		U.BEAT.MOVE: 	
			$PulseTween.pulse(0)

func _ready():
	$PulseTween.target = self
	$PulseTween.property = "modulate:a"
	$PulseTween.final_amount = 1