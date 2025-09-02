class_name CameraManager extends Node

@onready var camera: Camera2D = $Camera2D
@export var jane_pcam : PhantomCamera2D
@export var john_pcam : PhantomCamera2D

var player_jane : CharacterBody2D
var player_john : CharacterBody2D
var camera_bounds 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.level_loaded.connect( _set_follow_target )
	PlayerManager.switched_mc.connect( _switch_mc_cam )
	#camera_bounds = await get_tree().get_first_node_in_group("CameraBounds").get_path()
	#jane_pcam.set_limit_target(camera_bounds)

func _switch_mc_cam():
	# HACK ALL OF THIS
	if PlayerManager.current_mc == "John":
		jane_pcam.priority = 0
		john_pcam.priority = 1
	
	if PlayerManager.current_mc == "Jane":
		jane_pcam.priority = 1
		john_pcam.priority = 0
	
func _set_follow_target():
	var player_jane = get_tree().get_first_node_in_group("JaneGroup")
	var player_john = get_tree().get_first_node_in_group("JohnGroup")
	
	if player_jane and !jane_pcam.follow_target:
		jane_pcam.follow_target = player_jane
		
	if player_john and !john_pcam.follow_target:
		john_pcam.follow_target = player_john
	
	_switch_mc_cam()
