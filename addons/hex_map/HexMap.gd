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

var _dimensions_updated: bool = false
var _root_node: Node
var _grid_start: Vector3 = _calculate_grid_start()


# Called when the node enters the scene tree for the first time.
func _ready():
	_initial_grid_generation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Creates the intial instance of the grid map
func _initial_grid_generation():
	_root_node = get_tree().edited_scene_root
	# Create the Tiles and TileMap nodes if they haven't already been instanced
	if get_child_count() == 0:
		_generate_grid()


# Determine the starting point so that the middle of the generated map is center
# to the HexMap node
func _calculate_grid_start() -> Vector3:
	var origin_offset = Vector3(2 * HEX_EDGE_RATIO, 0.0, 1.0)
	origin_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	origin_offset.x -= (x_count if z_count == 2 else (x_count + 1.5)) * HEX_EDGE_RATIO
	return origin_offset


# Recalculate the grid start
func _update_grid_start():
	_grid_start = _calculate_grid_start()


# Generates the hex grid map basd off of x_count and z_count
func _generate_grid():
	var map_tile_offset: Vector3
	var index: int = 0
	# Keeps track of if an extra tile needs to be prepended
	var extra_tile_prepended: bool
	
	# Calculates the position for each tile relative to origin
	# and adds extra tiles as needed
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		extra_tile_prepended = false
		for x in x_count:
			map_tile_offset.x = 2 * HEX_EDGE_RATIO * x
			if !_is_even(z):
				map_tile_offset.x += HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset, index)
			index += 1


# Check if the grid has an even number of rows
func _is_even_grid() -> bool:
	return _is_even(z_count)


# Check if number is even
func _is_even(number) -> bool:
	return number % 2 == 0


# Instantiates the hex grid map tile at the specified offset with the HexMap
# node position being considered origin
func _instantiate_tile(offset: Vector3, index: int):
	var map_tile = MAP_TILE.instance()
	add_child(map_tile)
	map_tile.set_owner(_root_node)
	map_tile.set_index(index)
	
	# Position the tile to the appropriate position
	map_tile.translate_object_local(offset + _grid_start)


# Goes through the Map Tiles and establishes what each one's adjacent tiles are
func _determine_adjacencies():
	pass


# Removes all tiles from the tiles node and regenerates the map
func _regenerate_grid():
	# Delete the tiles of the current map
	var map_tiles = get_children()
	for tile in map_tiles:
		remove_child(tile)
		tile.set_owner(null)
		tile.queue_free()
	
	_generate_grid()


# Update the x_count parameter and regenerate the grid
func set_x_count(new_count: int):
	x_count = new_count
	_update_grid_start()
	_regenerate_grid()


# Update the z_count parameter and regenerate the grid
func set_z_count(new_count: int):
	z_count = new_count
	_update_grid_start()
	_regenerate_grid()
