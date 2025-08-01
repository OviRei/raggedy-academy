extends State

@export var move_state: State

func enter() -> void:
	parent.update_animation("idle", true)
	parent.velocity = Vector2()

func process_physics(delta: float) -> State:
	if parent.input_vector != Vector2.ZERO:
		return move_state
	parent.move_and_slide()
	return null
