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
	_set_state_machine_bus(STANDBY)
	encounter_ui.sub_options.show()
	encounter_ui.options.show()
	# This signal is used by other states and will be disconnected to avoid
	# unintended behavior.
	ErrorUtil.connect_signal(
			SignalBus,
			"tile_selected",
			self,
			"_on_SignalBus_tile_selected"
	)


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_encounter_player_end"):
		SignalBus.emit_signal("player_turn_ended", encounter_ui.get_focused_player())
		state_machine.transition_to(WAIT)


# Virtual function. Called by the state machine before changing the active 
# state. Use this function to clean up the state.
func exit() -> void:
	SignalBus.disconnect("tile_selected", self, "_on_SignalBus_tile_selected")


func _ready_connect_signals() -> void:
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

func _on_SignalBus_tile_selected(_info: Array) -> void:
	state_machine.transition_to(PAUSE)


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
