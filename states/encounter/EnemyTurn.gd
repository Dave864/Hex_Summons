extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `EnemyTurn` state.
Handles the encounter logic needed to allow the enemy character to properly
run during their turn. Remains in the `EnemyTurn` state if the next character
in initiative is also an enemy character. Goes to the `PlayerTurn` state if an
player character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


"""
TODO: Remove this when you create the AI logic for the EnemyCharacter
"""
var current_character: EnemyCharacter


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	StateMachineBus.encounter_states["Encounter"] = "EnemyTurn"
	current_character = enc._initiative_tracker[enc._cur_init]
	
	# Start the enemy turn.
	enc._rf.refresh_astar_connections("Enemy")
	"""
	TODO: Need to eventually add AI logic/state machine to EnemyCharacter.
	"""
	SignalBus.emit_signal(
		"enemy_turn_started",
		enc._rf.get_point_path(
			current_character.get_index_at(),
			enc._p.get_index_at()
		)
	)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Determine which turn to go to when the current player ends their turn.
	if StateMachineBus.encounter_states["EnemyCharacter"] == "Wait":
		var next_character: Character = enc.get_next_character()
		if next_character is PlayerCharacter:
			state_machine.transition_to("PlayerTurn")
		elif next_character is EnemyCharacter:
			state_machine.transition_to("EnemyTurn")
	
	# Move to the `End` State
	if enc.enemies.size() == 0:
		state_machine.transition_to("End")


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	enc.progress_initiative()
