extends Node
## Crossfades recorded original arrangements. Works without audio synthesis at runtime.
var players: Array[AudioStreamPlayer]=[]
signal countdown_alert(seconds: int)
var countdown_player: AudioStreamPlayer
var effect: AudioStreamPlayer
var ui_player: AudioStreamPlayer
var hover_time: int=0
var arrival: AudioStreamPlayer
var transitioning: bool=false
var footsteps: AudioStreamPlayer
var active_track: int=-1
var current_player: int=0
var volume: float=.65
var effects_volume: float=.7
var reduced: bool=false
var subdued: bool=false
var paused: bool=false:
	set(value):
		if paused==value: return
		paused=value
		for player in players: player.stream_paused=value
		if value: stop_countdown()
		if is_instance_valid(effect): effect.stream_paused=value
		if is_instance_valid(footsteps): footsteps.stream_paused=value
		if is_instance_valid(arrival): arrival.stream_paused=value
		if is_instance_valid(ui_player): ui_player.stream_paused=false
		if fade and fade.is_valid():
			if value: fade.pause()
			else: fade.play()
var enabled: bool=true
var fade: Tween
var defeat: bool=false
var final_defeat: bool=false

func _ready() -> void:
	enabled="--smoke" not in OS.get_cmdline_user_args()
	for i in range(2):
		var player:=AudioStreamPlayer.new()
		player.volume_db=-70
		add_child(player)
		players.append(player)
		player.finished.connect(func():
			if enabled and player==players[current_player]: player.play())
	countdown_player=AudioStreamPlayer.new(); add_child(countdown_player)
	effect=AudioStreamPlayer.new(); add_child(effect)
	footsteps=AudioStreamPlayer.new(); add_child(footsteps)
	ui_player=AudioStreamPlayer.new(); add_child(ui_player)
	ui_player.stream=load("res://audio/hover.wav")
	arrival=AudioStreamPlayer.new(); add_child(arrival)

func track(index: int,instant: bool=false) -> void:
	if not enabled or index==active_track: return
	active_track=index
	if fade and fade.is_running(): fade.kill()
	var old: AudioStreamPlayer=players[current_player]
	current_player=1-current_player
	var next: AudioStreamPlayer=players[current_player]
	next.stop()
	next.stream=load("res://audio/"+["menu","gallery","nature","inventions","finale","credits"][clampi(index,0,5)]+".wav")
	next.volume_db=-60
	next.play()
	next.stream_paused=paused
	fade=create_tween().set_parallel(true)
	fade.tween_property(old,"volume_db",-60.0,.05 if instant else 1.8)
	fade.tween_property(next,"volume_db",target_volume(),.05 if instant else 1.8)

	if paused: fade.pause()

func target_volume() -> float:
	return linear_to_db(maxf(.00001,volume*(.08 if final_defeat else .25 if defeat else .38 if transitioning else .48 if subdued else .8)))

func _process(delta: float) -> void:
	if players.is_empty(): return
	if not fade or not fade.is_running(): players[current_player].volume_db=lerpf(players[current_player].volume_db,target_volume(),minf(1,delta*5))
	ui_player.volume_db=linear_to_db(maxf(.00001,effects_volume*.35))
	countdown_player.volume_db=linear_to_db(maxf(.00001,effects_volume*.72))
	effect.volume_db=linear_to_db(maxf(.00001,effects_volume))
	footsteps.volume_db=linear_to_db(maxf(.00001,effects_volume*.35))
	arrival.volume_db=linear_to_db(maxf(.00001,effects_volume*.72))

func cue(name: String) -> void:
	if not enabled or paused: return
	effect.stream=load("res://audio/"+name+".wav")
	effect.play()

func step() -> void:
	if not enabled or paused: return
	footsteps.stream=load("res://audio/step.wav")
	footsteps.pitch_scale=randf_range(.93,1.08)
	footsteps.play()

func countdown(previous: float,remaining: float) -> void:
	if not enabled or paused or remaining<=0: return
	# Crossings prevent repeats on pause/resume and after choosing another question.
	# A delayed frame plays only its most recent warning, never a burst of old ticks.
	var threshold: int=0
	for second in [10,5,4,3,2,1]:
		if previous>second and remaining<=second: threshold=second
	if threshold==0: return
	countdown_player.stream=load("res://audio/tick.wav")
	countdown_player.pitch_scale=.92 if threshold==10 else 1.05+(5-threshold)*.075
	countdown_player.volume_db=linear_to_db(maxf(.00001,effects_volume*.72))
	countdown_player.play()
	countdown_alert.emit(threshold)

func stop_countdown() -> void:
	if is_instance_valid(countdown_player): countdown_player.stop()

func stop_all() -> void:
	stop_countdown()
	enabled=false
	if fade: fade.kill()
	for p in players: p.stop(); p.stream=null
	effect.stop(); effect.stream=null
	footsteps.stop(); footsteps.stream=null
	ui_player.stop(); ui_player.stream=null
	arrival.stop(); arrival.stream=null; transitioning=false

func hover() -> void:
	if not enabled or Time.get_ticks_msec()-hover_time<80: return
	hover_time=Time.get_ticks_msec()
	ui_player.stream_paused=false
	ui_player.volume_db=linear_to_db(maxf(.00001,effects_volume*.35))
	ui_player.play()

func begin_arrival(destination: int,kind: String) -> void:
	transitioning=true
	if not enabled:return
	var cue_name: String="gallery_travel" if kind=="travel" else ["arrival_art","arrival_nature","arrival_inventions","arrival_finale"][clampi(destination,0,3)]
	arrival.stop();arrival.stream=load("res://audio/"+cue_name+".wav")
	arrival.volume_db=linear_to_db(maxf(.00001,effects_volume*.72))
	arrival.play();arrival.stream_paused=paused
func end_arrival() -> void:
	transitioning=false
	if is_instance_valid(arrival):arrival.stop()
