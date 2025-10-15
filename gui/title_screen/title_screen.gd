extends CanvasLayer

const START_LEVEL = preload("res://areas/testing_zone.tscn")

@export var button_focus_audio : AudioStream
@export var button_press_audio : AudioStream

@onready var title: Label = $Control/Title
@onready var backgrounds: Control = $Control/Backgrounds

@onready var button_container: VBoxContainer = $Control/ButtonContainer
@onready var new_game_button: Button = $Control/ButtonContainer/NewGameButton
@onready var load_game_button: Button = $Control/ButtonContainer/LoadGameButton
@onready var settings_button: Button = $Control/ButtonContainer/SettingsButton
@onready var quit_button: Button = $Control/ButtonContainer/QuitButton

var target_offset: Vector2

func _ready() -> void:
	get_tree().paused = true
	PlayerManager.active_player.visible = false
	PlayerManager.inactive_player.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	
	if SaveManager.get_save_file() == null:
		load_game_button.disabled = true
		load_game_button.visible = false
	
	#$CanvasLayer/SplashScene.finished.connect( setup_title_screen )
	setup_title_screen()
	
	LevelManager.level_load_started.connect( exit_title_screen )

func setup_title_screen() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	change_background()
	
	new_game_button.grab_focus()
	new_game_button.pressed.connect( new_game )
	load_game_button.pressed.connect( load_game )
	settings_button.pressed.connect( open_settings )
	quit_button.pressed.connect( quit_game )
	
	new_game_button.focus_entered.connect( play_hover_sfx )
	load_game_button.focus_entered.connect( play_hover_sfx )

func play_hover_sfx():
	#SodaAudioManager.play_ui_sfx( button_focus_audio.resource_path )
	pass

func new_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SodaAudioManager.play_ui_sfx( button_press_audio.resource_path )
	LevelManager.load_new_level( START_LEVEL.resource_path, "", Vector2.ZERO )
	pass

func load_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SodaAudioManager.play_ui_sfx( button_press_audio.resource_path )
	SaveManager.load_game()
	pass

func open_settings() -> void:
	SodaAudioManager.play_ui_sfx( button_press_audio.resource_path )
	pass

func quit_game() -> void:
	SodaAudioManager.play_ui_sfx( button_press_audio.resource_path )
	get_tree().quit()


func exit_title_screen() -> void:
	PlayerManager.active_player.visible = true
	PlayerManager.inactive_player.visible = true
	#PlayerHud.visible = true
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	self.queue_free()
	pass

func change_background() -> void:
	var backgrounds_array : Array 
	for c : TextureRect in backgrounds.get_children():
		c.visible = false
		backgrounds_array.append(c)
	var rando : int = randi_range(0, 3)
	backgrounds_array[rando].visible = true
	title.set_position(Vector2(backgrounds_array[rando].title_pos_x, backgrounds_array[rando].title_pos_y))
	button_container.set_position(Vector2(backgrounds_array[rando].button_container_pos_x, 
	backgrounds_array[rando].button_container_pos_y))
