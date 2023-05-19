extends AudioStreamPlayer

var start_60bpm = preload("res://sounds/music/60bpm-basic.wav")

enum TRACKS { START_60BPM }
enum S { PLAYING, STOPPED }

var state = S.STOPPED

func gently_fade(time):
	var t = Tween.new()
	t.interpolate_property(self, "volume_db", null, -35, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	add_child(t)
	t.start()
	yield(t, "tween_completed")
	
func track(t):
	match t:
		TRACKS.START_60BPM: return start_60bpm
		_:
			print("ERROR: track %s not found" % t)
			return null

func begin_playing(track_):
	seek(0)
	volume_db = 0
	stream = track(track_)
	playing = true

func maybe_play_again(track_):
	match state:
		S.PLAYING: begin_playing(track_)
		S.STOPPED:
			self.disconnect("finished", self, "maybe_play_again")

func start(track_):
	state = S.PLAYING
	begin_playing(track_)
	var _ignore = self.connect("finished", self, "maybe_play_again", [track_])

func stop():
	playing = false
	state = S.STOPPED
