class_name HexUtil
extends Object
"""
Collection of functions useful for calculations on a hexagonal grid.
"""


# Represents the possible directions for a hex tile.
enum Direction {
	UPPER_LEFT,
	UPPER_RIGHT,
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	LEFT,
}

# Collection of vectors that represent the direction for a hex tile described
# in cube coordinates.
# Reference: https://www.redblobgames.com/grids/hexagons/#neighbors-cube
const CUBE_DIRECTION_VECTORS: Dictionary = {
	Direction.UPPER_LEFT: Vector3(0.0, -1.0, 1.0),
	Direction.UPPER_RIGHT: Vector3(1.0, -1.0, 0.0),
	Direction.RIGHT: Vector3(1.0, 0.0, -1.0),
	Direction.BOTTOM_RIGHT: Vector3(0.0, 1.0, -1.0),
	Direction.BOTTOM_LEFT: Vector3(-1.0, 1.0, 0.0),
	Direction.LEFT: Vector3(-1.0, 0.0, 1.0),
}

# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges.
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0


# Converts the index to the corresponding cube coordinate.
# Requires the number of tiles in a map along the x-axis.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func index_to_cube(index: int, x_count: int) -> Vector3:
	var z_pos: int = int(floor(float(index) / float(x_count)))
	var x_pos: int = index % x_count
	var x_cube: int = int(x_pos - (z_pos - (z_pos & 1)) / 2.0)
	var y_cube: int = z_pos
	return Vector3(x_cube, y_cube, -x_cube - y_cube)


# Converts the cube coordinates to offset coordinates. The offset coordinates
# have the origin centered at the upper leftmost tile of the hex map.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func cube_to_offset(coord: Vector3) -> Vector2:
	# Use bitwise and to detect whether something is even (0) or odd (1), 
	# in order to catch negative numbers too.
	var x_pos: int = int(coord.x + (coord.y - (int(coord.y) & 1)) / 2.0)
	var z_pos: int = int(coord.y)
	return Vector2(x_pos, z_pos)


# Converts the cube coordinates to the corresponding index.
# Requires the number of tiles in a map along the x-axis.
# Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func cube_to_index(coord: Vector3, x_count: int) -> int:
	var offset_coord: Vector2 = cube_to_offset(coord)
	return int((offset_coord.y * x_count) + offset_coord.x)


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


# Determines the hexagonal direction a tile position is at relative to a source
# position.
# 0  /\  1
# 5 |  | 2
# 4  \/  3
static func get_hex_direction(tile_from: Vector3, tile_to: Vector3) -> int:
	
	return 0
