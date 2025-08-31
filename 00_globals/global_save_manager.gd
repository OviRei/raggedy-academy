extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved


var current_save : Dictionary = {
	scene_path = "",
	player = {
		current_mc = "Jane",
		level = 1,
		xp = 0,
		hp = 1,
		max_hp = 1,
		attack = 1,
		defense = 1,
		pos_x = 0,
		pos_y = 0
	},
	items = [],
	persistence = [],
	quests = [
		#{ title = "not found", is_complete = false, completed_steps = [''] }
	],
	abilities = [ "", "", "", "" ]
}

func save_game():
	update_player_data()
	update_scene_path()
	
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE )
	var save_json = JSON.stringify( current_save )
	file.store_line( save_json )
	game_saved.emit()
	
	
func load_game():
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ )
	var json := JSON.new()
	json.parse( file.get_line() )
	var save_dict : Dictionary = json.get_data() as Dictionary
	current_save = save_dict
	
	LevelManager.load_new_level( current_save.scene_path, "", Vector2.ZERO)
	
	await LevelManager.level_load_started
	
	PlayerManager.set_player_position( Vector2(current_save.player.pos_x, current_save.player.pos_y) )
	
	await LevelManager.level_loaded
	
func update_player_data() -> void:
	var p = PlayerManager.active_player
	
	current_save.player.current_mc = PlayerManager.current_mc
	current_save.player.pos_x = p.global_position.x 
	current_save.player.pos_y = p.global_position.y
	
func update_scene_path() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
			
	current_save.scene_path = p
	
	
	
