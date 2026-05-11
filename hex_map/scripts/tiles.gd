@tool
class_name Tiles
extends Node3D
## A container for map tiles.
##
## Generates an array of map tiles with z rows and x columns. Positions each
## tile and sets up the connections between them. Also provides ways to define
## a default height, and the textures the tiles can use.


const MAP_TILE := "MapTile"
## The maximum amount of different textures the tiles can have.
const MAX_TEXTURE_COUNT := 50

## The dimensions for the grid of tiles.
@export_group("Grid Dimensions")
## The number of tiles along the X axis.
@export_range(1, 50) var x_count: int = 2:
	get = get_x_count,
	set = set_x_count
## The number of tiles along the Z axis.
@export_range(1, 50) var z_count: int = 3:
	get = get_z_count,
	set = set_z_count
## The parameters for map tiles.
@export_group("Tile Details")
## The border color for tiles.
@export_color_no_alpha var border_color: Color = Color.WHITE:
	set = set_border_color
## The textures used for map tiles.
@export var map_textures: Array[Texture2D] = []:
	set = set_map_textures
## The default values for when creating new tiles.
@export_subgroup("Defaults")
## The base height that all the tiles should be set to by default.
@export_range(0, 20) var default_height: int = 0
## The index of the texture that all tiles should be set to by default.
@export_range(-1, MAX_TEXTURE_COUNT) var default_texture_index: int = 0:
	set = set_default_texture_index
## Button that resets all tiles to have the same height and texture.
@export_tool_button("Reset Tiles") var reset_button = _reset_tiles
## Flag that indicates that the heights should be updated when resetting tiles.
@export var update_heights: bool = true
## Flag that indicates that the textures should be updated when resetting tiles.
@export var update_textures: bool = true

var _grid_start: Vector3 = _calculate_grid_start()
var _map_tile: PackedScene = preload("res://hex_map/MapTile/MapTile.tscn")

## Referene to the scene tree root.
@onready var _root_node: Node = get_tree().edited_scene_root


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initial_grid_generation()


## Update the z_count parameter and regenerate the grid.
func set_z_count(new_count: int) -> void:
	var old_z: int = z_count
	z_count = new_count
	if Engine.is_editor_hint():
		# Check if the root node is set to prevent the creation of "duplicate"
		# map tiles when loading in the game.
		if _root_node != null:
			_update_grid_start()
			_update_grid_z(old_z)


## Return the value of the z_count parameter.
func get_z_count() -> int:
	return z_count


## Update the x_count parameter and regenerate the grid.
func set_x_count(new_count: int) -> void:
	var old_x: int = x_count
	x_count = new_count
	if Engine.is_editor_hint():
		# Check if the root node is set to prevent the creation of "duplicate"
		# map tiles when loading in the game.
		if _root_node != null:
			_update_grid_start()
			_update_grid_x(old_x)


## Return the value of the x_count parameter.
func get_x_count() -> int:
	return x_count


## Get the tile at the specified index.
func get_at(index: int) -> Node:
	return get_child(index)


## Gets the MapTiles of the specified ids.
func get_from_ids(ids: Array[int]) -> Array[MapTile]:
	var tiles: Array[MapTile] = []
	for i: int in ids:
		tiles.append(get_child(i) as MapTile)
	return tiles


## Gets all the MapTiles.
func get_all() -> Array[MapTile]:
	var map_tiles: Array[MapTile] = []
	map_tiles.resize(get_child_count())
	for tile_index: int in get_child_count():
		map_tiles[tile_index] = get_at(tile_index)
	return map_tiles


## Checks if the given cube coordinates are within the bounds of the map.
func is_valid_cube(cube: Vector3) -> bool:
	var offset: Vector2 = HexUtil.cube_to_offset(cube)
	return (
		offset.x >= 0 
		and offset.x < get_x_count()
		and offset.y >= 0 
		and offset.y < get_z_count()
	)


## Sets the border colors for all present tiles.
func set_border_color(new_color: Color) -> void:
	border_color = new_color
	if not is_node_ready():
		return
	for tile: MapTile in get_all():
		tile.tile_mesh.set_border_color(new_color)


