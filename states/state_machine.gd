class_name StateMachine
extends Node
"""
Generic state machine. Initializes states and delegates engine callbacks
(_physics_process, _unhandled_input) to the active state.
"""


# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
onready var state: State = get_node(initial_state)


func _ready() -> void:
	yield(owner, "ready")
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
	state.enter()


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)


# This function connects a signal to the specified function in the current state
# and emits an error message if the connection failed.
func connect_signal(
	signal_source_node: Object,
	signal_name: String,
	target: Object,
	function_name: String
) -> void:
	var e = signal_source_node.connect(signal_name, target, function_name)
	
	if e != OK:
		if signal_source_node.name != target.name:
			ErrorMessage.signal_connect_failed(
				e,
				signal_name,
				signal_source_node.name,
				owner.name,
				target.name,
				function_name
			)
		else:
			ErrorMessage.signal_connect_self_failed(
				e,
				signal_name,
				target.name,
				function_name
			)
