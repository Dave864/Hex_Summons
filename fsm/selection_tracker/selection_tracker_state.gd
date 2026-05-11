@abstract
class_name SelectionTrackerState
extends State
## Boilerplate class to get full autocompletion and type checks for the `selector` 
## when coding the selector's states.


# The states the Selector can be in.
const START := "Start"
const MOVE := "Move"
const DIRECTIONAL_ACTION := "DirectionalAction"
const POSITIONAL_ACTION := "PositionalAction"
const PROCESS := "Process"
const WAIT := "Wait"

## Typed reference to the SelectionTracker node.
var s_tracker: SelectionTracker
## Typed reference to the Selector node.
var selector: Selector
## Typed reference to the HexMap.
var hex_map: HexMap


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of the `SelectionTracker` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Selector` type.
	# If the `owner` is not a `SelectionTracker`, we'll get `null`.
	s_tracker = owner as SelectionTracker
	selector = s_tracker.selector
	hex_map = s_tracker.hex_map
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Selector.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(s_tracker != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
