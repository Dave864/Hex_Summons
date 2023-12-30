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
	StateMachineBus.encounter_states["Encounter"] = "PlayerTurn"
	# Start the player turn.
	enc._rf.refresh_astar_connections("Player")
	SignalBus.emit_signal("player_turn_started")


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Determine which turn to go to when the current player ends their turn.
	if StateMachineBus.encounter_states["PlayerCharacter"] == "Wait":
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
