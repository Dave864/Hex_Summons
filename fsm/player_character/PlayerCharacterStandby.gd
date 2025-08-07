extends PlayerCharacterState
"""
The logic for what happens when a Player Character is in the 'Standby' state.
The Player Character waits for player input and then goes to the appropriate
state.
"""


# Connect this state to the signals it needs to observe.
func enter(_msg: Dictionary = {}) -> void:
	ErrorUtil.connect_signal(
		pc,
		"turn_ended",
		self,
		"_on_PlayerCharacter_turn_ended"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"move_path_created",
			self,
			"_on_SignalBus_move_path_created"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_action_executed",
			self,
			"_on_SignalBus_player_action_executed"
	)


# Called by the state machine before changing the active state. Use this 
# function to clean up the state.
func exit() -> void:
	pc.disconnect(
			"turn_ended",
			self,
			"_on_PlayerCharacter_turn_ended"
	)
	SignalBus.disconnect(
			"move_path_created",
			self,
			"_on_SignalBus_move_path_created"
	)
	SignalBus.disconnect(
			"player_action_executed",
			self,
			"_on_SignalBus_player_action_executed"
	)


# Hit when the Selector sets the movement path.
func _on_SignalBus_move_path_created(move_path: PoolVector3Array) -> void:
	state_machine.transition_to(MOVE, {"travel_path": move_path})


# Hit when the Selector confirms an action. 
func _on_SignalBus_player_action_executed(
	player: PlayerCharacter,
	action: Action,
	targets: Array
) -> void:
	if pc.get_instance_id() == player.get_instance_id():
		state_machine.transition_to(
				ACTION,
				{"action": action, "targets": targets}
		)


# Hit when the player has finished their turn.
func _on_PlayerCharacter_turn_ended() -> void:
	state_machine.transition_to(WAIT)
