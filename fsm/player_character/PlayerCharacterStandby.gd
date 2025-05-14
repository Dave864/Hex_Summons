extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Standby' state.
The Player Character waits for player input and then goes to the appropriate
state.
"""


# Hit when the Selector selects a map tile destination.
func _on_Encounter_move_tile_selected(info: Array) -> void:
	state_machine.transition_to(MOVE, {"travel_path": info})


# Hit when the EncounterUI indicates that a player has finished their turn.
func _on_EncounterUI_player_turn_ended(player: PlayerCharacter) -> void:
	if pc.name == player.name:
		state_machine.transition_to(WAIT)
