class_name SelectorState
extends State
"""
Boilerplate class to get full autocompletion and type checks for the `selector` 
when coding the selector's states.
"""


# Typed reference to the Selector node.
var selector: Selector


# Called when the node enters the scene tree for the first time.
func _ready():
	# The states are children of the `Selector` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	yield(owner, "ready")
	# The `as` keyword casts the `owner` variable to the `Selector` type.
	# If the `owner` is not a `Selector`, we'll get `null`.
	selector = owner as Selector
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Selector.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(selector != null)
