class_name EffectsList
extends Node
## Tracks all effects for an action.
##
## This node will track all children that are an Effect node. Handles
## initialization and updating of action potency and source character stat
## references for tracked effects.


## The list of effects.
var _effects: Array[ActionEffect] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child_node: Node in get_children():
		if child_node is ActionEffect:
			_effects.append(child_node as ActionEffect)
	_check_for_required_parameters()


## Returns the effects tracked.
func get_effects() -> Array[ActionEffect]:
	return _effects


## Updates the action_potency reference for this effect.
func set_action_potency(action_potency: Potency) -> void:
	for effect: ActionEffect in _effects:
		effect.set_action_potency(action_potency)


## Updates the source character stats of this effect.
func set_source_stats(new_source: StatModifiers) -> void:
	for effect: ActionEffect in _effects:
		effect.set_source_stats(new_source)


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(_effects.size() > 0, "Error: No effects in EffectList.")
