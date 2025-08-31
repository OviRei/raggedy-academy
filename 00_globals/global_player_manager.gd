extends Node

const PLAYER_JANE = preload("res://player/jane/player_jane.tscn")
const PLAYER_JOHN = preload("res://player/john/player_john.tscn")

var active_player : CharacterBody2D
var	inactive_player : CharacterBody2D
var player_spawned = false

var current_mc : String = "Jane"
signal switched_mc
var can_switch := true
var switch_cooldown := 0.5  # seconds

func _ready() -> void:
	add_player_instance()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mc") and not event.is_echo() and can_switch:
		switch_mc()
		can_switch = false
		await get_tree().create_timer(switch_cooldown).timeout
		can_switch = true

func switch_mc():
	current_mc = "John" if current_mc == "Jane" else "Jane"
	 
	var temp = active_player
	active_player = inactive_player
	inactive_player = temp

	switched_mc.emit()

func add_player_instance() -> void:
	if current_mc == "Jane":
		active_player = PLAYER_JANE.instantiate()
		inactive_player = PLAYER_JOHN.instantiate()
	elif current_mc == "John":
		active_player = PLAYER_JOHN.instantiate()
		inactive_player = PLAYER_JANE.instantiate()
		
	get_tree().get_current_scene().add_child(active_player)
	get_tree().get_current_scene().add_child(inactive_player)

# This is for setting the player node as a child of the root of the level nodes
func set_as_parent( _p : Node2D ) -> void:
	if active_player.get_parent():
		active_player.get_parent().remove_child( active_player )
	_p.add_child( active_player )

	if inactive_player.get_parent():
		inactive_player.get_parent().remove_child( inactive_player )
	_p.add_child( inactive_player )

func unparent_player( _p : Node2D ) -> void:
	_p.remove_child( active_player )
	_p.remove_child( inactive_player )

func set_player_position( new_pos : Vector2 ) -> void:
	active_player.global_position = new_pos
	inactive_player.global_position = new_pos 
