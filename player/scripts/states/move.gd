extends State

@export var idle_state: State
@export var follow_state: State

var should_follow := false

func enter() -> void:
	should_follow = false

func process_physics(delta: float) -> State:
	parent.update_animation("walk", true)
	
	if PlayerManager.current_mc != parent.mc_name:
		return follow_state
	
	if parent.input_vector == Vector2.ZERO:
		return idle_state
	
	parent.velocity = parent.input_vector * move_speed
	parent.move_and_slide()
	return null
	
