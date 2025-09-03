extends Node

# --- Inspector / exported settings ---
@export var music_audio_player_count: int = 2 
@export var music_bus: String = "Music"     
@export var music_fade_duration: float = 1.0 
@export var music_start_volume_db: float = -40.0  

@export var sfx_pool_size: int = 16         
@export var sfx_bus: String = "SFX"
@export var sfx_start_volume_db: float = -80.0

# --- Internal state  ---
var music_players: Array[AudioStreamPlayer] = []  
var music_target_db: Array[float] = []       
var current_music_player: int = 0 
var music_master_db: float = 0.0          
var music_muted: bool = false                   

var sfx_players: Array[AudioStreamPlayer2D] = []  
var sfx_pool_index: int = 0                       
var sfx_master_db: float = 0.0                   
var sfx_muted: bool = false                        

# bank of named sfx: name -> {stream: AudioStream, category: String}
var sfx_bank: Dictionary = {}

# categories let you group sfx and control their volumes/mute separately
var sfx_categories: Dictionary = {
	"default": {"volume_db": 0.0, "muted": false},
	"ui": {"volume_db": 0.0, "muted": false},
	"combat": {"volume_db": 0.0, "muted": false},
	"env": {"volume_db": 0.0, "muted": false}
}

signal sfx_played(name: String)  # emitted whenever a registered sfx is played

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# create the music players (non-positional). They live as children of this node.
	for i in range(music_audio_player_count):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		p.bus = music_bus
		p.volume_db = music_start_volume_db
		music_players.append(p)
		music_target_db.append(music_start_volume_db)

	# create the sfx player pool (AudioStreamPlayer2D for positional 2D audio).
	for i in range(sfx_pool_size):
		var sp: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(sp)
		sp.bus = sfx_bus
		sp.volume_db = sfx_start_volume_db
		sp.pitch_scale = 1.0
		sfx_players.append(sp)

	# load saved audio settings when available
	load_settings()

# --------------------
# Music functions
# --------------------

func play_music(audio: AudioStream, fade_duration: float = -1.0, loop: bool = false) -> void:
	# Start playing 'audio' with a crossfade to the next music player.
	# If the same AudioStream is already active, do nothing.
	if audio == null:
		return
	var cur_player = music_players[current_music_player]
	if cur_player.stream == audio:
		return

	current_music_player = (current_music_player + 1) % music_players.size()
	var new_player: AudioStreamPlayer = music_players[current_music_player]

	new_player.stream = audio
	new_player.play(0.0)

	if loop:
		var bound_callable := Callable(self, "_on_music_finished").bind(new_player)

		if not new_player.is_connected("finished", bound_callable):
			new_player.connect("finished", bound_callable)

	var duration = fade_duration if fade_duration > 0.0 else music_fade_duration

	# fade in the new player and fade out any other currently playing player(s)
	play_and_fade_in(new_player, duration)
	for p in music_players:
		if p != new_player and p.playing:
			fade_out_and_stop(p, duration)

func _on_music_finished(player: AudioStreamPlayer) -> void:
	if player.stream != null:
		player.play()

func play_and_fade_in(player: AudioStreamPlayer, duration: float) -> void:
	# Fade this player's volume_db up to the effective target (0 dB + master offset).
	# If music is muted, we use -80 dB to silence.
	var target_db = 0.0 + music_master_db
	if music_muted:
		target_db = -80.0
	# remember target for this index (useful if master volume changes later)
	music_target_db[music_players.find(player)] = target_db

	# if the player is currently very silent set a sensible start volume
	var tween := create_tween()
	if player.volume_db < -79.0:
		player.volume_db = music_start_volume_db
	tween.tween_property(player, "volume_db", target_db, duration)

func fade_out_and_stop(player: AudioStreamPlayer, duration: float) -> void:
	# Fade the player down to a very low volume then stop it.
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	await tween.finished
	if player.playing:
		player.stop()

func pause_music() -> void:
	# Pause all music players (useful for game pause menus).
	for p in music_players:
		if p.playing:
			p.stream_paused = true

func resume_music() -> void:
	# Resume paused music players.
	for p in music_players:
		if p.stream_paused:
			p.stream_paused = false

func stop_music(fade_duration: float = -1.0) -> void:
	# Stop all music with optional fade.
	var dur = fade_duration if fade_duration > 0.0 else music_fade_duration
	for p in music_players:
		if p.playing:
			fade_out_and_stop(p, dur)

func set_music_master_volume_db(db: float) -> void:
	music_master_db = db
	for i in range(music_players.size()):
		var p = music_players[i]
		var target = 0.0 + music_master_db
		if music_muted:
			target = -80.0
		music_target_db[i] = target
		var tween := create_tween()
		tween.tween_property(p, "volume_db", target, 0.25) 

func mute_music(mute: bool) -> void:
	# Mute or unmute music. Muting fades to -80 dB.
	music_muted = mute
	if mute:
		for p in music_players:
			var tween := create_tween()
			tween.tween_property(p, "volume_db", -80.0, 0.25)
	else:
		# restore to previously set master volume
		set_music_master_volume_db(music_master_db)

# --------------------
# SFX functions
# --------------------

func register_sfx(name: String, stream: AudioStream, category: String = "default") -> void:
	# Store a named AudioStream in the bank for simple calls later.
	# Example: register_sfx("jump", preload("res://sfx/jump.wav"), "player")
	if stream == null:
		return
	sfx_bank[name] = {"stream": stream, "category": category}

