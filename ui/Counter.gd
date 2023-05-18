extends Node2D

onready var beat_count_label = $BeatCount
onready var color_rect = $ColorRect
onready var rect_tween = $RectTween
onready var label_tween = $LabelTween

var beat = 0
var beat_count_max = 0

func reset_and_count_down_color_rect():
	var total_amount_of_time = U.beat_time
	var time_to_tick_back_up = total_amount_of_time * 0.15
	var time_to_tick_down = total_amount_of_time * 0.80
	rect_tween.remove_all()
	rect_tween.start()
	rect_tween.interpolate_property(color_rect, "rect_scale:x", null, 1.0, time_to_tick_back_up, Tween.TRANS_QUAD, Tween.EASE_OUT)
	yield(rect_tween, "tween_completed")
	rect_tween.interpolate_property(color_rect, "rect_scale:x", null, 0, time_to_tick_down, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func init(bcm):
	self.beat_count_max = bcm
	self.beat = bcm
	beat_count_label.text = "1"
	color_rect.rect_scale.x = 1.0

func spin_label(new_beat):
	var time = U.beat_time / 2.0
	label_tween.interpolate_property(beat_count_label, "rect_rotation", 0, 360, time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	label_tween.interpolate_property(beat_count_label, "rect_scale", null, U.v(0.4, 0.4), time / 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	label_tween.interpolate_property(beat_count_label, "rect_scale", U.v(0.4, 0.4), U.v(1, 1), time / 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, time / 2.0)
	label_tween.start()
	yield(get_tree().create_timer(time / 2), "timeout")
	beat_count_label.text = new_beat

func tick(_beat):
	beat = beat % beat_count_max
	reset_and_count_down_color_rect()
	spin_label("%s" % (beat + 1))
	beat += 1
