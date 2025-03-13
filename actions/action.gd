class_name Action
extends Node
"""
Describes the range and effects of an action.
"""


"""
TODO: Implement logic to use stats nodes to define action effect
"""
export(int, 1, 1000) var power
# Flag that denotes if the emission is fixed to the center of the area.
export(bool) var emit_from_center
# Flag that denotes if the emission ignores tile heights.
export(bool) var ignore_heights

# The area that is ignored when determining the possible tiles for effect emmision.
var _dead_range: AreaRange setget , get_dead_range
# The area specifying the possible tiles for effect emmision.
var _area_range: AreaRange
# The area specifying the tiles affected by the effect.
var _effect_range: AreaRange
# Whether the area range is cardinal or ring.
var _is_cardinal: bool = false setget , get_is_cardinal
# The index of the tile the effect is emitted from.
var _emission_map_index: int = -1 setget set_emission_map_index, get_emission_map_index


func _ready() -> void:
	# No DeadRange node indicates no dead range.
	_dead_range = get_node_or_null("DeadRange")
	_area_range = get_node("AreaRange")
	_effect_range = get_node("EffectRange")
	_is_cardinal = _area_range is CardinalArea


func _process(_delta) -> void:
	pass


# Get the details of the dead range.
func get_dead_range() -> AreaRange:
	return _dead_range


# Get the details of the area range.
func get_area_range() -> AreaRange:
	return _area_range


# Get the details of the effect range.
func get_effect_range() -> AreaRange:
	return _effect_range
	

# Returns if the area range is bound cardinally or not.
func get_is_cardinal() -> bool:
	return _is_cardinal


# Set the tile index the effect is emitted from.
func set_emission_map_index(index: int) -> void:
	_emission_map_index = index

# Return the index of the map tile the emission point is at.
func get_emission_map_index() -> int:
	return _emission_map_index


# Resets the position of the emittor.
func reset_emittor_position() -> void:
	_emission_map_index = -1
