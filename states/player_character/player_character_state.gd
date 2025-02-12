class_name PlayerCharacterState
extends State
"""
Boilerplate class to get full autocompletion and type checks for the 
`player_character` when coding the player character's states.
"""


# The name of the states for this FSM.
const WAIT: String = "Wait"
const STANDBY: String = "Standby"
const MOVE: String = "Move"
const ATTACK: String = "Attack"

# Typed reference to the PlayerCharacter node.
var pc: PlayerCharacter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of a `PlayerCharacter` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	yield(owner, "ready")
	# The `as` keyword casts the `owner` variable to the `PlayerCharacter` type.
	# If the `owner` is not a `PlayerCharacter`, we'll get `null`.
	pc = owner as PlayerCharacter
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the PlayerCharacter scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(pc != null)


# Update the value of the state bus for the PlayerCharacter state machine.
func _set_state_machine_bus(var state: String) -> void:
	StateMachineBus.encounter_states[FSM.Encounter.PLAYER_CHARACTER] = state
