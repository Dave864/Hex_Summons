tool
class_name Tiles
extends Spatial
"""
A container for map tiles. Generates an array of map tiles with z rows and 
x columns. Positions each tile and sets up the connections between them.
"""

const MAP_TILE = "MapTile"

# The number of tiles along the X axis.
export(int, 1, 50) var x_count = 2 setget set_x_count, get_x_count
# The number of tiles along the Z axis.
export(int, 1, 50) var z_count = 3 setget set_z_count, get_z_count
# Indicates that the map tiles are to be regenerated. Workaround for creating
# an Inspector plugin.
export(bool) var regenerate = false setget regenerate_grid

var _grid_start: Vector3 = _calculate_grid_start()
var _map_tile: PackedScene = preload("res://hex_map/map_tile_node/MapTile.tscn")

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


# Update the z_count parameter and regenerate the grid.
func set_z_count(new_count: int) -> void:
	var old_z: int = z_count
	z_count = new_count
	if Engine.is_editor_hint():
		# Check if the root node is set to prevent the creation of "duplicate"
		# map tiles when loading in the game.
		if _root_node != null:
			_update_grid_start()
			_update_grid_z(old_z)


# Return the value of the z_count parameter.
func get_z_count() -> int:
	return z_count


# Update the x_count parameter and regenerate the grid.
func set_x_count(new_count: int) -> void:
	var old_x: int = x_count
	x_count = new_count
	if Engine.is_editor_hint():
		# Check if the root node is set to prevent the creation of "duplicate"
		# map tiles when loading in the game.
		if _root_node != null:
			_update_grid_start()
			_update_grid_x(old_x)


# Return the value of the x_count parameter.
func get_x_count() -> int:
	return x_count


# Get the tile at the specified index.
func get_tile_at_index(index: int) -> Node:
	return get_child(index)


# Gets the MapTiles of the specified ids.
func get_tiles_from_ids(ids: Array) -> Array:
	var tiles: Array = []
	for i in ids:
		tiles.append(get_child(i))
	return tiles


# Gets all the MapTiles.
func get_all_tiles() -> Array:
	return get_children()


# Checks if the given cube coordinates are within the bounds of the map.
func is_valid_cube(cube: Vector3) -> bool:
	var offset: Vector2 = HexUtil.cube_to_offset(cube)
	return (
		offset.x >= 0 
		and offset.x < get_x_count()
		and offset.y >= 0 
		and offset.y < get_z_count()
	)


# Removes all tiles from the tiles node and regenerates the map.
func regenerate_grid(r: bool) -> void:
	if Engine.is_editor_hint() and r:
		# Delete the tiles of the current map
		var map_tiles = get_children()
		for tile in map_tiles:
			_delete_tile(tile)
		_generate_grid()
		_set_coordinates()
		_determine_adjacencies()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initial_grid_generation()


# Creates the intial instance of the grid map.
func _initial_grid_generation() -> void:
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
func _generate_grid() -> void:
	var map_tile_offset: Vector3
	# Calculates the position for each tile relative to origin
	# and adds extra tiles as needed.
	for z in z_count:
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		for x in x_count:
			map_tile_offset.x = 2 * HexUtil.HEX_EDGE_RATIO * x
			if !_is_even(z):
				map_tile_offset.x += HexUtil.HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset)


# Instantiates the hex grid map tile at the specified offset with the HexMap
# node position being considered origin.
func _instantiate_tile(offset: Vector3) -> void:
	var tile = _map_tile.instance()
	add_child(tile)
	tile.set_owner(_root_node)
	tile.translate_object_local(offset + _grid_start)


# Assign the index values of each map tile and their corresponding cube coordinates.
func _set_coordinates() -> void:
	var index: int = 0
	for tile in get_children():
		tile.name = MAP_TILE + String(index)
		tile.map_coordinate.set_index(index)
		tile.map_coordinate.set_cube_coord(HexUtil.index_to_cube(index, get_x_count()))
		index += 1


# Goes through the Map Tiles and establishes what each one's adjacent tiles are.
#  0  / \  1
#  5 |   | 2
#  4  \ /  3
func _determine_adjacencies() -> void:
	for tile in get_children():
		var index: int = tile.map_coordinate.get_index()
		var z_place: int = int(floor(float(index) / float(x_count)))
		var x_place: int = index % x_count
		var even_z_place: bool = _is_even(z_place)
		
		var is_left: bool = x_place == 0
		var is_right: bool = x_place == (x_count - 1)
		var is_top: bool = z_place == 0
		var is_bottom: bool = z_place == (z_count - 1)
		
		# Determine which tile is adjacent to the top left edge.
		var index_0_tile: Spatial = (
			null if is_top
			else null if is_left and even_z_place
			else get_child(index - x_count - 1) if even_z_place
			else get_child(index - x_count)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.UPPER_LEFT, index_0_tile)
		
		# Determine which tile is adjacent to the top right edge.
		var index_1_tile: Spatial = (
			null if is_top
			else null if is_right and !even_z_place
			else get_child(index - x_count) if even_z_place
			else get_child(index - x_count + 1)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.UPPER_RIGHT, index_1_tile)
		
		# Determine which tile is adjacent to the center right edge.
		var index_2_tile: Spatial = null if is_right else get_child(index + 1)
		tile.set_adjacent_tile(HexUtil.HexDirection.RIGHT, index_2_tile)
		
		# Determine which tile is adjacent to the bottom right edge.
		var index_3_tile: Spatial = (
			null if is_bottom 
			else null if is_right and !even_z_place
			else get_child(index + x_count) if even_z_place
			else get_child(index + x_count + 1)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.BOTTOM_RIGHT, index_3_tile)
		
		# Determine which tile is adjacent to the bottom left edge.
		var index_4_tile: Spatial = (
			null if is_bottom
			else null if is_left and even_z_place
			else get_child(index + x_count - 1) if even_z_place
			else get_child(index + x_count)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.BOTTOM_LEFT, index_4_tile)
		
		# Determine which tile is adjacent to the center left edge.
		var index_5_tile: Spatial = null if is_left else get_child(index - 1)
		tile.set_adjacent_tile(HexUtil.HexDirection.LEFT, index_5_tile)


