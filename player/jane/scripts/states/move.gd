extends State

@export var idle_state: State

func process_physics(delta: float) -> State:
	parent.update_animation("walk", true)
	
	if parent.input_vector == Vector2.ZERO:
		return idle_state
	
	parent.velocity = parent.input_vector * move_speed
	parent.move_and_slide()
	return null
