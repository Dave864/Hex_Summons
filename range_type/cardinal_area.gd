class_name CardinalArea
extends AreaRange
"""
Describes an area whose area is constrained by the six directions of a hexagon.
"""


# How many tiles out the range will reach.
export(int, 1, 1000) var distance = 1


## Determines which map tiles are in the cardinal area positioned at the start index.
## Does not account for tile heights.
#func determine_area_indexes(start: int, map_tiles: Tiles) -> Array:
#	var tile_ids: Array = []
#	var start_coord: Vector3 = map_tiles.get_tile_at_index(start).map_coordinate.get_cube_coord()
#	tile_ids.append(start)
#	for d in range(1, distance + 1):
#		for n in range(6):
#			var coord: Vector3 = HexUtil.cube_at_distance(start_coord, d, n)
#			if map_tiles.is_valid_cube(coord):
#				tile_ids.append(coord)
#	return tile_ids
