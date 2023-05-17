extends GenericTrap

func entered(area):
	var moveable = moveable_of_area(area)
	if moveable == null: return
	
	if success_or_fail(moveable):
		moveable.damage()
		pulse()

func _ready():
	var _ignore = $Area2D.connect("area_entered", self, "entered")
