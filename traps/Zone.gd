extends Node2D

onready var audio = $AudioStreamPlayer2D
onready var pulse_tween = $PulseTween

var sound_success = preload("res://sounds/success-2.wav")
var sound_fail = preload("res://sounds/fail-2.wav")

# func get_enemy(area):
# 	var potential_enemy = area.get_parent()
# 	if potential_enemy.is_in_group("enemy"):
# 		return potential_enemy
# 	else:
# 		print("Potential bug: get_enemy called with something that wasn't an enemy! Area: %s | Parent: %s" % [area, potential_enemy])
# 		return null

func play_sound_and_pulse(sound):
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
		sound = sound_fail
	elif moveable.is_in_group("enemy"):
		sound = sound_success
	else:
		print("potential bug: moveable was not a player or enemy: %s" % [moveable])
		return
	
	play_sound_and_pulse(sound)
	moveable.damage()
	
func tick(_beat):
	pass

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")
	# _ignore = $Area2D.connect("area_exited", self, "exited")