extends SelectorState
"""
The logic for what happens when the Selector is in the 'Wait' state.
The selector hides its shape and disables the snap position functionality
until the encounter is ready to recieve new player selections.
"""


# Hide the selector shape and disable the ability to snap to tile positions
func enter(_msg: Dictionary = {}) -> void:
	pass


# Called by the state machine before changing the active state. 
# Use this function to clean up the state.
func exit() -> void:
	pass


# Set the position of the selector to the player whose turn has started and move
# to the `SelectMove` state.
func _on_Encounter_player_turn_started(player: PlayerCharacter) -> void:
	state_machine.transition_to(SELECT_MOVE, {"initial_position": player.translation})
