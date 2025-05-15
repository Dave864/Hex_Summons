class_name HexUtil
extends Object
"""
Collection of functions useful for calculations on a hexagonal grid.
"""


# Represents the possible directions for a hex tile.
enum HexDirection {
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
	HexDirection.UPPER_LEFT: Vector3(0.0, -1.0, 1.0),
	HexDirection.UPPER_RIGHT: Vector3(1.0, -1.0, 0.0),
	HexDirection.RIGHT: Vector3(1.0, 0.0, -1.0),
	HexDirection.BOTTOM_RIGHT: Vector3(0.0, 1.0, -1.0),
	HexDirection.BOTTOM_LEFT: Vector3(-1.0, 1.0, 0.0),
	HexDirection.LEFT: Vector3(-1.0, 0.0, 1.0),
}

# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges.
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# Defines the positions of a unit circle that correspond to the vertices of
# a hexagon.
#    0
# 5 / \ 1
#  |   |
# 4 \ / 2
#    3
const HV_COORD_0: Vector2 = Vector2(0.0, -1.0)
const HV_COORD_1: Vector2 = Vector2(HEX_EDGE_RATIO, -0.5)
const HV_COORD_2: Vector2 = Vector2(HEX_EDGE_RATIO, 0.5)
const HV_COORD_3: Vector2 = Vector2(0.0, 1.0)
const HV_COORD_4: Vector2 = Vector2(-HEX_EDGE_RATIO, 0.5)
const HV_COORD_5: Vector2 = Vector2(-HEX_EDGE_RATIO, -0.5)
const HV_COORDS: Array = [
	HV_COORD_0,
	HV_COORD_1,
	HV_COORD_2,
	HV_COORD_3,
	HV_COORD_4,
	HV_COORD_5
]


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
static func cube_at_distance(
	origin: Vector3,
	distance: float,
	direction: int
) -> Vector3:
	var dest: Vector3 = origin
	if CUBE_DIRECTION_VECTORS.has(direction):
		dest += distance * CUBE_DIRECTION_VECTORS[direction]
	return dest


# Determines the hexagonal direction of a given unit vector.
# 0  /\  1
# 5 |  | 2
# 4  \/  3
static func get_hex_direction(
	dir_vec: Vector2,
	top_vertex: int = 0
) -> int:
	var dir: int = -1
	if (
		dir_vec.x > HV_COORD_0.x
		and dir_vec.x < HV_COORD_1.x
		and dir_vec.y < 0.0
	):
		dir = HexDirection.UPPER_RIGHT
	elif (
		dir_vec.x > 0.0
		and dir_vec.y > HV_COORD_1.y
		and dir_vec.y < HV_COORD_2.y
	):
		dir = HexDirection.RIGHT
	elif(
		dir_vec.x > HV_COORD_3.x
		and dir_vec.x < HV_COORD_2.x
		and dir_vec.y > 0.0
	):
		dir = HexDirection.BOTTOM_RIGHT
	elif(
		dir_vec.x > HV_COORD_4.x
		and dir_vec.x < HV_COORD_3.x
		and dir_vec.y > 0.0
	):
		dir = HexDirection.BOTTOM_LEFT
	elif(
		dir_vec.x < 0.0
		and dir_vec.y < HV_COORD_4.y
		and dir_vec.y > HV_COORD_5.y
	):
		dir = HexDirection.LEFT
	elif(
		dir_vec.x < HV_COORD_0.x
		and dir_vec.x > HV_COORD_5.x
		and dir_vec.y < 0.0
	):
		dir = HexDirection.UPPER_LEFT
	return _relative_hex_direction(dir, top_vertex)


# Converts joystick input to a hexagonal direction
static func joystick_to_hex_direction(top_vertex: int = 0) -> int:
	var dir_vec: Vector2 = Input.get_vector(
			"ui_selector_l",
			"ui_selector_r",
			"ui_selector_u",
			"ui_selector_d"
	)
	return get_hex_direction(dir_vec, top_vertex)


# Get the hexagonal direction relative to the defined top vertex. Used to
# match the joystick direction with respect to the camera orientation.
# 0  /\  1
# 5 |  | 2
# 4  \/  3
static func _relative_hex_direction(
	desired_direction: int,
	relative_top: int = 0
) -> int:
	return posmod(desired_direction + relative_top, 6)


# Get the axial direction relative to the defined top vertex. Used to
# match the joystick direction with respect to the camera orientation.
# 0  /\            /\  0
# 3 |  | 1  or  3 |  | 1
#    \/  2      2  \/
static func _relative_to_topaxial_direction(
	desired_direction: int,
	relative_top: int = 0
) -> int:
	return posmod(desired_direction + relative_top, 4)
