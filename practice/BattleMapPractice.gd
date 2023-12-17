extends Spatial

# Reference to the scene for the map tile
const MAP_TILE := preload("MapTilePractice.tscn")
# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# The number of tiles along the X axis
export(int, 1, 30) var x_count = 2
# The number of tiles along the Z axis
export(int, 1, 30) var z_count = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Instantiates the hex grid map tile at the specified offset
func _instantiate_tile(offset: Vector3, index: int):
	var map_tile = MAP_TILE.instance()
	add_child(map_tile)
	print("index %d: %s" % [index, String(offset)])
	map_tile.translate_object_local(offset)
	map_tile.translate_object_local(_start_of_grid())


# Generates the hex grid map basd off of x_count and z_count
func _generate_grid():
	var map_tile_offset: Vector3
	var grid_start = _start_of_grid()
	var index: int = 0
	# Keeps track of if an extra tile needs to be prepended on an odd z index
	var extra_tile_prepended: bool
	
	print(String(grid_start))
	
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		extra_tile_prepended = false
		for x in x_count:
			map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
			# Generate a hex row for a grid with an even number of rows
			if _is_even_grid():
				# Prepends an extra tile on odd rows except for the last row
				if !_is_even(z):
					if z == (z_count - 1) or extra_tile_prepended:
						map_tile_offset.x += HEX_EDGE_RATIO
					else:
						map_tile_offset.x -= HEX_EDGE_RATIO
						extra_tile_prepended = true
						_instantiate_tile(map_tile_offset, index)
						map_tile_offset.x += 2 * HEX_EDGE_RATIO
						index += 1
				# Appends an extra tile on even rows except for the first row
				elif z != 0 and x == (x_count - 1):
					_instantiate_tile(map_tile_offset, index)
					map_tile_offset.x += 2 * HEX_EDGE_RATIO
					index += 1
			# Generate a hex row for a grid with an odd number of rows
			else:
				map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
				# Add an extra tile before the start of odd rows
				if !_is_even(z): 
					if extra_tile_prepended:
						map_tile_offset.x += HEX_EDGE_RATIO
					else:
						map_tile_offset.x -= HEX_EDGE_RATIO
						extra_tile_prepended = true
						_instantiate_tile(map_tile_offset, index)
						map_tile_offset.x += 2 * HEX_EDGE_RATIO
						index += 1
			_instantiate_tile(map_tile_offset, index)
			index += 1


# Determine the starting point for the middle of the generated map to be center
# to the HexMap node
func _start_of_grid() -> Vector3:
	var origin_offset = Vector3(2 * HEX_EDGE_RATIO, 0.0, 1.0)
	origin_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	if _is_even_grid():
		if z_count == 2:
			origin_offset.x -= (x_count + 1.5) * HEX_EDGE_RATIO
		else:
			origin_offset.x -= (x_count + (3.5/2.0)) * HEX_EDGE_RATIO
		origin_offset.x -= 0.0
	else:
		origin_offset.x -= (x_count + 1.0) * HEX_EDGE_RATIO
	return origin_offset


# Check if the grid has an even number of rows
func _is_even_grid() -> bool:
	return _is_even(z_count)


# Check if number is even
func _is_even(number) -> bool:
	return number % 2 == 0
