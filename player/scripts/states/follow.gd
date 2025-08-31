class_name Follow extends State

@export var idle_state : State

func process_physics(delta: float):	
	#print(parent.mc_name + " is in following state")
	var direction = PlayerManager.active_player.global_position - parent.global_position
	
	if direction.length() > 30:
		parent.velocity = direction.normalized() * move_speed
		parent.update_animation("walk", true)
	else:
		parent.velocity = Vector2()
		parent.update_animation("idle", true)
	
	if PlayerManager.current_mc == parent.mc_name:
		return idle_state
		
	parent.move_and_slide()
	return null