## Updates the textures that the map tiles can use.
func set_map_textures(new_textures: Array[Texture2D]) -> void:
	if new_textures.size() > MAX_TEXTURE_COUNT:
		printerr("Attempting to define more than %d textures!" % MAX_TEXTURE_COUNT)
		return
	map_textures = new_textures
	if not is_node_ready():
		return
	for tile: MapTile in get_all():
		tile.set_texture_options(map_textures)


## Updates the default texture index for the tiles.
func set_default_texture_index(new_index: int) -> void:
	default_texture_index = new_index
	if new_index > map_textures.size() - 1:
		default_texture_index = map_textures.size() - 1
		push_warning(
				"There are no textures at index {0}. Setting the default to {1}" \
				.format([new_index, default_texture_index])
		)


## Goes through all created tiles and resets their heights and assigned textures.
func _reset_tiles() -> void:
	for tile: MapTile in get_all():
		if update_heights:
			tile.height = default_height
		if update_textures:
			tile.texture_index = default_texture_index


## Creates the intial instance of the grid map.
func _initial_grid_generation() -> void:
	# Create the TileMap nodes if they haven't already been instanced.
	if get_child_count() == 0:
		_generate_grid()
	_set_coordinates()
	_determine_adjacencies()
	set_map_textures(map_textures)
	set_border_color(border_color)


## Generates the hex grid map basd off of x_count and z_count.
## The orientation of the grid has the points of the tiles oriented vertically.
## The odd index rows are offset to the right.
##    / \ / \ / \
## 0 |   |   |   |
##    \ / \ / \ / \
## 1   |   |   |   |
##    / \ / \ / \ /
## 2 |   |   |   |
##    \ / \ / \ /
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


## Instantiates the hex grid map tile at the specified offset with the HexMap
## node position being considered origin.
func _instantiate_tile(offset: Vector3) -> void:
	var tile: MapTile = _map_tile.instantiate()
	add_child(tile)
	tile.set_owner(_root_node)
	tile.translate_object_local(offset + _grid_start)
	tile.height = default_height
	tile.set_texture_options(map_textures)
	tile.texture_index = default_texture_index


## Assign the index values of each map tile and their corresponding cube coordinates.
func _set_coordinates() -> void:
	var index: int = 0
	for tile in get_children():
		tile.name = MAP_TILE + String.num_int64(index)
		tile.map_coordinate.set_tile_index(index)
		tile.map_coordinate.set_cube_coord(HexUtil.index_to_cube(index, get_x_count()))
		index += 1


## Goes through the Map Tiles and establishes what each one's adjacent tiles are.
##  0  / \  1
##  5 |   | 2
##  4  \ /  3
func _determine_adjacencies() -> void:
	for tile in get_children():
		var index: int = tile.map_coordinate.get_tile_index()
		var z_place: int = int(floor(float(index) / float(x_count)))
		var x_place: int = index % x_count
		var even_z_place: bool = _is_even(z_place)
		
		var is_left: bool = x_place == 0
		var is_right: bool = x_place == (x_count - 1)
		var is_top: bool = z_place == 0
		var is_bottom: bool = z_place == (z_count - 1)
		
		# Determine which tile is adjacent to the top left edge.
		var index_0_tile: Node3D = (
			null if is_top
			else null if is_left and even_z_place
			else get_child(index - x_count - 1) if even_z_place
			else get_child(index - x_count)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.UPPER_LEFT, index_0_tile)
		
		# Determine which tile is adjacent to the top right edge.
		var index_1_tile: Node3D = (
			null if is_top
			else null if is_right and !even_z_place
			else get_child(index - x_count) if even_z_place
			else get_child(index - x_count + 1)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.UPPER_RIGHT, index_1_tile)
		
		# Determine which tile is adjacent to the center right edge.
		var index_2_tile: Node3D = null if is_right else get_child(index + 1)
		tile.set_adjacent_tile(HexUtil.HexDirection.RIGHT, index_2_tile)
		
		# Determine which tile is adjacent to the bottom right edge.
		var index_3_tile: Node3D = (
			null if is_bottom 
			else null if is_right and !even_z_place
			else get_child(index + x_count) if even_z_place
			else get_child(index + x_count + 1)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.BOTTOM_RIGHT, index_3_tile)
		
		# Determine which tile is adjacent to the bottom left edge.
		var index_4_tile: Node3D = (
			null if is_bottom
			else null if is_left and even_z_place
			else get_child(index + x_count - 1) if even_z_place
			else get_child(index + x_count)
		)
		tile.set_adjacent_tile(HexUtil.HexDirection.BOTTOM_LEFT, index_4_tile)
		
		# Determine which tile is adjacent to the center left edge.
		var index_5_tile: Node3D = null if is_left else get_child(index - 1)
		tile.set_adjacent_tile(HexUtil.HexDirection.LEFT, index_5_tile)


