class_name EncounterUIState
extends State
"""
Boilerplate class to get full autocompletion and type checks for the `EncounterUI` 
when coding the EncounterUI's states.
"""


# The states the Encounter UI can be in.
const WAIT: String = "Wait"
const STANDBY: String = "Standby"
const PAUSE: String = "Pause"
const ACTION_SELECT: String = "ActionSelect"
const SUB_ACTION_SELECT: String = "SubActionSelect"

# Typed reference to the EncounterUI node.
var encounter_ui: EncounterUI

# Called when the node enters the scene tree for the first time.
func _ready():
	# The states are children of the `EncounterUI` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	yield(owner, "ready")
	# The `as` keyword casts the `owner` variable to the `EncounterUI` type.
	# If the `owner` is not a `EncounterUI`, we'll get `null`.
	encounter_ui = owner as EncounterUI
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `EncounterUI.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(encounter_ui != null)


# Update the value of the state bus for the EncounterUI state machine.
func _set_state_machine_bus(var state: String) -> void:
	StateMachineBus.encounter_states[FSM.Encounter.UI] = state
