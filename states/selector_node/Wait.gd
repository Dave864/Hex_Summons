extends SelectorState
"""
The logic for what happens when the Selector is in the 'Wait' state.
The selector hides its shape and disables the snap position functionality
until the encounter is ready to recieve new player selections.
"""


# Hide the selector shape and disable the ability to snap to tile positions
func enter(_msg: Dictionary = {}):
	_set_state_machine_bus(WAIT)
	selector.snap_to_position = false
	selector.selector_shape.hide()


# Corresponds to the `_process()` callback.
func update(_delta: float):
	# When the player character has entered the 'Standby' state, reenable the
	# Selector.
	if StateMachineBus.encounter_states[FSM.Encounter.PLAYER_CHARACTER] == PlayerCharacterState.STANDBY:
		state_machine.transition_to(SELECT)
