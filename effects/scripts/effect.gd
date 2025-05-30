class_name Effect
extends Node
"""
Base class for effects that modify the stats of characters.
"""


# Reference to the potency details of an action.
var _action_potency: Potency = null setget set_action_potency
# The stats of the character that will apply this effect.
var _source_stats: CharacterStats = null setget set_source_stats
var _aspects: Array setget , get_aspects


# Called when the node enters the scene tree for the first time.
func _ready():
	_aspects = get_children()
	_check_for_required_parameters()
	_set_aspects_action_potency()


# Updates the action_potency reference for this effect.
func set_action_potency(ap: Potency) -> void:
	_action_potency = ap
	_set_aspects_action_potency()


# Updates the source character stats of this effect.
func set_source_stats(new_source: CharacterStats) -> void:
	_source_stats = new_source


func get_aspects() -> Array:
	return _aspects


# Initializes the action potency of each aspect to the referenced potency.
func _set_aspects_action_potency() -> void:
	for a in _aspects:
		a.set_action_potency(_action_potency)


# Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			_action_potency != null,
			"Error: %s Effect missing defined action_potency." % [name]
	)
	assert(
			_aspects.size() > 0,
			"Error: %s Effect does not have any EffectAspects." % [name]
	)
	for a in _aspects:
		assert(
				a is EffectAspect,
				"Error: Node %s of %s Effect is not an EffectAspect." % [a.name, name]
		)
