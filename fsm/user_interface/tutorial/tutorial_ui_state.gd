@abstract
class_name TutorialUIState
extends State
## Boilerplate class to get full autocompletion and type checks for the `TutorialUI` 
## when coding the TutorialUI's states.


# The states the Tutorial UI can be in.
const WAIT := "Wait"
const PAUSE := "Pause"
const ACTION := "Action"

## Typed reference to the TutorialUI node.
var tutorial_ui: TutorialUIMenuLayout

## Called when the node enters the scene tree for the first time.
func _ready():
	# The states are children of the `TutorialUI` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `TutorialUI` type.
	# If the `owner` is not a `TutorialUI`, we'll get `null`.
	tutorial_ui = owner as TutorialUIMenuLayout
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `TutorialUI.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(tutorial_ui != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
