class_name AreaRange
extends Resource
"""
Describes the function signatures for area ranges.
"""


# Base function for area ranges that define a general area around a starting
# point.
func determine_area_indexes(_start: int, _map_tiles: Tiles) -> Array:
	return []


# Base function for area ranges that define an area emitted in a direction from
# starting point.
func determine_directional_area_indexes(
	_start: int,
	_dir: int,
	_map_tiles: Tiles
) -> Array:
	return []
