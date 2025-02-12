extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the 'Wait' state.
The Enemy Character does nothing until it is called upon to act.
"""


# Hit when the enemy character is selected to take its turn.
func _on_SignalBus_enemy_turn_started(path: PoolVector3Array) -> void:
	state_machine.transition_to(MOVE, {"travel_path": path})


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(WAIT)
	var e: int = SignalBus.connect(
		"enemy_turn_started", 
		self, 
		"_on_SignalBus_enemy_turn_started"
	)
	
	# Emit error message when issue is encountered when connecting the 
	# enemy_turn_started SignalBus signal to the
	# _on_SignalBus_player_turn_started method.
	if e != OK:
		printerr(Constants.ERROR_SIGNAL_CONNECT_FAILED % [
			e,
			"enemy_turn_started",
			"SignalBus autoload",
			"EnemyCharacter",
			"Wait",
			"_on_SignalBus_enemy_turn_started"
		])


# Called by the state machine before changing the active state.
func exit() -> void:
	SignalBus.disconnect(
		"enemy_turn_started",
		self,
		"_on_SignalBus_enemy_turn_started"
	)
