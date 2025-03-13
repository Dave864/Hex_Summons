extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Standby` state.
UI elements relevant to user options become active and are made visible. Moves
to the `Wait` state when the user chooses to end their turn. Moves to the
`Pause` state when a PlayerCharacter moves to a new tile. Moves to the
`Action` state when an action with multiple options is selected.
"""


# Virtual function. Called by the state machine upon changing the active state. 
# The `msg` parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.sub_options.show()
	encounter_ui.options.show()
	
	# These signals are used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
			SignalBus,
			"move_tile_selected",
			self,
			"_on_SignalBus_move_tile_selected"
	)
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


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_encounter_player_end"):
		SignalBus.emit_signal("player_turn_ended", encounter_ui.get_focused_player())
		state_machine.transition_to(WAIT)
	if _event.is_action_pressed("ui_encounter_option_1"):
		_technique_selected()
	if _event.is_action_pressed("ui_encounter_option_2"):
		_spell_selected()
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


# Virtual function. Called by the state machine before changing the active 
# state. Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect("move_tile_selected", self, "_on_SignalBus_move_tile_selected")
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


func _technique_selected() -> void:
	state_machine.transition_to(
			ACTION, 
			{"option_flag": encounter_ui.Options.TECHNIQUE}
	)


func _spell_selected() -> void:
	print("Selecting a spell")


func _end_selected() -> void:
	SignalBus.emit_signal("player_turn_ended", encounter_ui.get_focused_player())
	state_machine.transition_to(WAIT)


func _on_SignalBus_move_tile_selected(_info: Array) -> void:
	state_machine.transition_to(PAUSE)


func _on_TechniqueButton_button_pressed() -> void:
	_technique_selected()


func _on_SpellButton_button_pressed() -> void:
	_spell_selected()


func _on_EndButton_button_pressed() -> void:
	_end_selected()
