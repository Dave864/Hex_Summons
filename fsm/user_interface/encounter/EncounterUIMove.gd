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
	if (
		event.is_action_pressed("ui_select")
		and (
			InputController.source_is_keymouse()
			or encounter_ui.get_viewport().gui_get_focus_owner() == encounter_ui.movement_button
		)
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
	ErrorUtil.connect_signal(
			SignalBus,
			"move_path_created",
			self,
			"_on_SignalBus_move_path_created"
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
	_depress_other_options(encounter_ui.Options.TECHNIQUE)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": encounter_ui.Options.TECHNIQUE}
	)


## Handles behavior for when the "SPELL" option is chosen. Goes to the ACTION
## state, specifying SPELL as the option.
func _spell_selected() -> void:
	encounter_ui.spell_button.grab_focus()
	_depress_other_options(encounter_ui.Options.SPELL)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": encounter_ui.Options.SPELL}
	)


## Handles behavior for when the "SUMMON" option is chosen. Goes to the ACTION
## state, specifying SUMMON as the option.
func _summon_selected() -> void:
	encounter_ui.summon_button.call_deferred("grab_focus")
	_depress_other_options(encounter_ui.Options.SUMMON)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": encounter_ui.Options.SUMMON}
	)


## Handles behavior for when the "ITEM" option is chosen. Goes to the ACTION
## state, specifying ITEM as the option.
func _item_selected() -> void:
	encounter_ui.item_button.call_deferred("grab_focus")
	_depress_other_options(encounter_ui.Options.ITEM)
	state_machine.transition_to(
			ACTION, 
			{"option_flag": encounter_ui.Options.ITEM}
	)


## Handles behavior for when the "END" option is chosen. The current player turn
## is signaled to have ended, all options are reset, and the state machine goes
## to the WAIT state.
func _end_selected() -> void:
	encounter_ui.get_focused_player().emit_turn_ended()
	encounter_ui.reset_all_options()
	state_machine.transition_to(WAIT)


## Sets the button_pressed state of other option buttons to false.
func _depress_other_options(pressed_option: int) -> void:
	var is_pressed: bool = pressed_option == encounter_ui.Options.TECHNIQUE
	encounter_ui.technique_button.button_pressed = is_pressed
	is_pressed = pressed_option == encounter_ui.Options.SPELL
	encounter_ui.spell_button.button_pressed = is_pressed
	is_pressed = pressed_option == encounter_ui.Options.SUMMON
	encounter_ui.summon_button.button_pressed = is_pressed
	is_pressed = pressed_option == encounter_ui.Options.ITEM
	encounter_ui.item_button.button_pressed = is_pressed
	is_pressed = pressed_option == encounter_ui.Options.MOVE
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
