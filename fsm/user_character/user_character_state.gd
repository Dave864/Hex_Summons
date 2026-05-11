@abstract
class_name UserCharacterState
extends State
## Boilerplate class to get full autocompletion and type checks for a character 
## controlled by the user when coding the states for said characters.


# The name of the states for this FSM.
const WAIT: String = "Wait"
const STANDBY: String = "Standby"
const MOVE: String = "Move"
const ACTION: String = "Action"

## Typed reference to the Character node.
var character: Character


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of a `PlayerCharacter` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `PlayerCharacter` type.
	# If the `owner` is not a `PlayerCharacter`, we'll get `null`.
	character = owner as Character
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the PlayerCharacter scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(character != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
