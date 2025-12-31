class_name EncounterUIMove
extends EncounterUIState
## The logic for what happens when an EncounterUI scene is in the `Move` state.
##
## UI elements relevant to user options become active and are made visible. Moves
## to the `Wait` state when the user chooses to end their turn. Moves to the
## `Pause` state when a PlayerCharacter moves to a new tile. Moves to the
##`Action` state when an action with multiple options is selected.


## Virtual function. Called by the state machine upon changing the active state. 
## The `msg` parameter is a dictionary with arbitrary data the state can use to 
## initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.sub_options.activate()
	encounter_ui.options.show()
	encounter_ui.movement_button.button_pressed = true
	encounter_ui.movement_button.call_deferred("grab_focus")
	_connect_signals()


## Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(event: InputEvent) -> void:
	var gui_focus: Control = encounter_ui.get_viewport().gui_get_focus_owner()
	var movement_focused: bool = gui_focus == encounter_ui.movement_button
	if (
		event.is_action_pressed("ui_selector_select")
		and (InputController.source_is_keymouse() or movement_focused)
	):
		SignalBus.emit_move_path_requested()
	if event.is_action_pressed("ui_encounter_player_end"):
		_end_selected()
	if (
		not encounter_ui.technique_button.disabled
		and event.is_action_pressed("ui_encounter_option_1")
	):
		_technique_selected()
	if (
		not encounter_ui.spell_button.disabled
		and event.is_action_pressed("ui_encounter_option_2")
	):
		_spell_selected()
	if (
		not encounter_ui.item_button.disabled
		and event.is_action_pressed("ui_encounter_option_3")
	):
		_item_selected()
	if (
		not encounter_ui.summon_button.disabled
		and event.is_action_pressed("ui_encounter_option_4")
	):
		_summon_selected()


## Virtual function. Called by the state machine before changing the active 
## state. Use this function to clean up the state.
func exit() -> void:
	_disconnect_signals()


## These signals are used by other states and will be later disconnected to avoid
## unintended behavior.
func _connect_signals() -> void:
	SignalBus.connect(
			"move_path_created",
			Callable(self, "_on_SignalBus_move_path_created")
	)
	encounter_ui.technique_button.connect(
			"pressed",
			Callable(self, "_on_TechniqueButton_pressed")
	)
	encounter_ui.spell_button.connect(
			"pressed",
			Callable(self, "_on_SpellButton_pressed")
	)
	encounter_ui.summon_button.connect(
			"pressed",
			Callable(self, "_on_SummonButton_pressed")
	)
	encounter_ui.item_button.connect(
			"pressed",
			Callable(self, "_on_ItemButton_pressed")
	)
	encounter_ui.end_button.connect(
			"pressed",
			Callable(self, "_on_EndButton_pressed")
	)


## Disconnect signals that will be used by other states in this FSM.
func _disconnect_signals() -> void:
	SignalBus.disconnect(
		"move_path_created",
		Callable(self, "_on_SignalBus_move_path_created")
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


## Handles behavior for when the "TECHNIQUE" option is chosen. Goes to the ACTION
## state, specifying TECHNIQUE as the option.
func _technique_selected() -> void:
	encounter_ui.technique_button.grab_focus()
	_depress_other_options(EncounterUI.Options.TECHNIQUE)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": EncounterUI.Options.TECHNIQUE}
	)


## Handles behavior for when the "SPELL" option is chosen. Goes to the ACTION
## state, specifying SPELL as the option.
func _spell_selected() -> void:
	encounter_ui.spell_button.grab_focus()
	_depress_other_options(EncounterUI.Options.SPELL)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": EncounterUI.Options.SPELL}
	)


## Handles behavior for when the "SUMMON" option is chosen. Goes to the ACTION
## state, specifying SUMMON as the option.
func _summon_selected() -> void:
	encounter_ui.summon_button.call_deferred("grab_focus")
	_depress_other_options(EncounterUI.Options.SUMMON)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": EncounterUI.Options.SUMMON}
	)


## Handles behavior for when the "ITEM" option is chosen. Goes to the ACTION
## state, specifying ITEM as the option.
func _item_selected() -> void:
	encounter_ui.item_button.call_deferred("grab_focus")
	_depress_other_options(EncounterUI.Options.ITEM)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": EncounterUI.Options.ITEM}
	)


## Handles behavior for when the "END" option is chosen. The current player turn
## is signaled to have ended, all options are reset, and the state machine goes
## to the WAIT state.
func _end_selected() -> void:
	encounter_ui.get_focused_character().emit_turn_ended()
	encounter_ui.reset_all_options()
	state_machine.transition_to(WAIT)


## Sets the button_pressed state of other option buttons to false.
func _depress_other_options(pressed_option: EncounterUI.Options) -> void:
	var is_pressed: bool = pressed_option == EncounterUI.Options.TECHNIQUE
	encounter_ui.technique_button.button_pressed = is_pressed
	is_pressed = pressed_option == EncounterUI.Options.SPELL
	encounter_ui.spell_button.button_pressed = is_pressed
	is_pressed = pressed_option == EncounterUI.Options.SUMMON
	encounter_ui.summon_button.button_pressed = is_pressed
	is_pressed = pressed_option == EncounterUI.Options.ITEM
	encounter_ui.item_button.button_pressed = is_pressed
	is_pressed = pressed_option == EncounterUI.Options.MOVE
	encounter_ui.movement_button.button_pressed = is_pressed


## Triggered when a move tile has been selected and a path created to said tile.
func _on_SignalBus_move_path_created(_path: PackedVector3Array) -> void:
	if not _state_is_active():
		return
	state_machine.transition_to(PAUSE)


## Catches the signal for when the TechniqueButton is pressed.
func _on_TechniqueButton_pressed() -> void:
	_technique_selected()


## Catches the signal for when the SpellButton is pressed.
func _on_SpellButton_pressed() -> void:
	_spell_selected()


## Catches the signal for when the SummonButton is pressed.
func _on_SummonButton_pressed() -> void:
	_summon_selected()


## Catches the signal for when the ItemButton is pressed.
func _on_ItemButton_pressed() -> void:
	_item_selected()


## Catches the signal for when the EndButton is pressed.
func _on_EndButton_pressed() -> void:
	_end_selected()