## Updates the set of map tiles when the x count of the map is updated
func _update_grid_x(old_x: int) -> void:
	if old_x > x_count:
		_shrink_x(old_x)
	elif old_x < x_count:
		_grow_x(old_x)
	_set_coordinates()
	_determine_adjacencies()


## Add new tiles to account for an increase in the value of x_count.
func _grow_x(old_x: int) -> void:
	var old_tiles: Array[Node] = get_children()
	var x_offset: float = (old_x - x_count) * HexUtil.HEX_EDGE_RATIO
	for t: Node in old_tiles:
		t.translate_object_local(Vector3(x_offset, 0.0, 0.0))
	# Calculates the position for each tile so that the grid is centered to
	# origin and adds new tiles.
	for z: int in z_count:
		var offset: Vector3 = Vector3.ZERO
		offset.z = 1.5 * z
		for x: int in x_count:
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


## Remove tiles to account for a decrease in the value of x_count.
func _shrink_x(old_x: int) -> void:
	var tiles: Array[Node] = get_children()
	for i in old_x - x_count:
		var x: int = old_x - i - 1
		for z: int in z_count:
			var index: int = (z * old_x) + x
			_delete_tile(tiles[index])
	# Move remaining tiles to the right
	var x_offset: float = (old_x - x_count) * HexUtil.HEX_EDGE_RATIO
	for t: Node in get_children():
		t.translate_object_local(Vector3(x_offset, 0.0, 0.0))


## Updates the set of map tiles when the z count of the map is updated
func _update_grid_z(old_z: int) -> void:
	if old_z > z_count:
		_shrink_z(old_z)
	elif old_z < z_count:
		_grow_z(old_z)
	_set_coordinates()
	_determine_adjacencies()


## Add new tiles to account for an increase in the value of z_count.
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


## Remove tiles to account for a decrease in the value of z_count.
func _shrink_z(old_z: int) -> void:
	var tiles: Array[Node] = get_children()
	for i: int in range(old_z - z_count):
		var z: int = old_z - i - 1
		for x in x_count:
			var index: int = (z * x_count) + x
			_delete_tile(tiles[index])
	# Shift all tiles up to account for size change
	for t in get_children():
		t.translate_object_local(Vector3(0.0, 0.0, (old_z - z_count) * 0.75))


## Determine the starting point so that the middle of the generated map is center
## to the HexMap node.
func _calculate_grid_start() -> Vector3:
	var origin_offset = Vector3(2 * HexUtil.HEX_EDGE_RATIO, 0.0, 1.0)
	origin_offset.z -= ((3.0 * z_count) + 1.0) / 4.0
	origin_offset.x -= (x_count + 1.5) * HexUtil.HEX_EDGE_RATIO
	return origin_offset


## Recalculate the grid start.
func _update_grid_start() -> void:
	_grid_start = _calculate_grid_start()


## Deletes the tile from the scene.
func _delete_tile(tile: MapTile) -> void:
	remove_child(tile)
	tile.set_owner(null)
	tile.queue_free()


## Check if the grid has an even number of rows.
func _is_even_grid() -> bool:
	return _is_even(z_count)


## Check if number is even.
func _is_even(number) -> bool:
	return number % 2 == 0
