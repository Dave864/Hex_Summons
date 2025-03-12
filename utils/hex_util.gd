class_name HexUtil
extends Object
"""
Collection of functions useful for calculating on a hexagonal grid.
"""


# Collection of vectors that represent the direction for a hex tile described
# in cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#neighbors-cube
const CUBE_DIRECTION_VECTORS: Dictionary = {
	MapTile.NeighborPosition.UPPER_LEFT: Vector3(0.0, -1.0, 1.0),
	MapTile.NeighborPosition.UPPER_RIGHT: Vector3(1.0, -1.0, 0.0),
	MapTile.NeighborPosition.RIGHT: Vector3(1.0, 0.0, -1.0),
	MapTile.NeighborPosition.BOTTOM_RIGHT: Vector3(0.0, 1.0, -1.0),
	MapTile.NeighborPosition.BOTTOM_LEFT: Vector3(-1.0, 1.0, 0.0),
	MapTile.NeighborPosition.LEFT: Vector3(-1.0, 0.0, 1.0),
}


# Converts the index to the corresponding cube coordinate.
# Requires the number of tiles in a map along the x-axis.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func index_to_cube(index: int, x_count: int) -> Vector3:
	var z_pos: int = int(floor(float(index) / float(x_count)))
	var x_pos: int = index % x_count
	var x_cube: int = int(x_pos - (z_pos - (z_pos & 1)) / 2.0)
	var y_cube: int = z_pos
	return Vector3(x_cube, y_cube, -x_cube - y_cube)


# Converts the cube coordinates to the corresponding index.
# Requires the number of tiles in a map along the x-axis.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func cube_to_index(coord: Vector3, x_count: int) -> int:
	# Use bitwise and to detect whether something is even (0) or odd (1), 
	# in order to catch negative numbers too.
	var z_pos: int = int(coord.y + (coord.x - (int(coord.x) & 1)) / 2.0)
	var x_pos: int = int(coord.x)
	return (z_pos * x_count) + x_pos


# Get the cube coordinates of the tile a specified distance away from an origin
# point in a specific hexagonal cardinal direction.
# 0  /\  1
# 5 |  | 2
# 4  \/  3
# Reference: # https://www.redblobgames.com/grids/hexagons/#neighbors
static func cube_at_distance(origin: Vector3, distance: float, direction: int) -> Vector3:
	var dest: Vector3 = origin
	if CUBE_DIRECTION_VECTORS.has(direction):
		dest += distance * CUBE_DIRECTION_VECTORS[direction]
	return dest
