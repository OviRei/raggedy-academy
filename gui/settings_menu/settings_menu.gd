extends Control

@onready var close_button: Button = %CloseButton

# Audio Variables
var music_volume : float = 0
var ui_volume : float = 0
var sfx_volume : float = 0

func _ready() -> void:
	close_button.pressed.connect( _on_close_pressed )

func _on_close_pressed():
	visible = false
	PauseMenu.is_settings_open = false

# Audio Settings
func _on_music_slider_value_changed(value: float) -> void:
	music_volume = linear_to_db(value)
	SodaAudioManager.update_volume(music_volume, ui_volume, sfx_volume)

func _on_ui_slider_value_changed(value: float) -> void:
	ui_volume = linear_to_db(value)
	SodaAudioManager.update_volume(music_volume, ui_volume, sfx_volume)

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_volume = linear_to_db(value)
	SodaAudioManager.update_volume(music_volume, ui_volume, sfx_volume)
	

# Window Settings
func _on_window_options_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		 
