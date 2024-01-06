tool
class_name Tiles
extends Spatial
"""
A container for map tiles. Generates an array of map tiles with z rows and 
x columns. Positions each tile and sets up the connections between them.
"""


<<<<<<< HEAD
# The ratio between 
# the distance from the center of a hexagon to one of its vertices and 
# the distance from the center of a hexagon to the midpoint of one of its edges.
const HEX_EDGE_RATIO: float = sqrt(3.0) / 2.0
=======
# Reference to the scene for the map tile.
const MAP_TILE: PackedScene = preload(
	"res://" + 
	"hex_map/" +
	"map_tile_node/" +
	"MapTile.tscn"
)
>>>>>>> 8116b3d (character-technique: Moved HEX_EDGE_RATIO to Constants util script. Adjusted max values for core_stats. Refactored comments.)

# The number of tiles along the X axis.
export(int, 1, 50) var x_count = 2 setget set_x_count, get_x_count
# The number of tiles along the Z axis.
export(int, 1, 50) var z_count = 3 setget set_z_count, get_z_count

var _grid_start: Vector3 = _calculate_grid_start()
var _map_tile: PackedScene = preload("res://hex_map/map_tile_node/MapTile.tscn")

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


# Called when the node enters the scene tree for the first time.
func _ready():
	_initial_grid_generation()


# Creates the intial instance of the grid map.
func _initial_grid_generation():
	# Create the TileMap nodes if they haven't already been instanced.
	if get_child_count() == 0:
		_generate_grid()
	_set_coordinates()
	_determine_adjacencies()


# Generates the hex grid map basd off of x_count and z_count.
# The orientation of the grid has the points of the tiles oriented vertically.
# The odd index rows are offset to the right.
#    / \ / \ / \
# 0 |   |   |   |
#    \ / \ / \ / \
# 1   |   |   |   |
#    / \ / \ / \ /
# 2 |   |   |   |
#    \ / \ / \ /
func _generate_grid():
	var map_tile_offset: Vector3
	
	# Calculates the position for each tile relative to origin
	# and adds extra tiles as needed.
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		for x in x_count:
			map_tile_offset.x = 2 * Constants.HEX_EDGE_RATIO * x
			if !_is_even(z):
				map_tile_offset.x += Constants.HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset)


# Determine the starting point so that the middle of the generated map is center
# to the HexMap node.
func _calculate_grid_start() -> Vector3:
	var origin_offset = Vector3(2 * Constants.HEX_EDGE_RATIO, 0.0, 1.0)
	origin_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	origin_offset.x -= (
		float(x_count) if float(z_count) == 2.0
		else (x_count + 1.5)
	) * Constants.HEX_EDGE_RATIO
	return origin_offset


# Instantiates the hex grid map tile at the specified offset with the HexMap
# node position being considered origin.
func _instantiate_tile(offset: Vector3):
	var tile = _map_tile.instance()
	add_child(tile)
	tile.set_owner(_root_node)
	tile.translate_object_local(offset + _grid_start)


# Assign the index values of each map tile and their corresponding cube coordinates.
func _set_coordinates():
	var index: int = 0
	for tile in get_children():
		tile.set_index(index)
		tile.set_cube_coord(index_to_cube(index))
		index += 1