func register_sfx_bulk(dict: Dictionary, category: String = "default") -> void:
	# Bulk register from a dictionary where keys are names and values are AudioStream.
	for name in dict.keys():
		register_sfx(name, dict[name], category)

# 'position' is nullable. Pass a Vector2 to play at a position, or leave null to use origin.
func play_sfx(name: String, volume_db: float = 0.0, pitch_variance: float = 0.0, position = null, category: String = "", looping: bool = false) -> void:
	# Play a named SFX from the pool with optional per-play adjustments.
	if not sfx_bank.has(name):
		return
	var info = sfx_bank[name]
	var stream: AudioStream = info["stream"]
	
	var cat: String = category if category != "" else info.get("category", "default")
	var cat_info = sfx_categories.get(cat, {"volume_db": 0.0, "muted": false})
	
	if cat_info["muted"]:
		return

	var player: AudioStreamPlayer2D = _get_next_sfx_player()
	player.stream = stream

	if position != null:
		player.position = position
	else:
		player.position = Vector2.ZERO

	# compute effective volume: master + category + per-play offset
	var effective_db = sfx_master_db + float(cat_info["volume_db"]) + volume_db
	if sfx_muted:
		effective_db = -80.0
	player.volume_db = effective_db

	if pitch_variance != 0.0:
		var randv = (randf() * 2.0 - 1.0) * pitch_variance
		player.pitch_scale = 1.0 + randv
	else:
		player.pitch_scale = 1.0

	# optional looping: attach a bound callback to restart this specific player when it finishes
	if looping:
		var bound_c := Callable(self, "_on_sfx_finished_loop").bind(player)
		if not player.is_connected("finished", bound_c):
			player.connect("finished", bound_c)
			
	player.play(0.0)
	emit_signal("sfx_played", name)

func _on_sfx_finished_loop(player: AudioStreamPlayer2D) -> void:
	# Simple loop handler for pooled players when looping=true was used
	if player.stream != null:
		player.play()

func play_one_shot(stream: AudioStream, volume_db: float = 0.0, pitch_variance: float = 0.0, position = null) -> void:
	# Play an AudioStream directly without registering a name first.
	if stream == null:
		return
	var player: AudioStreamPlayer2D = _get_next_sfx_player()
	player.stream = stream
	if position != null:
		player.position = position
	else:
		player.position = Vector2.ZERO
	player.volume_db = sfx_master_db + volume_db if not sfx_muted else -80.0
	if pitch_variance != 0.0:
		player.pitch_scale = 1.0 + ((randf() * 2.0 - 1.0) * pitch_variance)
	else:
		player.pitch_scale = 1.0
	player.play(0.0)

func _get_next_sfx_player() -> AudioStreamPlayer2D:
	# If the chosen player is already playing it will be reused.
	var idx = sfx_pool_index % sfx_players.size()
	sfx_pool_index = (sfx_pool_index + 1) % sfx_players.size()
	return sfx_players[idx]

func set_sfx_master_volume_db(db: float) -> void:
	# Set master sfx volume and apply to currently playing pooled players instantly.
	sfx_master_db = db
	for p in sfx_players:
		if p.playing:
			p.volume_db = db

func mute_sfx(mute: bool) -> void:
	# Toggle sfx mute. New plays will respect this flag.
	sfx_muted = mute

func set_sfx_category_volume(category: String, db: float) -> void:
	# Create or update a category volume (in dB).
	if not sfx_categories.has(category):
		sfx_categories[category] = {"volume_db": db, "muted": false}
	else:
		sfx_categories[category]["volume_db"] = db

func mute_sfx_category(category: String, mute: bool) -> void:
	# Mute or unmute a specific category of sfx.
	if not sfx_categories.has(category):
		sfx_categories[category] = {"volume_db": 0.0, "muted": mute}
	else:
		sfx_categories[category]["muted"] = mute

func stop_sfx_by_name(name: String) -> void:
	# Stop all pooled players currently playing the stream registered under 'name'.
	if not sfx_bank.has(name):
		return
	var stream = sfx_bank[name]["stream"]
	for p in sfx_players:
		if p.stream == stream and p.playing:
			p.stop()

# --------------------
# Save / Load settings
# --------------------

const SETTINGS_FILE := "user://audio_settings.cfg" 

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("music", "master_db", music_master_db)
	cfg.set_value("music", "muted", music_muted)
	cfg.set_value("sfx", "master_db", sfx_master_db)
	cfg.set_value("sfx", "muted", sfx_muted)
	cfg.set_value("sfx", "categories", sfx_categories)
	cfg.save(SETTINGS_FILE)

func load_settings() -> void:
	# Load saved settings if the file exists. Missing values keep current defaults.
	var cfg := ConfigFile.new()
	var err = cfg.load(SETTINGS_FILE)
	if err != OK:
		return
	music_master_db = float(cfg.get_value("music", "master_db", music_master_db))
	music_muted = bool(cfg.get_value("music", "muted", music_muted))
	sfx_master_db = float(cfg.get_value("sfx", "master_db", sfx_master_db))
	sfx_muted = bool(cfg.get_value("sfx", "muted", sfx_muted))
	var cats = cfg.get_value("sfx", "categories", null)
	if typeof(cats) == TYPE_DICTIONARY:
		sfx_categories = cats
	# apply loaded values immediately
	set_music_master_volume_db(music_master_db)
	if music_muted:
		mute_music(true)
	set_sfx_master_volume_db(sfx_master_db)

func _notification(what):
	# Called on window close. Save settings when the app requests window close.
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
