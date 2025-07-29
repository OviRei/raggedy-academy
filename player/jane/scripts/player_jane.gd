extends CharacterBody2D

@export var move_speed := 150.0
var facing_direction := Vector2.DOWN  # Default facing direction

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_animation := ""

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input_vector != Vector2.ZERO:
		facing_direction = input_vector  # Update last direction when moving
		update_animation("walk", true)
	else:
		update_animation("idle", true)  # Play idle animation when no input

	velocity = input_vector * move_speed
	move_and_slide()

func get_facing_direction() -> String:
	if abs(facing_direction.x) > abs(facing_direction.y):
		return "right" if facing_direction.x > 0 else "left"
	else:
		return "down" if facing_direction.y > 0 else "up"

func update_animation(animation_name: String, directional: bool):
	var anim_to_play = animation_name
	if directional:
		anim_to_play += "_" + get_facing_direction()

	# Only play if animation changes to avoid restarting it every frame
	if anim_to_play != current_animation:
		animation_player.play(anim_to_play)
		current_animation = anim_to_play
