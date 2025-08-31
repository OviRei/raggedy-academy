extends State

@export var move_state: State
@export var follow_state: State

var should_follow := false

func enter():
	parent.update_animation("idle", true)
	parent.velocity = Vector2()

func process_physics(delta: float) -> State:
	if PlayerManager.current_mc != parent.mc_name:
		return follow_state
		
	if parent.input_vector != Vector2.ZERO:
		return move_state
		
	parent.move_and_slide()
	return null
