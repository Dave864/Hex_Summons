extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Action` state.
"""


var option_flag: int


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	option_flag = _msg["option_flag"]
	encounter_ui.set_current_selection(option_flag)
	_toggle_option()
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
			encounter_ui.technique_button,
			"button_state_changed",
			self,
			"_on_TechniqueButton_button_state_changed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.spell_button,
			"button_state_changed",
			self,
			"_on_SpellButton_button_state_changed"
	)
	ErrorUtil.connect_signal(
			encounter_ui.end_button,
			"button_state_changed",
			self,
			"_on_EndButton_button_state_changed"
	)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	_toggle_option()
	encounter_ui.sub_options.clear_sub_options()
	encounter_ui.technique_button.disconnect(
		"button_state_changed",
		self,
		"_on_TechniqueButton_button_state_changed"
	)
	encounter_ui.spell_button.disconnect(
		"button_state_changed",
		self,
		"_on_SpellButton_button_state_changed"
	)
	encounter_ui.end_button.disconnect(
		"button_state_changed",
		self,
		"_on_EndButton_button_state_changed"
	)


func _toggle_option() -> void:
	match option_flag:
		encounter_ui.Options.TECHNIQUE:
			encounter_ui.technique_button.disabled = !encounter_ui.technique_button.disabled
		encounter_ui.Options.SPELL:
			encounter_ui.spell_button.disabled = !encounter_ui.spell_button.disabled
		encounter_ui.Options.SUMMON:
			encounter_ui.summon_button.disbled = !encounter_ui.summon_button.disbled
		_:
			pass


func _on_TechniqueButton_button_state_changed(state: int) -> void:
	if state == LabeledIconButton.ButtonStates.PRESSED:
		state_machine.transition_to(
			ACTION, 
			{"option_flag": encounter_ui.Options.TECHNIQUE}
		)


func _on_SpellButton_button_state_changed(state: int) -> void:
	if state == LabeledIconButton.ButtonStates.PRESSED:
		print("Selecting a spell")


func _on_EndButton_button_state_changed(state: int) -> void:
	if state == LabeledIconButton.ButtonStates.PRESSED:
		SignalBus.emit_signal("player_turn_ended", encounter_ui.get_focused_player())
		state_machine.transition_to(WAIT)
