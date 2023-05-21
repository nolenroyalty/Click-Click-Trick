extends GenericTrap

var _sound_success = preload("res://sounds/teleportplayer.wav")
var _sound_fail = preload("res://sounds/teleportenemy.wav")

onready var area = $Area2D
onready var grid_tween = $GridTween
var _other_teleporter = null
var was_teleported_into = {}

func all_teleporters_other_than_me():
	var teleporters = get_tree().get_nodes_in_group("teleporter")
	if len(teleporters) <= 1: return null
	
	var teleporters_other_than_me = []
	for teleporter in teleporters:
		if teleporter != self:
			teleporters_other_than_me.append(teleporter)
	return teleporters_other_than_me

func find_other_teleporter():
	var teleporters_other_than_me = all_teleporters_other_than_me()
	if teleporters_other_than_me == null:
		print("Likely bug - didn't find any other teleporters %s" % [self])
		return null
	if len(teleporters_other_than_me) > 1:
		print("Likely bug - found too many other teleporters! %s" % [self])
		return null
	
	_other_teleporter = teleporters_other_than_me[0]

func get_other_teleporter():
	if _other_teleporter == null:
		find_other_teleporter()
	return _other_teleporter

func on_success():
	audio_success.stream = sound_success
	audio_success.play()
	audio_success.volume_db = -25

func on_fail():
	audio_fail.stream = sound_fail
	audio_fail.play()
	audio_fail.volume_db = -25

func pulse(amount=U.v(0.9, 0.9)):
	# This syntax is insane
	.pulse(amount)

func pulse_full():
	pulse(U.v(0.5, 0.5))
	grid_tween.pulse()

func teleport(node):
	var other_teleporter = get_other_teleporter()

	if other_teleporter == null:
		print("No other teleporter - can't teleport %s - bailing %s" % [node, self])
		return
	
	if node.set_teleport_postiion_if_possible(U.pos_(other_teleporter)):
		other_teleporter.was_teleported_into[node] = true
		print("tele state for %s from %s" % [node, self])
		success_or_fail(node, true)
		pulse_full()
		other_teleporter.pulse_full()

func tick(beat):
	match beat:
		U.BEAT.NOOP: pass
		U.BEAT.SHOW: pulse()
		U.BEAT.MOVE: pass

func handle_area_entered(node):
	var moveable = moveable_of_area(node)
	if not moveable: return
	if moveable in was_teleported_into:
		print("Not teleporting %s because it was teleported into this teleporter" % [moveable])
	else:
		print("Teleport %s - %s: %s" % [moveable, self, was_teleported_into])
		teleport(moveable)
	
func handle_area_exited(node):
	var parent = node.get_parent()
	if parent is Moveable:
		was_teleported_into.erase(parent)
		if parent.has_been_teleported():
			parent.clear_teleportation_state()
			print("Clear tele state for %s from %s" % [ parent, self])
	else:
		print("Likely bug - %s (parent %s) exited teleporter but it's not a Moveable" % [node, parent])

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("area_entered", self, "handle_area_entered")
	area.connect("area_exited", self, "handle_area_exited")
	sound_success = _sound_success
	sound_fail = _sound_fail
	grid_tween.target = $Grid

	U.add_teleporter(self)
