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

func play_success_for_enemy_fail_for_player(moveable):
	if moveable is Player:
		play_fail()
		return true
	elif moveable.is_in_group("enemy"):
		play_success()
		return true
	else:
		print("Potential bug: moveable was nota  player or enemy! %s" % [moveable])
		return false

func pulse():
	pulse_tween.pulse()

func moveable_of_area(area):
	var moveable = area.get_parent()
	if not (moveable is Moveable):
		print("Potential bug: non-moveable detected by trap %s / %s.%s" % [ self, moveable, area] )
		return null
	return moveable

func tick(_beat):
	pass