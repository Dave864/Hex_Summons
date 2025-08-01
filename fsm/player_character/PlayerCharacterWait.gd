extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the `Wait` state.
The Player Character waits until it is reenabled.
"""


func enter(_msg: Dictionary = {}) -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"player_turn_started",
			self,
			"_on_SignalBus_player_turn_started"
	)
	pc.emit_is_waiting()


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	SignalBus.disconnect(
			"player_turn_started",
			self,
			"_on_SignalBus_player_turn_started"
	)


# Hit when the player character is selected to take its turn.
func _on_SignalBus_player_turn_started(player: PlayerCharacter) -> void:
	if player.get_instance_id() == pc.get_instance_id():
		state_machine.transition_to(STANDBY)
