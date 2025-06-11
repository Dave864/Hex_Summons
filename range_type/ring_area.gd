class_name RingArea
extends AreaRange
"""
Describes a range whose area encompasses all hexes within a defined distance.
"""


# How many tiles out from the cast point the area will reach.
export(int, 0, 1000) var radius = 0


# Determines which map tiles are in the ring area positioned at the start index.
# Does not account for tile heights.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-coordinate
func determine_area_indexes(start: int, map_tiles: Tiles) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			map_tiles.get_tile_at_index(start) \
			.map_coordinate.get_cube_coord()
	)
	for x in range(-radius, radius + 1):
		var x_lower: int = max(-radius, -x - radius) as int
		var x_upper: int = min(radius, radius - x) as int
		for y in range(x_lower, x_upper + 1):
			var coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			if map_tiles.is_valid_cube(coord):
				var tile_id = HexUtil.cube_to_index(coord, map_tiles.get_x_count())
				tile_ids.append(tile_id)
	return tile_ids


# Base function for area ranges that define an area emitted in a direction from
# starting point.
func determine_directional_area_indexes(
	start: int,
	_dir: int,
	map_tiles: Tiles
) -> Array:
	return determine_area_indexes(start, map_tiles)
