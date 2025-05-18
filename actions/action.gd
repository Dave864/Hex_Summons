class_name Action
extends Node
"""
Describes the range and effects of an action.
"""


"""
TODO: Implement logic to use stats nodes to define action effect
"""
# The modifier that will be applied to the character's attack stat when this action is used.
export(float, 0, 3) var potency = 1.0
# The elemental affinity of the action.
export(int, 0, 6) var earth_affinity = 0
export(int, 0, 6) var fire_affinity = 0
export(int, 0, 6) var water_affinity = 0
export(int, 0, 6) var wind_affinity = 0
# The details of the area and effect range of the action.
export(Resource) var ranges = null
# The target of the action.
export(Resource) var target = null

# Whether the area range is cardinal or ring.
var _is_cardinal: bool = false setget , get_is_cardinal
# The index of the tile the effect is emitted from.
var _emission_map_index: int = -1 setget set_emission_map_index, get_emission_map_index
# The direction the effect is emitted. Only updated if the action is cardinal.
var _emission_direction: int setget set_emission_direction, get_emission_direction


func _ready() -> void:
	_check_for_required_parameters()
	# No DeadRange node indicates no dead range.
	_is_cardinal = ranges.area_range is CardinalArea
	set_emission_direction(HexUtil.HexDirection.UPPER_LEFT)


func _process(_delta) -> void:
	pass


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


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			ranges != null,
			ErrorUtil.missing_required_parameter(name, "ranges")
	)
	assert(
			ranges is ActionRanges,
			"Error: Action %s ranges is not of type ActionRanges."
	)
	assert(
			ranges.area_range != null,
			ErrorUtil.missing_required_parameter(name, "area_range")
	)
	assert(
			ranges.area_range is CardinalArea or ranges.area_range is RingArea,
			"Error: Action %s area_range is neither a CardinalArea or RingArea." % [name]
	)
	if ranges.dead_range != null:
		assert(
				ranges.dead_range is CardinalArea or ranges.dead_range is RingArea,
				"Error: Action %s dead_range is neither a CardinalArea or RingArea."
		)
	assert(
			ranges.effect_range != null,
			ErrorUtil.missing_required_parameter(name, "effect_range")
	)
	assert(
			ranges.effect_range is AreaRange,
			"Error: Action %s effect_range is not an AreaRange." % [name]
	)
	assert(
			target != null,
			ErrorUtil.missing_required_parameter(name, "target")
	)
	assert(
			target is ActionTarget,
			"Error: Action %s target is not an ActionTarget." % [name]
	)
