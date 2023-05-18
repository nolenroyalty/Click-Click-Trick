extends Node2D

class_name GenericTrap

onready var audio_success = $AudioSuccess
onready var audio_fail = $AudioFail
onready var pulse_tween = $PulseTween

var sound_success = preload("res://sounds/success-2.wav")
var sound_fail = preload("res://sounds/fail-2.wav")

func play_success():
	audio_success.stream = sound_success
	audio_success.play()

func play_fail():
	audio_fail.stream = sound_fail
	audio_fail.play()

func on_success():
	play_success()

func on_fail():
	play_fail()

func success_or_fail(moveable, triggering_is_good=false):
	var is_player = moveable is Player

	if not is_player and not moveable.is_in_group("enemy"):
		print("Potential bug: moveable was not a player or enemy! %s" % [moveable])
		return false

	if is_player == triggering_is_good:
		on_success()
	else:
		on_fail()
	
	return true

func pulse(amount=null):
	if amount: pulse_tween.pulse(amount)
	else: pulse_tween.pulse()

func moveable_of_area(area):
	var moveable = area.get_parent()
	if not (moveable is Moveable):
		print("Potential bug: non-moveable detected by trap %s / %s.%s" % [ self, moveable, area] )
		return null
	return moveable

func tick(_beat):
	pass