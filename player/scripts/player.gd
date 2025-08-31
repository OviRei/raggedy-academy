extends CharacterBody2D

@export var mc_name : String

var input_vector : Vector2 = Vector2.ZERO
var facing_direction := Vector2.DOWN  # Default facing direction

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_animation := ""

@onready var state_machine: Node = $StateMachine

func _ready() -> void:
	# Initilize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)
	
	var style: DialogicStyle = load('res://dialogic/styles/vn_style.tres')
	style.prepare()
	Dialogic.preload_timeline('res://dialogic/timelines/ghost_talk.dtl')
	Dialogic.preload_timeline('res://dialogic/timelines/ghost_talk2.dtl')

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
	input_vector = Vector2(
	 	Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input_vector != Vector2.ZERO:
		facing_direction = input_vector  # Update last direction when moving

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
