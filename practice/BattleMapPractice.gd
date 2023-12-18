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
	map_tile.set_index(index)
	$Tiles.add_child(map_tile)
	map_tile.translate_object_local(offset + _start_of_grid())


# Generates the hex grid map basd off of x_count and z_count
func _generate_grid():
	var map_tile_offset: Vector3
	var index: int = 0
	
	# Calculates the position for each tile relative to origin
	# and adds extra tiles as needed
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		for x in x_count:
			map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
			if !_is_even(z):
				map_tile_offset.x += HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset, index)
			index += 1
	
	_determine_adjacencies()


# Determine the starting point for the middle of the generated map to be center
# to the HexMap node
func _start_of_grid() -> Vector3:
	var origin_offset = Vector3(2 * HEX_EDGE_RATIO, 0.0, 1.0)
	origin_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	origin_offset.x -= (x_count if z_count == 2 else (x_count + 1.5)) * HEX_EDGE_RATIO
	return origin_offset


# Check if the grid has an even number of rows
func _is_even_grid() -> bool:
	return _is_even(z_count)


# Check if number is even
func _is_even(number) -> bool:
	return number % 2 == 0


# Goes through the Map Tiles and establishes what each one's adjacent tiles are
#  0  /\  1
#  5 |  | 2
#  4  \/  3
func _determine_adjacencies():
	var index: int
	var z_place: int
	var x_place: int
	var even_z_place: bool
	# Flags to indicate if a tile is at the edge of the map grid
	var is_left: bool
	var is_right: bool
	var is_top: bool
	var is_bottom: bool
	
	print("Tiles count: " + String($Tiles.get_child_count()))
	
	for tile in $Tiles.get_children():
		index = tile.get_index()
		z_place = int(floor(index / x_count))
		x_place = index % x_count
		even_z_place = _is_even(z_place)
		
		is_left = x_place == 0
		is_right = x_place == (x_count - 1)
		is_top = z_place == 0
		is_bottom = z_place == (z_count - 1)
		
		print("\n" + tile.name + ": " + String(index))
		print("z_place: " + String(z_place) + ", x_place: " + String(x_place))
		print("top: " + String(is_top) 
			+ ", bottom: " + String(is_bottom) \
			+ ", left: " + String(is_left) \
			+ ", right: " + String(is_right))
		
		# Determine which tile is adjacent to the top left edge
		# * /\
		#  |  |
		#   \/
		
		var index_0_tile: Spatial = (
			null if is_top
			else null if is_left and even_z_place
			else $Tiles.get_child(index - x_count + 1) if even_z_place
			else $Tiles.get_child(index - x_count)
		)
		tile.call_deferred("set_adjacent_tile", 0, index_0_tile)
		
		# Determine which tile is adjacent to the top right edge
		#   /\ *
		#  |  |
		#   \/
		var index_1_tile: Spatial = (
			null if is_top
			else null if is_right and !even_z_place
			else $Tiles.get_child(index - x_count) if even_z_place
			else $Tiles.get_child(index - x_count + 1)
		)
		tile.call_deferred("set_adjacent_tile", 1, index_1_tile)
		#var index_1: int = (
		#	-100 if is_top
		#	else -100 if is_right and !even_z_place
		#	else index - x_count if even_z_place
		#	else index - x_count + 1
		#)
		#print("index_1: " + String(index_1))
		
		# Determine which tile is adjacent to the center right edge
		#   /\
		#  |  |*
		#   \/
		var index_2_tile: Spatial = null if is_right else $Tiles.get_child(index + 1)
		tile.call_deferred("set_adjacent_tile", 2, index_2_tile)
		
		# Determine which tile is adjacent to the bottom right edge
		#   /\
		#  |  |
		#   \/ *
		var index_3_tile: Spatial = (
			null if is_bottom 
			else null if is_right and !even_z_place
			else $Tiles.get_child(index + x_count) if even_z_place
			else $Tiles.get_child(index + x_count + 1)
		)
		tile.call_deferred("set_adjacent_tile", 3, index_3_tile)
		
		# Determine which tile is adjacent to the bottom left edge
		#   /\
		#  |  |
		# * \/
		var index_4_tile: Spatial = (
			null if is_bottom
			else null if is_left and even_z_place
			else $Tiles.get_child(index + x_count - 1) if even_z_place
			else $Tiles.get_child(index + x_count)
		)
		tile.call_deferred("set_adjacent_tile", 4, index_4_tile)
		
		# Determine which tile is adjacent to the center left edge
		#   /\
		# *|  |
		#   \/
		var index_5_tile: Spatial = null if is_left else $Tiles.get_child(index - 1)
		tile.call_deferred("set_adjacent_tile", 5, index_5_tile)
