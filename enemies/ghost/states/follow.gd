class_name GhostFollow extends State

@export var wander_state : State

func process_physics(delta: float):	
	var direction = PlayerManager.active_player.global_position - parent.global_position
	
	if direction.length() > 25:
		parent.velocity = direction.normalized() * move_speed
	else:
		parent.velocity = Vector2()
	
	if direction.length() > 50:
		return wander_state
		
	return null
	
