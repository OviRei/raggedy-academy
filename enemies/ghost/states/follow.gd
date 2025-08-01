class_name Follow extends State

@export var wander_state : State

var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player") # HACK temporary way to get the player node
	return null

func process_physics(delta: float):	
	var direction = player.global_position - parent.global_position
	
	if direction.length() > 25:
		parent.velocity = direction.normalized() * move_speed
	else:
		parent.velocity = Vector2()
	
	if direction.length() > 50:
		return wander_state
		
	return null
	
