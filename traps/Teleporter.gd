extends Node2D

onready var area = $Area2D
var rng

func all_teleporters_other_than_me():
	var teleporters = get_tree().get_nodes_in_group("teleporter")
	if len(teleporters) <= 1: return null
	
	var teleporters_other_than_me = []
	for teleporter in teleporters:
		if teleporter != self:
			teleporters_other_than_me.append(teleporter)
	return teleporters_other_than_me

func pick_a_teleporter():
	var teleporters_other_than_me = all_teleporters_other_than_me()
	if teleporters_other_than_me == null: return null
	
	var teleporter = teleporters_other_than_me[rng.randi() % len(teleporters_other_than_me)]
	return teleporter

func teleport(node):
	var teleporter = pick_a_teleporter()

	if teleporter == null: 
		print("Likely bug: tried to teleport %s but there were no teleporters other than me (%s)" % [node, self])
		return
	
	if node.set_teleport_postiion_if_possible(U.pos_(teleporter)):
		# Play a sound?
		$PulseTween.pulse()

func handle_area_entered(node):
	var parent = node.get_parent()
	if parent is Moveable:
		teleport(parent)
	else:
		print("Likely bug - %s (parent %s) entered teleporter but it's not a Moveable" % [node, parent])

func handle_area_exited(node):
	var parent = node.get_parent()
	if parent is Moveable:
		if parent.has_been_teleported():
			parent.clear_teleportation_state()
	else:
		print("Likely bug - %s (parent %s) exited teleporter but it's not a Moveable" % [node, parent])

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	area.connect("area_entered", self, "handle_area_entered")
	area.connect("area_exited", self, "handle_area_exited")
