class_name Effect
extends Node
## Base class for effects that modify the stats of characters.


## Reference to the potency details of an action.
var _action_potency: Potency = null
## The stats of the entity that will apply this effect.
var _source_stats: StatModifiers = null
var _aspects: Array[EffectAspect]


## Called when the node enters the scene tree for the first time.
## The _action_potency and _source_stats variables are set by the Action 
## this node is a child of.
func _ready():
	for aspect: EffectAspect in get_children():
		_aspects.append(aspect)
	_check_for_required_parameters()


## Updates the action_potency reference for this effect.
func set_action_potency(ap: Potency) -> void:
	_action_potency = ap
	_set_aspects_action_potency()


## Updates the source character stats of this effect.
func set_source_stats(new_source: StatModifiers) -> void:
	_source_stats = new_source
	_set_aspects_source_stats()


## Get all aspects associated with this effect.
func get_aspects() -> Array[EffectAspect]:
	return _aspects


## Initializes the action potency of each aspect to the referenced potency.
func _set_aspects_action_potency() -> void:
	for a: EffectAspect in _aspects:
		a.set_action_potency(_action_potency)


## Initializes the source stats of each aspect to the referenced stats.
func _set_aspects_source_stats() -> void:
	for a: EffectAspect in _aspects:
		a.set_source_stats(_source_stats)


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			_aspects.size() > 0,
			"Error: %s Effect does not have any EffectAspects." % [name]
	)
