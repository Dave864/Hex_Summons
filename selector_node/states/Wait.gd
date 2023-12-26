extends SelectorState
"""
The logic for what happens when the Selector is in the 'Wait' state.
The selector hides its shape until it is signaled to enter the 'Select' state.
"""


# Hide the selector shape and disable the ability to snap to tile positions
func enter(_msg: Dictionary = {}):
	selector.snap_to_position = false
	selector.selector_shape.hide()


# Enables the selector when signaled
func _on_selector_enabled():
	state_machine.transition_to("Select")
