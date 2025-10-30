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
func enter(msg := {}) -> void:
	_option_flag = msg["option_flag"]
	encounter_ui.set_current_selection(_option_flag)
	encounter_ui.grab_focus_for_sub_option_at_index(0)
	_current_action = encounter_ui.get_sub_option_at_index(0)
	SignalBus.emit_player_action_selected(
			encounter_ui.get_focused_player(),
			_current_action
	)
	_connect_signals()


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(event: InputEvent) -> void:
	if (
		InputController.source_is_keymouse()
		and event.is_action_pressed("ui_selector_select")
	):
		SignalBus.emit_player_action_selected(
				encounter_ui.get_focused_player(),
				_current_action
		)
	if event.is_action_pressed("ui_encounter_movement"):
		_movement_selected()
	if event.is_action_pressed("ui_encounter_player_end"):
		_end_selected()
	if (
		not encounter_ui.technique_button.disabled
		and event.is_action_pressed("ui_encounter_option_1")
	):
		_option_selected(EncounterUI.Options.TECHNIQUE)
	if (
		not encounter_ui.spell_button.disabled
		and event.is_action_pressed("ui_encounter_option_2")
	):
		_option_selected(EncounterUI.Options.SPELL)
	if (
		not encounter_ui.item_button.disabled
		and event.is_action_pressed("ui_encounter_option_3")
	):
		print("Item option selected")
#		_option_selected(EncounterUI.Options.ITEM)
	if (
		not encounter_ui.summon_button.disabled
		and event.is_action_pressed("ui_encounter_option_4")
	):
		print("Summon option selected")
#		_option_selected(EncounterUI.Options.SUMMON)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	encounter_ui.sub_options.clear_sub_options()
	_disconnect_signals()


# Connect the relevant signals to this state.
# These signals are used by other states and will be disconnected to avoid
# unintended behavior.
func _connect_signals() -> void:
	ErrorUtil.connect_signal(
			encounter_ui.get_focused_player(),
			"turn_ended",
			self,
			"_on_PlayerCharacter_turn_ended"
	)
	ErrorUtil.connect_signal(
			encounter_ui.movement_button,
			"pressed",
			self,
			"_on_MovementButton_pressed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.technique_button,
			"pressed",
			self,
			"_on_TechniqueButton_pressed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.spell_button,
			"pressed",
			self,
			"_on_SpellButton_pressed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.summon_button,
			"pressed",
			self,
			"_on_SummonButton_pressed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.item_button,
			"pressed",
			self,
			"_on_ItemButton_pressed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.end_button,
			"pressed",
			self,
			"_on_EndButton_pressed"
	)
	ErrorUtil.connect_signal(
			SignalBus,
			"player_action_executed",
			self,
			"_on_SignalBus_player_action_executed"
	)


# Disconnect the signals connected to this state.
func _disconnect_signals() -> void:
	encounter_ui.get_focused_player().disconnect(
			"turn_ended",
			Callable(self, "_on_PlayerCharacter_turn_ended")
	)
	encounter_ui.movement_button.disconnect(
			"pressed",
			Callable(self, "_on_MovementButton_pressed")
	)
	encounter_ui.technique_button.disconnect(
			"pressed",
			Callable(self, "_on_TechniqueButton_pressed")
	)
	encounter_ui.spell_button.disconnect(
			"pressed",
			Callable(self, "_on_SpellButton_pressed")
	)
	encounter_ui.summon_button.disconnect(
			"pressed",
			Callable(self, "_on_SummonButton_pressed")
	)
	encounter_ui.item_button.disconnect(
			"pressed",
			Callable(self, "_on_ItemButton_pressed")
	)
	encounter_ui.end_button.disconnect(
			"pressed",
			Callable(self, "_on_EndButton_pressed")
	)
	SignalBus.disconnect(
			"player_action_executed",
			Callable(self, "_on_SignalBus_player_action_executed")
	)


# Logic for what happens when the turn has ended.
func _end_selected() -> void:
	encounter_ui.end_button.call_deferred("grab_focus")
	encounter_ui.reset_all_options()
	encounter_ui.get_focused_player().emit_turn_ended()


# Logic for when movement has been selected.
func _movement_selected() -> void:
	_toggle_off_current_option()
	_action_type_canceled()


# Logic for when a specified option is selected.
func _option_selected(option: int) -> void:
	_toggle_off_current_option()
	if _option_flag == option:
		_action_type_canceled()
	else:
		state_machine.transition_to(ACTION, {"option_flag": option})


# Toggles off the currently active option.
func _toggle_off_current_option() -> void:
	match _option_flag:
		EncounterUI.Options.TECHNIQUE:
			encounter_ui.technique_button.button_pressed = false
		EncounterUI.Options.SPELL:
			encounter_ui.spell_button.button_pressed = false
		EncounterUI.Options.SUMMON:
			encounter_ui.summon_button.button_pressed = false
		EncounterUI.Options.ITEM:
			encounter_ui.item_button.button_pressed = false
		_:
			pass


# Signal that an action type is no longer being looked at before transitioning
# to the 'Move' state.
func _action_type_canceled() -> void:
	SignalBus.emit_player_action_type_canceled()
	state_machine.transition_to(MOVE)


# Logic for what happens when the Movement button is pressed.
func _on_MovementButton_pressed() -> void:
	_movement_selected()


# Logic for what happens when the Technique button is pressed.
func _on_TechniqueButton_pressed() -> void:
	_option_selected(EncounterUI.Options.TECHNIQUE)


# Logic for what happens when the Spell button is pressed.
func _on_SpellButton_pressed() -> void:
	_option_selected(EncounterUI.Options.SPELL)


# Logic for what happens when the Summon button is pressed.
func _on_SummonButton_pressed() -> void:
	print("Summon option selected")
#	_option_selected(EncounterUI.Options.SUMMON)


# Logic for what happens when the Item button is pressed.
func _on_ItemButton_pressed() -> void:
	print("Item option selected")
#	_option_selected(EncounterUI.Options.ITEM)


# Logic for what happens when the End button is pressed.
func _on_EndButton_pressed() -> void:
	_end_selected()


# Go to the WAIT state when the player turn has ended.
func _on_PlayerCharacter_turn_ended() -> void:
	state_machine.transition_to(WAIT)


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
