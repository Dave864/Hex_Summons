class_name Effect
extends Node
"""
Base class for effects that modify the stats of characters.
"""


var _aspects: Array setget , get_aspects


# Called when the node enters the scene tree for the first time.
func _ready():
	_aspects = get_children()
	_check_for_required_parameters()


func get_aspects() -> Array:
	return _aspects


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			_aspects.size() > 0,
			"Error: %s Effect does not have any EffectAspects." % [name]
	)
	for a in _aspects:
		assert(
				a is EffectAspect,
				"Error: Node %s of %s Effect is not an EffectAspect." % [a.name, name]
		)
