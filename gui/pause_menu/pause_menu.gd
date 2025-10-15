extends CanvasLayer

signal shown
signal hidden

@onready var settings_menu: Control = $SettingsMenu

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

@onready var item_description: Label = $Control/ItemDescription


var is_paused : bool = false
var is_settings_open : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pause_menu()
	save_button.pressed.connect( _on_save_pressed )
	load_button.pressed.connect( _on_load_pressed )
	settings_button.pressed.connect( _on_settings_pressed )
	main_menu_button.pressed.connect( _on_main_menu_pressed )
	quit_button.pressed.connect( _on_quit_pressed )

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SodaAudioManager.pause_music()
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()
	
func hide_pause_menu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SodaAudioManager.resume_music()
	visible = false
	is_paused = false
	hidden.emit()

func _on_save_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.save_game()
	hide_pause_menu()
	pass

func _on_load_pressed():
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_loaded
	hide_pause_menu()
	pass

func _on_settings_pressed():
	settings_menu.visible = true
	is_settings_open = true

func _on_main_menu_pressed():
	if is_paused == false:
		return
	LevelManager.load_new_level( "res://gui/title_screen/title_screen.tscn", "",  Vector2.ZERO)
	await LevelManager.level_loaded
	hide_pause_menu()
	
func _on_quit_pressed():
	if is_paused == false:
		return
	get_tree().quit()

func update_item_description( new_text : String ) -> void:
	item_description.text = new_text
	
func play_audio( audio : AudioStream ) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
