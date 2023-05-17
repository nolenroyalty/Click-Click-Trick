extends Node2D

var PathingLine = preload("res://effects/PathingLine.tscn")

# func offset(d):
	# return (C.CELL_SIZE / 2) * U.d(d)
	
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
