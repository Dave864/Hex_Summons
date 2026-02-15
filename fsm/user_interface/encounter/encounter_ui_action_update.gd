class_name EncounterUIActionUpdate
extends EncounterUIState
## The logic for what happens when an EncounterUI scene is in the `Action` state.
##
## Activates the player options menu. When a movement path has been created


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
	encounter_ui.get_focused_character().connect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
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
	SignalBus.connect(
			"move_path_created",
			Callable(self, "_on_SignalBus_move_path_created")
	)


## Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	encounter_ui.get_focused_character().disconnect(
			"turn_ended",
			Callable(self, "_on_Character_turn_ended")
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
	SignalBus.disconnect(
			"move_path_created",
			Callable(self, "_on_SignalBus_move_path_created")
	)


## Indicates that the current player turn has ended.
func _on_PlayerOptionsUI_wait_selected() -> void:
	encounter_ui.get_focused_character().emit_turn_ended()


## Go to the WAIT state when the character turn has ended.
func _on_Character_turn_ended() -> void:
	state_machine.transition_to(WAIT)


## Signal that a selected action has been executed. Hide the options UI elements.
func _on_SignalBus_character_action_executed(
	_character: Character,
	_action: Action,
	_targets: Array
) -> void:
	encounter_ui.display_player_menu(false)


## Triggered when a move tile has been selected and a path created to said tile.
func _on_SignalBus_move_path_created(_path: PackedVector3Array) -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(PAUSE)
