class_name HexUtil
extends Object
## Collection of functions useful for calculations on a hexagonal grid.


## Represents the possible directions for a hex tile.
enum HexDirection {
	UPPER_LEFT,
	UPPER_RIGHT,
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	LEFT,
}

## Collection of vectors that represent the direction for a hex tile described
## in cube coordinates.
## Reference: https://www.redblobgames.com/grids/hexagons/#neighbors-cube
const CUBE_DIRECTION_VECTORS: Dictionary[HexDirection, Vector3] = {
	HexDirection.UPPER_LEFT: Vector3(0.0, -1.0, 1.0),
	HexDirection.UPPER_RIGHT: Vector3(1.0, -1.0, 0.0),
	HexDirection.RIGHT: Vector3(1.0, 0.0, -1.0),
	HexDirection.BOTTOM_RIGHT: Vector3(0.0, 1.0, -1.0),
	HexDirection.BOTTOM_LEFT: Vector3(-1.0, 1.0, 0.0),
	HexDirection.LEFT: Vector3(-1.0, 0.0, 1.0),
}

## The ratio between 
## the distance from the center of a hexagon to one of its vertices and 
## the distance from the center of a hexagon to the midpoint of one of its edges.
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# Defines the positions of a unit circle that correspond to the vertices of
# a hexagon.
#    0
# 5 / \ 1
#  |   |
# 4 \ / 2
#    3
## The unit circle position of vertex 0 (top).
const HV_COORD_0: Vector2 = Vector2(0.0, -1.0)
## The unit circle position of vertex 1 (top right).
const HV_COORD_1: Vector2 = Vector2(HEX_EDGE_RATIO, -0.5)
## The unit circle position of vertex 2 (bottom right)
const HV_COORD_2: Vector2 = Vector2(HEX_EDGE_RATIO, 0.5)
## The unit circle position of vertex 3 (bottom).
const HV_COORD_3: Vector2 = Vector2(0.0, 1.0)
## The unit circle position of vertex 4 (bottom left).
const HV_COORD_4: Vector2 = Vector2(-HEX_EDGE_RATIO, 0.5)
## The unit circle position of vertex 5 (top left).
const HV_COORD_5: Vector2 = Vector2(-HEX_EDGE_RATIO, -0.5)


## Converts the index to the corresponding cube coordinate.
## Requires the number of tiles in a map along the x-axis.
## Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func index_to_cube(index: int, x_count: int) -> Vector3:
	var z_pos: int = int(floor(float(index) / float(x_count)))
	var x_pos: int = index % x_count
	var x_cube: int = int(x_pos - (z_pos - (z_pos & 1)) / 2.0)
	return Vector3(x_cube, z_pos, -x_cube - z_pos)


## Converts the cube coordinates to offset coordinates. The offset coordinates
## have the origin centered at the upper leftmost tile of the hex map.
## Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func cube_to_offset(coord: Vector3) -> Vector2:
	# Use bitwise and to detect whether something is even (0) or odd (1), 
	# in order to catch negative numbers too.
	var x_pos: int = int(coord.x + (coord.y - (int(coord.y) & 1)) / 2.0)
	var z_pos: int = int(coord.y)
	return Vector2(x_pos, z_pos)


## Converts the cube coordinates to the corresponding index.
## Requires the number of tiles in a map along the x-axis.
## Reference: https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func cube_to_index(coord: Vector3, x_count: int) -> int:
	var offset_coord: Vector2 = cube_to_offset(coord)
	return int((offset_coord.y * x_count) + offset_coord.x)


## Get the cube coordinates of the tile a specified distance away from an origin
## point in a specific hexagonal cardinal direction.
## 0  /\  1
## 5 |  | 2
## 4  \/  3
## Reference: https://www.redblobgames.com/grids/hexagons/#neighbors
static func cube_at_distance(
	origin: Vector3,
	distance: float,
	direction: int
) -> Vector3:
	var dest: Vector3 = origin
	if CUBE_DIRECTION_VECTORS.has(direction):
		dest += distance * CUBE_DIRECTION_VECTORS[direction]
	return dest


## Calculates the cube distance.
## Reference: https://www.redblobgames.com/grids/hexagons/#distances-cube
static func cube_dist(start: Vector3, end: Vector3) -> float:
	var diff: Vector3 = start - end
	return (abs(diff.x) + abs(diff.y) + abs(diff.z)) / 2.0


