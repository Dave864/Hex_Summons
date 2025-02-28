class_name EncounterState
extends State
"""
Boilerplate class to get full autocompletion and type checks for an 
`encounter` when coding an encounter's states.
"""


# The name of the states for this FSM.
const START: String = "Start"
const PLAYER_TURN: String = "PlayerTurn"
const ENEMY_TURN: String = "EnemyTurn"
const END: String = "End"

# Typed reference to the Encounter node.
var enc: Encounter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of an `Encounter` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	yield(owner, "ready")
	# The `as` keyword casts the `owner` variable to the `Encounter` type.
	# If the `owner` is not an `Encounter`, we'll get `null`.
	enc = owner as Encounter
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the `Encounter` scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(enc != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
