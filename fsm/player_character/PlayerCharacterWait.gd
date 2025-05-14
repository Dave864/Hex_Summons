extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the `Wait` state.
The Player Character waits until it is reenabled.
"""


# Hit when the player character is selected to take its turn.
func _on_Encounter_player_turn_started(player: PlayerCharacter) -> void:
	if player.name == pc.name:
		state_machine.transition_to(STANDBY)