# Updates the set of map tiles when the x count of the map is updated
func _update_grid_x(old_x: int) -> void:
	if old_x > x_count:
		_shrink_x(old_x)
	elif old_x < x_count:
		_grow_x(old_x)
	_set_coordinates()
	_determine_adjacencies()


# Add new tiles to account for an increase in the value of x_count.
func _grow_x(old_x: int) -> void:
	var old_tiles: Array = get_children()
	var x_offset: float = (old_x - x_count) * HexUtil.HEX_EDGE_RATIO
	for t in get_children():
		t.translate_object_local(Vector3(x_offset, 0.0, 0.0))
	# Calculates the position for each tile so that the grid is centered to
	# origin and adds new tiles.
	for z in z_count:
		var offset: Vector3 = Vector3.ZERO
		offset.z = 1.5 * z
		for x in x_count:
			if x >= old_x:
				offset.x = 2 * HexUtil.HEX_EDGE_RATIO * x
				if !_is_even(z):
					offset.x += HexUtil.HEX_EDGE_RATIO
				_instantiate_tile(offset)
				# Change the child index of the new tile to match its map index.
				move_child(get_child(get_child_count() - 1), (z * x_count) + x)
			else:
				# Change the child index of old tiles to match their new
				# map index.
				var i: int = (z * old_x) + x
				move_child(old_tiles[i], (z * x_count) + x)


# Remove tiles to account for a decrease in the value of x_count.
func _shrink_x(old_x: int) -> void:
	var tiles: Array = get_children()
	for i in old_x - x_count:
		var x: int = old_x - i - 1
		for z in z_count:
			var index: int = (z * old_x) + x
			_delete_tile(tiles[index])
	# Move remaining tiles to the right
	var x_offset: float = (old_x - x_count) * HexUtil.HEX_EDGE_RATIO
	for t in get_children():
		t.translate_object_local(Vector3(x_offset, 0.0, 0.0))


# Updates the set of map tiles when the z count of the map is updated
func _update_grid_z(old_z: int) -> void:
	if old_z > z_count:
		_shrink_z(old_z)
	elif old_z < z_count:
		_grow_z(old_z)
	_set_coordinates()
	_determine_adjacencies()


# Add new tiles to account for an increase in the value of z_count.
func _grow_z(old_z: int) -> void:
	# Shift all tiles up to account for size change
	for t in get_children():
		t.translate_object_local(Vector3(0.0, 0.0, (old_z - z_count) * 0.75))
	# Calculates the position for each tile relative to origin
	# and adds extra tiles as needed.
	var map_tile_offset: Vector3
	for z in range(old_z, z_count):
		map_tile_offset = Vector3.ZERO
		map_tile_offset.z = 1.5 * z
		for x in x_count:
			map_tile_offset.x = 2 * HexUtil.HEX_EDGE_RATIO * x
			if !_is_even(z):
				map_tile_offset.x += HexUtil.HEX_EDGE_RATIO
			_instantiate_tile(map_tile_offset)


# Remove tiles to account for a decrease in the value of z_count.
func _shrink_z(old_z: int) -> void:
	var tiles: Array = get_children()
	for i in range(old_z - z_count):
		var z: int = old_z - i - 1
		for x in x_count:
			var index: int = (z * x_count) + x
			_delete_tile(tiles[index])
	# Shift all tiles up to account for size change
	for t in get_children():
		t.translate_object_local(Vector3(0.0, 0.0, (old_z - z_count) * 0.75))


# Determine the starting point so that the middle of the generated map is center
# to the HexMap node.
func _calculate_grid_start() -> Vector3:
	var origin_offset = Vector3(2 * HexUtil.HEX_EDGE_RATIO, 0.0, 1.0)
	origin_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	origin_offset.x -= (x_count + 1.5) * HexUtil.HEX_EDGE_RATIO
	return origin_offset


# Recalculate the grid start.
func _update_grid_start() -> void:
	_grid_start = _calculate_grid_start()


# Deletes the tile from the scene.
func _delete_tile(tile: MapTile) -> void:
	remove_child(tile)
	tile.set_owner(null)
	tile.queue_free()


# Check if the grid has an even number of rows.
func _is_even_grid() -> bool:
	return _is_even(z_count)


# Check if number is even.
func _is_even(number) -> bool:
	return number % 2 == 0
