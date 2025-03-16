class_name Action
extends Node
"""
Describes the range and effects of an action.
"""


"""
TODO: Implement logic to use stats nodes to define action effect
"""
export(int, 1, 1000) var power
# The area specifying the possible tiles for effect emmision.
export var area_range: Resource = null
# The area that is ignored when determining the possible tiles for effect emmision.
export var dead_range: Resource = null
# The area specifying the tiles affected by the effect.
export var effect_range: Resource = null
# Flag that denotes if the emission is fixed to the center of the area.
export(bool) var emit_from_center
# Flag that denotes if the emission ignores tile heights.
export(bool) var ignore_heights

# Whether the area range is cardinal or ring.
var _is_cardinal: bool = false setget , get_is_cardinal
# The index of the tile the effect is emitted from.
var _emission_map_index: int = -1 setget set_emission_map_index, get_emission_map_index
# The direction the effect is emitted. Only updated if the action is cardinal.
var _emission_direction: int setget set_emission_direction, get_emission_direction


func _ready() -> void:
	assert(
		area_range != null,
		ErrorUtil.missing_required_parameter(name, "area_range")
	)
	assert(
		effect_range != null,
		ErrorUtil.missing_required_parameter(name, "effect_range")
	)
	# No DeadRange node indicates no dead range.
	_is_cardinal = area_range is CardinalArea
	set_emission_direction(HexUtil.Direction.UPPER_LEFT)


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
