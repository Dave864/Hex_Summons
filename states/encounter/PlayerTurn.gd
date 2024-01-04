extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `PlayerTurn` state.
Handles the encounter logic needed to allow the player character to properly
run during their turn. Remains in the `PlayerTurn` state if the next character
in initiative is also a player character. Goes to the `EnemyTurn` state if an
enemy character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(PLAYER_TURN)
	# Start the player turn.
	#enc._rf.refresh_astar_connections(Constants.MapOccupants.PLAYER)
	enc._rf.set_char_type(Constants.MapOccupants.PLAYER)
	enc._rf.astar_for_range(enc._initiative_tracker[enc._cur_init])
	SignalBus.emit_signal("player_turn_started", enc.get_current_character())


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Determine which turn to go to when the current player ends their turn.
	if StateMachineBus.encounter_states[FSM.Encounter.PLAYER_CHARACTER] == PlayerCharacterState.WAIT:
		var next_character: Character = enc.get_next_character()
		if next_character is PlayerCharacter:
			state_machine.transition_to(PLAYER_TURN)
		elif next_character is EnemyCharacter:
			state_machine.transition_to(ENEMY_TURN)
	
	# Move to the `End` State
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	enc.progress_initiative()
	enc._rf.clear_movement_highlight()
