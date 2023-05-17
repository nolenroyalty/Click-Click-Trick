extends Node2D

onready var beat_count_label = $Container/BeatCount
onready var color_rect = $Container/ColorRect
onready var rect_tween = $RectTween

var beat = 0
var beat_count_max = 0
# var rect_max_width = 0

# func reset_color_rect():
#	color_rect.rect_scale.x = 1

func reset_and_count_down_color_rect():
	var total_amount_of_time = U.beat_time
	var time_to_tick_back_up = total_amount_of_time * 0.15
	var time_to_tick_down = total_amount_of_time * 0.80
	rect_tween.remove_all()
	rect_tween.start()
	rect_tween.interpolate_property(color_rect, "rect_scale:x", null, 1.0, time_to_tick_back_up, Tween.TRANS_QUAD, Tween.EASE_OUT)
	yield(rect_tween, "tween_completed")
	rect_tween.interpolate_property(color_rect, "rect_scale:x", null, 0, time_to_tick_down, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# rect_tween.remove_all()

func init(bcm):
	self.beat_count_max = bcm

func tick(_beat):
	beat = beat % beat_count_max
	beat_count_label.text = "%s / %s" % [beat + 1, beat_count_max]
	beat += 1
	reset_and_count_down_color_rect()
