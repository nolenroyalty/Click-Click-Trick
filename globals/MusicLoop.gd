extends AudioStreamPlayer

var start_60bpm = preload("res://sounds/music/60bpm-basic.wav")

enum TRACKS { START_60BPM }
enum S { PLAYING, STOPPED }

var state = S.STOPPED

func track(t):
	match t:
		TRACKS.START_60BPM: return start_60bpm
		_:
			print("ERROR: track %s not found" % t)
			return null

func begin_playing(track_):
	seek(0)
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
