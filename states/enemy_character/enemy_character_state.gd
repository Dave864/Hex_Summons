class_name EnemyCharacterState
extends State
"""
Boilerplate class to get full autocompletion and type checks for the 
`enemy_character` when coding the enemy character's states.
"""


# The name of the states for this FSM.
const THINK: String = "Think"
const ACTION: String = "Action"
const MOVE: String = "Move"
const WAIT: String = "Wait"

# Typed reference to the PlayerCharacter node.
var ec: EnemyCharacter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of a `PlayerCharacter` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	yield(owner, "ready")
	# The `as` keyword casts the `owner` variable to the `PlayerCharacter` type.
	# If the `owner` is not a `PlayerCharacter`, we'll get `null`.
	ec = owner as EnemyCharacter
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the PlayerCharacter scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(ec != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
