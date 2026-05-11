@abstract
extends State
class_name EncounterCameraState
## Boilerplate class to get full autocompletion and type checks for an 
## `encounter_camera` when coding an encounter camera's states.


# The name of the states for this FSM.
var ROTATE: String = "Rotate"
var NORMALIZE: String = "Normalize"
var RESET: String = "Reset"

## Typed reference to the EncounterCamera node.
var enc_camera: EncounterCamera


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of an `EncounterCamera` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `EncounterCamera` type.
	# If the `owner` is not an `EncounterCamera`, we'll get `null`.
	enc_camera = owner as EncounterCamera
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the `EncounterCamera` scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(enc_camera != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
