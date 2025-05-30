class_name Action
extends Node
"""
Describes the details of an action.
"""


# The path to the stats of the character that owns this action.
export(NodePath) var source_stats_path = null
# The details of the area and effect range of the action.
export(Resource) var stat_details = null

# The effects of this action
var _effects: Array setget , get_effects
# Whether the area range is cardinal or ring.
var _is_cardinal: bool = false setget , get_is_cardinal
# The index of the tile the effect is emitted from.
var _emission_map_index: int = -1 setget set_emission_map_index, get_emission_map_index
# The direction the effect is emitted. Only updated if the action is cardinal.
var _emission_direction: int setget set_emission_direction, get_emission_direction


func _ready() -> void:
	_check_for_required_parameters()
	_initialize_effects()
	_is_cardinal = stat_details.area_range is CardinalArea
	set_emission_direction(HexUtil.HexDirection.UPPER_LEFT)


# Returns the effects of this action.
func get_effects() -> Array:
	return _effects


# Returns if the area range is bound cardinally or not.
func get_is_cardinal() -> bool:
	return _is_cardinal


# Set the tile index the effect is emitted from.
func set_emission_map_index(index: int) -> void:
	_emission_map_index = index

# Return the index of the map tile the emission point is at.
func get_emission_map_index() -> int:
	return _emission_map_index


# Set the direction of the emission (0 - 5). Only updates the direction if the action
# is cardinal.
func set_emission_direction(dir: int) -> void:
	if _is_cardinal:
		_emission_direction = 0 if dir < 0 else 5 if dir > 5 else dir
	else:
		_emission_direction = -1


# Get the direction of the emission. Returns -1 if the action is not cardinal.
func get_emission_direction() -> int:
	return _emission_direction


# Resets the position of the emittor.
func reset_emittor_position() -> void:
	_emission_map_index = -1


# Initialize the effects list of the action, checking that all effects are valid.
func _initialize_effects() -> void:
	_effects = get_children()
	assert(
			len(_effects) > 0,
			"Error: Action %s does not have any effects" % [name]
	)
	for effect in _effects:
		assert(effect is Effect, "Error: Action %s effect %s is not an Effect")
		# Type checking for the node referenced at the path.
		var source_stats_node: CharacterStats = get_node(source_stats_path)
		effect.set_source_stats(source_stats_node)
		effect.set_action_potency(stat_details.potency)


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			source_stats_path != null,
			ErrorUtil.missing_required_parameter(name, "source_stats_path")
	)
	assert(
			stat_details != null,
			ErrorUtil.missing_required_parameter(name, "stat_details")
	)
	assert(
			stat_details is ActionStats,
			"Error: Action %s ranges is not of type ActionStats."
	)
	stat_details.check_for_required_resources()
