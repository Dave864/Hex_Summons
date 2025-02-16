extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Pause` state.
"""


# Virtual function. Called by the state machine upon changing the active state. 
# The `msg` parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(PAUSE)
	encounter_ui.toggle_options()
	
	ErrorUtil.connect_signal(
		SignalBus,
		"selector_required",
		self,
		"_on_SignalBus_selector_required"
	)


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine before changing the active 
# state. Use this function to clean up the state.
func exit() -> void:
	encounter_ui.toggle_options()
	SignalBus.disconnect("selector_required", self, "_on_SignalBus_selector_required")


func _on_SignalBus_selector_required() -> void:
	state_machine.transition_to(STANDBY)
