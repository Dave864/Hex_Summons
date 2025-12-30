class_name SelectorNodeWait
extends SelectorState
## The logic for what happens when the Selector is in the 'Wait' state.
##
## The selector hides its shape and disables the snap position functionality
## until the encounter is ready to recieve new player selections.


## Connect to the player_turn_started signal from the SignalBus.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	selector.active_character = null
	SignalBus.connect(
			"player_turn_started",
			Callable(self, "_on_SignalBus_player_turn_started")
	)


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
func exit() -> void:
	SignalBus.disconnect(
			"player_turn_started",
			Callable(self, "_on_SignalBus_player_turn_started")
	)


## Set the active character to be the player whose turn has started and move
## to the `SelectMove` state.
func _on_SignalBus_player_turn_started(player: PlayerCharacter) -> void:
	selector.active_character = player
	state_machine.transition_to(SELECT_MOVE)


## Move to the `SelectMove` state. The active character should have already
## been set by the Encounter FSM.
func _on_SignalBus_summon_turn_started() -> void:
	state_machine.transition_to(SELECT_MOVE)
