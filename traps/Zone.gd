extends GenericTrap

func play_sound_and_pulse(was_success):
	if was_success: play_success()
	else: play_fail()
	
	pulse()

func entered(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	
	if play_success_for_enemy_fail_for_player(moveable):
		moveable.damage()

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")