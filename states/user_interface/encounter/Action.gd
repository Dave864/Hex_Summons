extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Action` state.
"""


var option_flag: int


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(ACTION)
	option_flag = _msg["option_flag"]
	encounter_ui.set_current_selection(option_flag)
	_toggle_option()


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	_toggle_option()
	encounter_ui.sub_options.clear_sub_options()


func _toggle_option() -> void:
	match option_flag:
		encounter_ui.Options.TECHNIQUE:
			encounter_ui.technique_button.disabled = !encounter_ui.technique_button.disabled
		encounter_ui.Options.SPELL:
			pass
		encounter_ui.Options.SUMMON:
			pass
		_:
			pass
