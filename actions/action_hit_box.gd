class_name ActionHitBox
extends Area
"""
Defines the hit box for a given action. Tracks the potency and effects of the
action this hit box is for.
"""


export(NodePath) var effects_ref = null

var caster_id: int = -1

var _effects: Array = [] setget , get_effects

onready var _c_shape: CollisionShape = $CollisionShape


# Gets the effects this hit box is transferring.
func get_effects() -> Array:
	return _effects


# Activates the collision shape.
func activate() -> void:
	monitorable = true
	_c_shape.disabled = false


# Deactivates the collision shape.
func deactivate() -> void:
	monitorable = false
	_c_shape.disabled = true


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	var effects_node: Node = get_node(effects_ref)
	yield(effects_node, "ready")
	_effects = effects_node.get_children()


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(effects_ref != null, "ActionHitBox is missing effect reference.")
