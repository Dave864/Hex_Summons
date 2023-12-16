extends Spatial

# Reference to the scene for the map tile
const MAP_TILE := preload("MapTile.tscn")
# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges
const HEX_EDGE_RATIO: float = 0.87

# The number of tiles along the X axis
export(int, 1, 30) var x_count = 1
# The number of tiles along the Z axis
export(int, 3, 30) var z_count = 3


# Instantiates the hex grid map tile at the specified offset
func _instantiate_tile(offset: Vector3):
	var map_tile = MAP_TILE.instance()
	$Tiles.add_child(map_tile)
	map_tile.translate_object_local(offset)


# Generates a hex grid with an odd number of tiles on the z-axis
func _generate_odd_grid():
	var map_tile_offset: Vector3
	var x: int
	# Keeps track of if an extra tile needs to be added on an even z index
	var extra_tile_added: bool
	
	for z in z_count:
		x = 0
		extra_tile_added = false
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		while x < x_count:
			map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
			# Adjust the x offset based on the current z count
			if z % 2 != 0: 
				if extra_tile_added:
					map_tile_offset.x += HEX_EDGE_RATIO
				else:
					# Add an extra tile before the start of the row
					map_tile_offset.x -= HEX_EDGE_RATIO
					extra_tile_added = true
					x-=1
			x+=1
			_instantiate_tile(map_tile_offset)


# Generates a hex grid with an even number of tiles on the z-axis
func _generate_even_grid():
	pass

# Generates the hex grid map basd off of x_count and z_count
func _generate_grid():
	#var map_tile_offset: Vector3
	#
	# Generata a grid of hex tiles
	#for z in z_count:
	#	map_tile_offset = Vector3.ZERO
	#	map_tile_offset.z = 1.5 * z
	#	for x in x_count:
	#		map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
	#		# Adjust the x offset based on the current z count
	#		if z % 2 != 0: map_tile_offset.x += HEX_EDGE_RATIO
	#		
	#		_instantiate_tile(map_tile_offset)
	if z_count % 2 != 0: _generate_odd_grid()
	else: _generate_even_grid()


# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
