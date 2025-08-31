class_name CameraManager extends Node

@export var jane_pcam : PhantomCamera2D
@export var john_pcam : PhantomCamera2D

var player_jane : CharacterBody2D
var player_john : CharacterBody2D
var camera_bounds 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	player_jane = get_tree().get_first_node_in_group("JaneGroup") # HACK temp way of getting player
	player_john = get_tree().get_first_node_in_group("JohnGroup") # HACK temp way of getting player
	camera_bounds = await get_tree().get_first_node_in_group("CameraBounds").get_path()
	jane_pcam.set_limit_target(camera_bounds)
	print(camera_bounds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# HACK ALL OF THIS
	
	if !jane_pcam.follow_target:
		jane_pcam.follow_target = player_jane
	if !john_pcam.follow_target:
		john_pcam.follow_target = player_john
	
	if PlayerManager.current_mc == "John":
		jane_pcam.priority = 0
		john_pcam.priority = 1
	
	if PlayerManager.current_mc == "Jane":
		jane_pcam.priority = 1
		john_pcam.priority = 0
	pass
