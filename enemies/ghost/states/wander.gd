class_name Wander extends State

@export var follow_state : State

var player: CharacterBody2D

var move_direction : Vector2
var wander_time : float

func randomise_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)

func enter():
	player = get_tree().get_first_node_in_group("Player") # HACK temporary way to get the player node
	randomise_wander()
	
	return null

func process_frame(delta: float):
	if wander_time > 0:
		wander_time	-= delta
	
	else:
		randomise_wander()
	
	return null

func process_physics(delta: float):	
	if parent:
		parent.velocity = move_direction * move_speed
	
	var direction = player.global_position - parent.global_position
	
	if direction.length() < 50: 
		return follow_state
