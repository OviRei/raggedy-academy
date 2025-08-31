class_name Ghost extends CharacterBody2D

@export var move_speed := 150.0
var facing_direction := Vector2.DOWN  # Default facing direction

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_animation := ""

@onready var state_machine: Node = $StateMachine
@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	state_machine.init(self)
	interaction_area.interact = Callable(self, "_on_interact")

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)
	
func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
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
		
func _on_interact():
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return
	if PlayerManager.current_mc == "Jane":
		Dialogic.start('ghost_talk')
	elif PlayerManager.current_mc == "John":
		Dialogic.start('ghost_talk2')
		
	await Dialogic.timeline_ended
	pass
