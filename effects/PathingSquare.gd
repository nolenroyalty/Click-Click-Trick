extends Node2D

var PathingLine = preload("res://effects/PathingLine.tscn")
var PathingEnd = preload("res://effects/PathingEnd.tscn")

var end_for_pulsing = null
	
func init(is_player, this_move, next_move):
	var this_tile = PathingLine.instance()
	this_tile.position = U.center_in_world(this_tile.position)
	add_child(this_tile)
	this_tile.orient_and_set_color(is_player, this_move, false)

	if next_move:
		var next_tile = PathingLine.instance()
		add_child(next_tile)
		next_tile.position = U.center_in_world(next_tile.position)
		next_tile.orient_and_set_color(is_player, next_move, true)
	else:
		var end = PathingEnd.instance()
		add_child(end)
		end.set_color(is_player)
		end.position = U.center_in_world(end.position)
		end_for_pulsing = end
		# end.orient_and_set_color(is_player, this_move, true)

func pulse():
	if end_for_pulsing: end_for_pulsing.pulse()