# Goes through the Map Tiles and establishes what each one's adjacent tiles are.
#  0  / \  1
#  5 |   | 2
#  4  \ /  3
func _determine_adjacencies():
	var index: int
	var z_place: int
	var x_place: int
	var even_z_place: bool
	# Flags to indicate if a tile is at the edge of the map grid.
	var is_left: bool
	var is_right: bool
	var is_top: bool
	var is_bottom: bool
	
	for tile in get_children():
		index = tile.get_index()
		z_place = int(floor(float(index) / float(x_count)))
		x_place = index % x_count
		even_z_place = _is_even(z_place)
		
		is_left = x_place == 0
		is_right = x_place == (x_count - 1)
		is_top = z_place == 0
		is_bottom = z_place == (z_count - 1)
		
		# Determine which tile is adjacent to the top left edge.
		# * / \
		#  |   |
		#   \ /
		var index_0_tile: Spatial = (
			null if is_top
			else null if is_left and even_z_place
			else get_child(index - x_count - 1) if even_z_place
			else get_child(index - x_count)
		)
		tile.set_adjacent_tile(0, index_0_tile)
		
		# Determine which tile is adjacent to the top right edge.
		#   / \ *
		#  |   |
		#   \ /
		var index_1_tile: Spatial = (
			null if is_top
			else null if is_right and !even_z_place
			else get_child(index - x_count) if even_z_place
			else get_child(index - x_count + 1)
		)
		tile.set_adjacent_tile(1, index_1_tile)
		
		# Determine which tile is adjacent to the center right edge.
		#   / \
		#  |   |*
		#   \ /
		var index_2_tile: Spatial = null if is_right else get_child(index + 1)
		tile.set_adjacent_tile(2, index_2_tile)
		
		# Determine which tile is adjacent to the bottom right edge.
		#   / \
		#  |   |
		#   \ / *
		var index_3_tile: Spatial = (
			null if is_bottom 
			else null if is_right and !even_z_place
			else get_child(index + x_count) if even_z_place
			else get_child(index + x_count + 1)
		)
		tile.set_adjacent_tile(3, index_3_tile)
		
		# Determine which tile is adjacent to the bottom left edge.
		#   / \
		#  |   |
		# * \ /
		var index_4_tile: Spatial = (
			null if is_bottom
			else null if is_left and even_z_place
			else get_child(index + x_count - 1) if even_z_place
			else get_child(index + x_count)
		)
		tile.set_adjacent_tile(4, index_4_tile)
		
		# Determine which tile is adjacent to the center left edge.
		#   / \
		# *|   |
		#   \ /
		var index_5_tile: Spatial = null if is_left else get_child(index - 1)
		tile.set_adjacent_tile(5, index_5_tile)


# Removes all tiles from the tiles node and regenerates the map.
func _regenerate_grid():
	# Delete the tiles of the current map
	var map_tiles = get_children()
	for tile in map_tiles:
		remove_child(tile)
		tile.set_owner(null)
		tile.queue_free()
	
	_generate_grid()
	_set_coordinates()
	_determine_adjacencies()


# Recalculate the grid start.
func _update_grid_start():
	_grid_start = _calculate_grid_start()


# Check if the grid has an even number of rows.
func _is_even_grid() -> bool:
	return _is_even(z_count)


# Check if number is even.
func _is_even(number) -> bool:
	return number % 2 == 0


# Update the z_count parameter and regenerate the grid.
func set_z_count(new_count: int):
	z_count = new_count
	# Check if the root node is set to prevent the creation of "duplicate"
	# map tiles when loading in the game.
	if _root_node != null:
		_update_grid_start()
		_regenerate_grid()


# Return the value of the z_count parameter.
func get_z_count() -> int:
	return z_count


# Update the x_count parameter and regenerate the grid.
func set_x_count(new_count: int):
	x_count = new_count
	# Check if the root node is set to prevent the creation of "duplicate"
	# map tiles when loading in the game.
	if _root_node != null:
		_update_grid_start()
		_regenerate_grid()


# Return the value of the x_count parameter.
func get_x_count() -> int:
	return x_count


# Get the tile at the specified index.
func get_tile_at_index(index: int) -> Node:
	return get_child(index)


# Converts the index value to its corresponding cube cooridinate.
func index_to_cube(index: int) -> Vector3:
	var z_pos: int = int(floor(float(index) / float(x_count)))
	var x_pos: int = index % x_count
	var x_cube: int = int(x_pos - (z_pos - (z_pos & 1)) / 2.0)
	var y_cube: int = z_pos
	return Vector3(x_cube, y_cube, -x_cube - y_cube)
