extends AudioStreamPlayer

var start_60bpm = preload("res://sounds/music/60bpm-basic.wav")
onready var fade_tween = $FadeTween

enum TRACKS { START_60BPM }
enum S { PLAYING, STOPPED }

var state = S.STOPPED

func gently_fade(time):
	fade_tween.interpolate_property(self, "volume_db", null, -60, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	fade_tween.start()
	yield(fade_tween, "tween_completed")
	
func track(t):
	match t:
		TRACKS.START_60BPM: return start_60bpm
		_:
			print("ERROR: track %s not found" % t)
			return null

func begin_playing(track_):
	print('begin playing track %s' % track_)
	seek(0)
	stream = track(track_)
	playing = true

func maybe_play_again(track_):
	match state:
		S.PLAYING: begin_playing(track_)
		S.STOPPED: pass
			
func start(track_):
	state = S.PLAYING
	fade_tween.stop_all()
	volume_db = -15
	begin_playing(track_)
	var _ignore = self.connect("finished", self, "maybe_play_again", [track_])

func stop():
	playing = false
	state = S.STOPPED
	self.disconnect("finished", self, "maybe_play_again")
