extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var item_description: Label = $Control/ItemDescription


var is_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pause_menu()
	save_button.pressed.connect( _on_save_pressed )
	load_button.pressed.connect( _on_load_pressed )
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu():
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()
	
func hide_pause_menu():
	get_tree().paused = false
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

func update_item_description( new_text : String ) -> void:
	item_description.text = new_text
	
func play_audio( audio : AudioStream ) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
