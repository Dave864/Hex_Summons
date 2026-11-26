@abstract
class_name TutorialState
extends State
## Boilerplate class to get full autocompletion and type checks for a 
## `tutorial` when coding a tutorial's states.


## The name of the starting state of the Tutorial fsm.
const START: String = "Start"
## The name of the instruction turn state of the Tutorial fsm.
const INSTRUCTION: String = "Instruction"
## The name of the player turn state of the Tutorial fsm.
const PLAYER_TURN: String = "PlayerTurn"
## The name of the enemy turn state of the Tutorial fsm.
const ENEMY_TURN: String = "EnemyTurn"
## The name of the summon turn state of the Tutorial fsm.
const SUMMON_TURN: String = "SummonTurn"
## The name of the end state of the Tutorial fsm.
const END: String = "End"

## Typed reference to the Tutorial node.
var tutorial: Tutorial


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of an `Tutorial` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Tutorial` type.
	# If the `owner` is not an `Tutorial`, we'll get `null`.
	tutorial = owner as Tutorial
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the `Tutorial` scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(tutorial != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
