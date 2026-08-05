class_name PlayerCharacterWait
extends UserCharacterWait
## The logic for what happens when a Player Character is in the `Wait` state.
##
## The Player Character waits and is inactive until it is reenabled.


func enter(msg: Dictionary[Variant, Variant] = {}) -> void:
	SignalBus.player_turn_started.connect(_on_SignalBus_player_turn_started)
	super.enter(msg)


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	SignalBus.player_turn_started.disconnect(_on_SignalBus_player_turn_started)


## Hit when the player character is selected to take its turn.
func _on_SignalBus_player_turn_started(player: PlayerCharacter) -> void:
	if player.get_instance_id() == character.get_instance_id():
		state_machine.transition_to(STANDBY)
