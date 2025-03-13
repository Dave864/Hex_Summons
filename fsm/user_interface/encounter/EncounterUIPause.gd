extends EncounterUIState
"""
The logic for what happens when an EncounterUI scene is in the `Pause` state.
Disables all interactable UI elements until they are needed.
"""


# Virtual function. Called by the state machine upon changing the active state. 
# The `msg` parameter is a dictionary with arbitrary data the state can use to 
# initialize itself.
func enter(_msg := {}) -> void:
	encounter_ui.toggle_options()
	
	# This signal is used by other states and will be disconnected to avoid
	# unintended behavior.
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
	SignalBus.disconnect(
			"selector_required",
			self,
			"_on_SignalBus_selector_required"
	)


func _on_SignalBus_selector_required(_ip: Vector3) -> void:
	state_machine.transition_to(STANDBY)
