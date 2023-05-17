extends Node2D

onready var audio_success = $AudioSuccess
onready var audio_fail = $AudioFail
onready var pulse_tween = $PulseTween

var sound_success = preload("res://sounds/success-2.wav")
var sound_fail = preload("res://sounds/fail-2.wav")

func play_sound_and_pulse(was_success):
	var audio
	var sound

	if was_success:
		sound = sound_success
		audio = audio_success
	else:
		sound = sound_fail
		audio = audio_fail
	
	audio.stream = sound
	audio.play()
	pulse_tween.pulse()

func entered(area):
	var moveable = area.get_parent()
	if not (moveable is Moveable):
		print("potential bug: non-moveable detected by zone %s" % [moveable])
		return
	
	var sound = null
	if moveable is Player:
		play_sound_and_pulse(false)
	elif moveable.is_in_group("enemy"): 
		play_sound_and_pulse(true)
	else:
		print("potential bug: moveable was not a player or enemy: %s" % [moveable])
		return
	
	play_sound_and_pulse(sound)
	moveable.damage()
	
func tick(_beat):
	pass

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")