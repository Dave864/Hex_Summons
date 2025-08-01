extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Action` state.
Populates the SubOptions node with buttons descrbing available choices. Selecting
the button for the currently active action will clear the SubOptions node and
allow for movement. Selecting a different button will transition to the `Action`
state using the features of the new option.
"""


var _option_flag: int
var _current_action: Action


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_option_flag = _msg["option_flag"]
	encounter_ui.set_current_selection(_option_flag)
	encounter_ui.grab_focus_for_sub_option_at_index(0)
	_current_action = encounter_ui.get_sub_option_at_index(0)
	SignalBus.emit_player_action_selected(
			encounter_ui.get_focused_player(),
			_current_action
	)
	_connect_signals()


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if (
		InputController.get_source() == InputController.Source.KEYBOARD_AND_MOUSE
		and _event.is_action_pressed("ui_selector_select")
	):
		SignalBus.emit_player_action_selected(
				encounter_ui.get_focused_player(),
				_current_action
		)
	if _event.is_action_pressed("ui_encounter_player_end"):
		SignalBus.emit_player_turn_ended(encounter_ui.get_focused_player())
		state_machine.transition_to(WAIT)
	if _event.is_action_pressed("ui_encounter_option_1"):
		_option_selected(EncounterUI.Options.TECHNIQUE)
	if _event.is_action_pressed("ui_encounter_option_2"):
		print("Spell option selected")
#		_option_selected(EncounterUI.Options.SPELL)
	if _event.is_action_pressed("ui_encounter_option_3"):
		"""
		TODO: Eventually add button for items.
		"""
		pass
	if _event.is_action_pressed("ui_encounter_option_4"):
		"""
		TODO: Eventually add functionality for summons.
		"""
		pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	encounter_ui.sub_options.clear_sub_options()
	_disconnect_signals()


# Connect the relevant signals to this state.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals() -> void:
	encounter_ui.technique_button.connect_button_signal(
			self,
			"pressed",
			"_on_TechniqueButton_button_pressed"
	)
	encounter_ui.spell_button.connect_button_signal(
			self,
			"pressed",
			"_on_SpellButton_button_pressed"
	)
	encounter_ui.end_button.connect_button_signal(
			self,
			"pressed",
			"_on_EndButton_button_pressed"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_action_executed",
			self,
			"_on_SignalBus_player_action_executed"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_turn_ended",
			self,
			"_on_SignalBus_player_turn_ended"
	)


# Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	encounter_ui.technique_button.disconnect_button_signal(
			self,
			"pressed",
			"_on_TechniqueButton_button_pressed"
	)
	encounter_ui.spell_button.disconnect_button_signal(
			self,
			"pressed",
			"_on_SpellButton_button_pressed"
	)
	encounter_ui.end_button.disconnect_button_signal(
			self,
			"pressed",
			"_on_EndButton_button_pressed"
	)
	SignalBus.disconnect(
			"player_action_executed",
			self,
			"_on_SignalBus_player_action_executed"
	)
	SignalBus.disconnect(
			"player_turn_ended",
			self,
			"_on_SignalBus_player_turn_ended"
	)


# Logic for when a specified option is selected.
func _option_selected(option: int) -> void:
	if _option_flag == option:
		_action_type_canceled()
	else:
		state_machine.transition_to(ACTION, {"option_flag": option})


# Signal that an action type is no longer being looked at before transitioning
# to the 'Standby` state.
func _action_type_canceled() -> void:
	SignalBus.emit_player_action_type_canceled()
	state_machine.transition_to(STANDBY)


# Logic for what happens when the turn has ended.
func _end_selected() -> void:
	SignalBus.emit_player_turn_ended(encounter_ui.get_focused_player())


# Logic for what happens when the Technique button is pressed.
func _on_TechniqueButton_button_pressed() -> void:
	_option_selected(EncounterUI.Options.TECHNIQUE)


# Logic for what happens when the Spell button is pressed.
func _on_SpellButton_button_pressed() -> void:
	print("Spell option selected")
#	_option_selected(EncounterUI.Options.SPELL)


# Logic for what happens when the End button is pressed.
func _on_EndButton_button_pressed() -> void:
	_end_selected()


# Signal that an action option has been selected from the currently
# displayed options.
func _on_SubOptions_option_selected(action_info: Action) -> void:
	_current_action = action_info
	SignalBus.emit_player_action_selected(
			encounter_ui.get_focused_player(),
			_current_action
	)


# Signal that a selected action has been executed. Hide the UI elements.
func _on_SignalBus_player_action_executed(
	_player: PlayerCharacter,
	_action: Action,
	_targets: Array
) -> void:
	encounter_ui.sub_options.deactivate()
	encounter_ui.options.hide()
	encounter_ui.active_player_stats.hide()


# Go to the WAIT state when the player turn has ended.
func _on_SignalBus_player_turn_ended(player: PlayerCharacter) -> void:
	if encounter_ui.get_focused_player() == player:
		state_machine.transition_to(WAIT)