## Gets the cube coordinates of the hexes that are in a line from start to end.
## Reference: https://www.redblobgames.com/grids/hexagons/#line-drawing
static func cube_line(start: Vector3, end: Vector3) -> Array[Vector3]:
	var line_cubes: Array[Vector3] = []
	var dist: float = cube_dist(start, end)
	for step in range(dist + 1):
		var step_lerp: float = 1.0 / dist * step
		var cube_lerp: Vector3 = Vector3(
				_cube_axis_lerp(start.x, end.x, step_lerp),
				_cube_axis_lerp(start.y, end.y, step_lerp),
				_cube_axis_lerp(start.z, end.z, step_lerp)
		)
		line_cubes.append(_cube_round(cube_lerp))
	return line_cubes


## Determines the hexagonal direction of a given unit vector.
## 0  /\  1
## 5 |  | 2
## 4  \/  3
static func get_hex_direction(
	dir_vec: Vector2,
	top_vertex: int = 0
) -> HexDirection:
	var dir: int = -1
	if (
		dir_vec.x >= HV_COORD_0.x
		and dir_vec.x < HV_COORD_1.x
		and dir_vec.y <= 0.0
	):
		dir = HexDirection.UPPER_RIGHT
	elif (
		dir_vec.x >= 0.0
		and dir_vec.y >= HV_COORD_1.y
		and dir_vec.y < HV_COORD_2.y
	):
		dir = HexDirection.RIGHT
	elif(
		dir_vec.x >= HV_COORD_3.x
		and dir_vec.x < HV_COORD_2.x
		and dir_vec.y >= 0.0
	):
		dir = HexDirection.BOTTOM_RIGHT
	elif(
		dir_vec.x >= HV_COORD_4.x
		and dir_vec.x < HV_COORD_3.x
		and dir_vec.y >= 0.0
	):
		dir = HexDirection.BOTTOM_LEFT
	elif(
		dir_vec.x <= 0.0
		and dir_vec.y <= HV_COORD_4.y
		and dir_vec.y > HV_COORD_5.y
	):
		dir = HexDirection.LEFT
	else:
		dir = HexDirection.UPPER_LEFT
	return _relative_hex_direction(dir, top_vertex)


## Returns the rotation in radians of the given hex direction. Binds the direction
## to valid hex directions.
## 0: -11 * PI / 6.0  /\  1: -1 * PI / 6.0
## 5: -9 * PI / 6.0  |  | 2: -3 * PI / 6.0
## 4: -7 * PI / 6.0   \/  3: -5 * PI / 6.0
static func dir_rotation(dir: HexDirection) -> float:
	var true_dir: int = 6 if dir == HexDirection.UPPER_LEFT else dir
	# Want to position rotation at midpoint of line. Testing revealed that the
	# rotation needs to be negative in order to align with the direction.
	return -(2 * true_dir - 1) * PI / 6.0


## Get the hexagonal direction relative to the defined top vertex. Used to
## match the camera orientation.
## 0  /\  1
## 5 |  | 2
## 4  \/  3
static func _relative_hex_direction(
	desired_direction: int,
	relative_top: int = 0
) -> HexDirection:
	if desired_direction >= 0:
		return posmod(desired_direction + relative_top, 6) as HexDirection
	else:
		return desired_direction as HexDirection


## Get the axial direction relative to the defined top vertex. Used to
## match the camera orientation.
## 0  /\            /\  0
## 3 |  | 1  or  3 |  | 1
##    \/  2      2  \/
static func _relative_axial_direction(
	desired_direction: int,
	relative_top: int = 0
) -> int:
	if desired_direction >= 0:
		return posmod(desired_direction + relative_top, 4)
	else:
		return desired_direction


## Linearly interpolates between two points of a cube coordinate axis.
## Helper for cube_line.
## Reference: https://www.redblobgames.com/grids/hexagons/#line-drawing
static func _cube_axis_lerp(start: float, end: float, weight: float) -> float:
	return start + (end - start) * weight


## Rounds the given cube fraction to the nearest cube coordinate. Helper for
## cube_line.
## Reference: https://www.redblobgames.com/grids/hexagons/#rounding
static func _cube_round(cube_frac: Vector3) -> Vector3:
	var x: float = round(cube_frac.x)
	var y: float = round(cube_frac.y)
	var z: float = round(cube_frac.z)

	var x_diff: float = abs(x - cube_frac.x)
	var y_diff: float = abs(y - cube_frac.y)
	var z_diff: float = abs(z - cube_frac.z)

	if x_diff > y_diff and x_diff > z_diff:
		x = -y - z
	elif y_diff > z_diff:
		y = -x - z
	else:
		z = -x - y
	return Vector3(x, y, z)
