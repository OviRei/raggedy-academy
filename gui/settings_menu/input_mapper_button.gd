# TODO ALL OF THIS NONE OF IT WORKS!!!!!
extends Button

@export var action_name: String = ""

var binding_mode: bool = false

func _ready() -> void:
	text = _get_action_text()
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed() -> void:
	if binding_mode:
		return

	if action_name == "" or action_name.is_empty():
		action_name = "rebind_action_%s" % str(get_instance_id())

	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	binding_mode = true
	text = "Press a key..."
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	if not binding_mode:
		return

	if event is InputEventKey:
		if not event.pressed or event.echo:
			return
		_handle_bind(event)
		return

	if event is InputEventMouseButton:
		if not event.pressed:
			return
		_handle_bind(event)
		return

	if event is InputEventJoypadButton:
		if not event.pressed:
			return
		_handle_bind(event)
		return

func _handle_bind(event: InputEvent) -> void:
	var ev := event.duplicate()
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, ev)

	get_viewport().set_input_as_handled()

	binding_mode = false
	set_process_input(false)
	text = _get_action_text()

func _get_action_text() -> String:
	if action_name == "" or action_name.is_empty():
		return "No action set"
	var evs = InputMap.action_get_events(action_name)
	if evs.size() > 0:
		return evs[0].as_text()
	return "Unassigned"
