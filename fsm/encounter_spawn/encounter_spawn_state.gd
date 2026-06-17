@abstract
class_name EncounterSpawnState
extends State
## Boilerplate class to get full autocompletion and type checks for an 
## `encounter_spawn` when coding an EncounterSpawn's states.


## The starting state where the node appears in the scene.
const SPAWN := "Spawn"
## The state where the node engages in some passive behavior until something
## enters its alert range.
const IDLE := "Idle"
## The state where the node waits for a detected object to either get too close
## or go away.
const ALERT := "Alert"
## The state where the node responds to a detected object.
const REACTION := "Reaction"
## The state where the node vanishes before exiting the scene tree.
const DESPAWN := "Despawn"

## Typed reference to the encounter spawn node.
var enc_spawn : EncounterSpawn


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The states are children of an `EncounterSpawn` node so their `_ready()` 
	# callback will execute first. That's why we wait for the `owner` 
	# to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `EncounterSpawn` type.
	# If the `owner` is not an `EncounterSpawn`, we'll get `null`.
	enc_spawn = owner as EncounterSpawn
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than the `EncounterSpawn` scene, which would be 
	# unintended. This can help prevent some bugs that are difficult to 
	# understand.
	assert(enc_spawn != null)
	# Connect any unique signals the state will use.
	_ready_connect_signals()
