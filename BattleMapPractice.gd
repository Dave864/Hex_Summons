extends Spatial

# Reference to the scene for the map tile
const MAP_TILE := preload("MapTile.tscn")
# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# The number of tiles along the X axis
export(int, 1, 30) var x_count = 2
# The number of tiles along the Z axis
export(int, 1, 30) var z_count = 3


# Instantiates the hex grid map tile at the specified offset
func _instantiate_tile(offset: Vector3):
	var map_tile = MAP_TILE.instance()
	$Tiles.add_child(map_tile)
	map_tile.translate_object_local(offset)


# Generates a hex grid with an odd number of tiles on the z-axis
func _generate_odd_grid():
	var map_tile_offset: Vector3
	# Keeps track of if an extra tile needs to be prepended on an odd z index
	var extra_tile_prepended: bool
	
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		extra_tile_prepended = false
		for x in x_count:
			map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
			# Add an extra tile before the start of odd rows
			if z % 2 != 0: 
				if extra_tile_prepended:
					map_tile_offset.x += HEX_EDGE_RATIO
				else:
					map_tile_offset.x -= HEX_EDGE_RATIO
					extra_tile_prepended = true
					_instantiate_tile(map_tile_offset)
					map_tile_offset.x += 2 * HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset)


# Generates a hex grid with an even number of tiles on the z-axis
func _generate_even_grid():
	var map_tile_offset: Vector3
	# Keeps track of if an extra tile needs to be prepended on an odd z index
	var extra_tile_prepended: bool
	
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		extra_tile_prepended = false
		for x in x_count:
			map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
			# Prepends an extra tile on odd rows except for the last row
			if z % 2 != 0:
				if z == (z_count - 1) or extra_tile_prepended:
					map_tile_offset.x += HEX_EDGE_RATIO
				else:
					map_tile_offset.x -= HEX_EDGE_RATIO
					extra_tile_prepended = true
					_instantiate_tile(map_tile_offset)
					map_tile_offset.x += 2 * HEX_EDGE_RATIO
			# Appends an extra tile on even rows except for the first row
			elif z != 0 and x == (x_count - 1):
				_instantiate_tile(map_tile_offset)
				map_tile_offset.x += 2 * HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset)


# Generates the hex grid map basd off of x_count and z_count
func _generate_grid():
	if z_count % 2 != 0: _generate_odd_grid()
	else: _generate_even_grid()


# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
