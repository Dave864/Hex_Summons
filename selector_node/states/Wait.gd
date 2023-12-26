extends SelectorState
"""
The logic for what happens when the Selector is in the 'Wait' state.
The selector hides its shape and disables the snap position functionality
until the shape is revealed by an external trigger caught in the selector.
Moves to the 'Select' state when the shape is revealed.
"""


# Hide the selector shape and disable the ability to snap to tile positions
func enter(_msg: Dictionary = {}):
	#selector.snap_to_position = false
	#selector.selector_shape.hide()
	pass


func update(_delta: float):
	state_machine.transition_to("Select")
