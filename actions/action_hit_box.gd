class_name ActionHitBox
extends Area3D
## Defines the hit box for a given action.
##
## Tracks the potency and effects of the action this hit box is for.


## Reference to the node that holds the action effects.
@export var effects_list: EffectsList = null

## The action effects for the action.
var _effects: Array[ActionEffect] = []

## The collision shape for the hit box.
@onready var _c_shape: CollisionShape3D = $CollisionShape3D


## Gets the effects this hit box is transferring.
func get_effects() -> Array[ActionEffect]:
	return _effects


## Activates the collision shape on the next frame.
func activate() -> void:
	monitorable = true
	_c_shape.set_deferred("disabled", false)


## Deactivates the collision shape on the next frame.
func deactivate() -> void:
	monitorable = false
	_c_shape.set_deferred("disabled", true)


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	await effects_list.ready
	_effects = effects_list.get_effects()


## Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(effects_list != null, "ActionHitBox is missing EffectList reference.")
