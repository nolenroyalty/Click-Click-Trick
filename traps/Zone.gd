extends Node2D

onready var audio = $AudioStreamPlayer2D
onready var pulse_tween = $PulseTween

var present_enemies = {}
var sound_success = preload("res://sounds/success-1.wav")
var sound_fail = preload("res://sounds/fail-1.wav")

func display_success():
	audio.stream = sound_success
	audio.play()
	pulse_tween.pulse()

func get_enemy(area):
	var potential_enemy = area.get_parent()
	if potential_enemy.is_in_group("enemy"):
		return potential_enemy
	else:
		print("Potential bug: get_enemy called with something that wasn't an enemy! Area: %s | Parent: %s" % [area, potential_enemy])
		return null

func enemy_entered(area):
	var enemy = get_enemy(area)
	if enemy:
		display_success()
		present_enemies[enemy] = true

func enemy_exited(area):
	var enemy = get_enemy(area)
	if enemy:
		if present_enemies.erase(enemy):
			pass
		else:
			print("Enemy %s exited but was not in present_enemies" % [enemy])

func tick(_beat):
	pass

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "enemy_entered")
	_ignore = $Area2D.connect("area_exited", self, "enemy_exited")