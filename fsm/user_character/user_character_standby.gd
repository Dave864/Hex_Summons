class_name UserCharacterStandby
extends UserCharacterState
## The logic for what happens when a user controlled Character is in the
## 'Standby' state.
##
## The Character waits for user input and then goes to the appropriate state.


## Connect this state to the signals it needs to observe.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	character.connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.connect(
			"move_path_created",
			Callable(self, "_on_SignalBus_move_path_created")
	)
	SignalBus.connect(
			"character_action_executed",
			Callable(self, "_on_SignalBus_character_action_executed")
	)


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	character.disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
	)
	SignalBus.disconnect(
			"move_path_created",
			Callable(self, "_on_SignalBus_move_path_created")
	)
	SignalBus.disconnect(
			"character_action_executed",
			Callable(self, "_on_SignalBus_character_action_executed")
	)


## Hit when the Selector sets the movement path.
func _on_SignalBus_move_path_created(move_path: PackedVector3Array) -> void:
	state_machine.transition_to(MOVE, {"travel_path": move_path})


## Hit when the Selector confirms an action. 
func _on_SignalBus_character_action_executed(
	c: Character,
	action: Action,
	targets: Array
) -> void:
	if character.get_instance_id() == c.get_instance_id():
		state_machine.transition_to(
				ACTION,
				{"action": action, "targets": targets}
		)


## Hit when the character has finished their turn.
func _on_Character_turn_ended() -> void:
	state_machine.transition_to(WAIT)
