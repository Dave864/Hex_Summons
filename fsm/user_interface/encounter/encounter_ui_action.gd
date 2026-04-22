class_name EncounterUIAction
extends EncounterUIState
## The logic for what happens when an EncounterUI scene is in the `Action` state.
##
## Activates the player options menu. Goes to the `Wait` state when the turn has
## been finalized.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.display_player_menu(true)
	encounter_ui.disable_player_menu(false)
	_connect_signals()


## Called by the state machine before changing the active state.
## Use this function to clean up the state.
func exit() -> void:
	_disconnect_signals()


## Connect the relevant signals to this state.
## These signals are used by other states and will be disconnected to avoid
## unintended behavior.
func _connect_signals() -> void:
	SignalBus.connect(
			"player_turn_finalized",
			Callable(self, "_on_SignalBus_player_turn_finalized")
	)
	SignalBus.connect(
			"character_action_selected",
			Callable(self, "_on_SignalBus_character_action_selected")
	)
	SignalBus.connect(
			"spawn_action_selected", 
			Callable(self, "_on_SignalBus_spawn_action_selected")
	)
	SignalBus.connect(
			"character_action_executed",
			Callable(self, "_on_SignalBus_character_action_executed")
	)


## Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	SignalBus.disconnect(
			"player_turn_finalized",
			Callable(self, "_on_SignalBus_player_turn_finalized")
	)
	SignalBus.disconnect(
			"character_action_selected",
			Callable(self, "_on_SignalBus_character_action_selected")
	)
	SignalBus.disconnect(
			"spawn_action_selected", 
			Callable(self, "_on_SignalBus_spawn_action_selected")
	)
	SignalBus.disconnect(
			"character_action_executed",
			Callable(self, "_on_SignalBus_character_action_executed")
	)


## Indicates that the current player turn has been finalized.
func _on_PlayerOptionsUI_wait_selected() -> void:
	SignalBus.emit_player_turn_finalized()


## Go to the WAIT state when the character turn has been finalized.
func _on_SignalBus_player_turn_finalized() -> void:
	state_machine.transition_to(WAIT)


## Signal that a selected action has been executed. Hide the options UI elements.
func _on_SignalBus_character_action_executed(
	_character: Character,
	_action: Action,
	_targets: Array
) -> void:
	encounter_ui.display_player_menu(false)
