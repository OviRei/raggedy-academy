extends Node

signal level_load_started
signal level_loaded


var target_transition : String
var position_offset : Vector2


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK) 
	await get_tree().process_frame
	level_loaded.emit()


func load_new_level(
		level_path : String,
		_target_transition : String,
		_position_offset : Vector2
	) -> void:
	
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	await SceneTransition.fade_out()
	
	level_load_started.emit()
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_file( level_path )
	
	SceneTransition.fade_in()
	
	get_tree().paused = false
	
	await get_tree().process_frame
	
	level_loaded.emit()
	
	pass
