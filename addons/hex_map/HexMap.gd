tool
extends Spatial


# Reference to the scene for the map tile
const MAP_TILE := preload("map_tile/MapTile.tscn")
# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0

# The number of tiles along the X axis
export(int, 1, 30) var x_count = 2 setget set_x_count
# The number of tiles along the Z axis
export(int, 1, 30) var z_count = 3 setget set_z_count

var _tiles_node = Spatial.new()
var _dimensions_updated: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_instantiate_tiles_node()
	_generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Generates the hex grid map basd off of x_count and z_count
func _generate_grid():
	var map_tile_offset: Vector3
	# Keeps track of if an extra tile needs to be prepended on an odd z index
	var extra_tile_prepended: bool
	
	_center_grid()
	
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
						_instantiate_tile(map_tile_offset)
						map_tile_offset.x += 2 * HEX_EDGE_RATIO
				# Appends an extra tile on even rows except for the first row
				elif z != 0 and x == (x_count - 1):
					_instantiate_tile(map_tile_offset)
					map_tile_offset.x += 2 * HEX_EDGE_RATIO
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
						_instantiate_tile(map_tile_offset)
						map_tile_offset.x += 2 * HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset)


# Move the map grid so its center is at the transformation of the base node
func _center_grid():
	var tiles_offset = Vector3(2 * HEX_EDGE_RATIO, 0.0, 1.0)
	tiles_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	if _is_even_grid():
		if z_count == 2:
			tiles_offset.x -= (x_count + 1.5) * HEX_EDGE_RATIO
		else:
			tiles_offset.x -= (x_count + (3.5/2.0)) * HEX_EDGE_RATIO
		tiles_offset.x -= 0.0
	else:
		tiles_offset.x -= (x_count + 1.0) * HEX_EDGE_RATIO
	
	_tiles_node.translation = tiles_offset


# Check if the grid has an even number of rows
func _is_even_grid() -> bool:
	return _is_even(z_count)


# Check if number is even
func _is_even(number) -> bool:
	return number % 2 == 0


# Instantiates the hex grid map tile at the specified offset
func _instantiate_tile(offset: Vector3):
	var map_tile = MAP_TILE.instance()
	_tiles_node.add_child(map_tile)
	if get_owner() != null:
		map_tile.set_owner(get_tree().edited_scene_root)
	map_tile.translate_object_local(offset)


# Instantiates the node that will keep track of the map tiles
func _instantiate_tiles_node():
	_tiles_node.name = "Tiles"
	add_child(_tiles_node)
	if get_owner() != null:
		_tiles_node.set_owner(get_tree().edited_scene_root)


# Removes all tiles from the tiles node and regenerates the map
func _regenerate_grid():
	# Delete the tiles of the current map
	var map_tiles = _tiles_node.get_children()
	for tile in map_tiles:
		_tiles_node.remove_child(tile)
		tile.set_owner(null)
		tile.queue_free()
	
	_generate_grid()


# Update the x_count parameter and regenerate the grid
func set_x_count(new_count: int):
	x_count = new_count
	_regenerate_grid()


# Update the z_count parameter and regenerate the grid
func set_z_count(new_count: int):
	z_count = new_count
	_regenerate_grid()
