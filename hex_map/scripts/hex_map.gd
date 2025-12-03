class_name HexMap
extends Node3D
## A representation of the overall battlemap.
##
## Exposes the necessary parameters from the child nodes that are needed for
## other nodes to interact with the map.


## Name of the node that stores the map tiles.
const TILES: String = "Tiles"
## Name of the node that is the mesh for the floor of the map.
const FLOOR_MESH: String = "FloorMesh"
## Name of the node that tracks the highlighted and selected tiles.
const SELECTION_TRACKER: String = "SelectionTracker"
## Name of the node that holds logic for pathfinding and distance calculation.
const RANGE_FINDER: String = "RangeFinder"
## The maximum number of player characters that can be present on the map.
const MAX_PLAYER_COUNT: int = 4

## The tile indexes that player characters can start at.
@export var player_start_tiles: PackedInt32Array = [0, 1, 2, 3]
## The tile indexes that enemy characters can start at.
@export var enemy_start_tiles: PackedInt32Array = []

var selection_tracker: SelectionTracker = null
var range_finder: RangeFinder = null
var _floor_mesh: PlaneMesh = preload("res://hex_map/resources/hex_map_floor.tres")
var _floor_mesh_node: MeshInstance3D = null
var _tiles_node: Tiles = null

## The collection of all map tiles stored in the Tiles node.
@onready var _map_tiles: Array = []: get = get_map_tiles
## Reference to the scene tree root.
@onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_create_selection_tracker()
	_create_pathfinder()
	_create_floor_mesh()
	_create_tiles_node()
	_map_tiles = _tiles_node.get_children()
	_check_for_required_parameters()


## Get the number of tiles along the X axis.
func get_x_count() -> int:
	return _tiles_node.get_x_count()


## Get the number of tiles along the Z axis.
func get_z_count() -> int:
	return _tiles_node.get_z_count()


## Places the character at the tile at the given index.
func place_character_at_tile(character: Character, tile_index: int) -> void:
	var pos: Vector3 = get_tile_at(tile_index).get_character_position()
	character.position = pos


## Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array:
	return _map_tiles


## Get the map tile at the specific index.
func get_tile_at(index: int) -> MapTile:
	return _map_tiles[index]


## Checks if the given cube coordinates are within the bounds of the map.
func is_valid_cube(cube: Vector3) -> bool:
	return _tiles_node.is_valid_cube(cube)


## Creates a Tiles node if not already present.
func _create_tiles_node() -> void:
	if get_node_or_null(TILES) == null:
		_tiles_node = Tiles.new()
		_tiles_node.name = TILES
		add_child(_tiles_node)
		_tiles_node.set_owner(_root_node)
	else:
		_tiles_node = get_node(TILES)


## Create a floor mesh node and position it if not already present.
func _create_floor_mesh() -> void:
	if get_node_or_null(FLOOR_MESH) == null:
		_floor_mesh_node = MeshInstance3D.new()
		_floor_mesh_node.name = FLOOR_MESH
		_floor_mesh_node.set_mesh(_floor_mesh)
		_floor_mesh_node.mesh.resource_local_to_scene = true
		add_child(_floor_mesh_node)
		_floor_mesh_node.set_owner(_root_node)
		_floor_mesh_node.position.y = -Constants.HEX_TILE_UNIT_HEIGHT
	else:
		_floor_mesh_node = get_node(FLOOR_MESH)


## Create a selection tracker node if not already present.
func _create_selection_tracker() -> void:
	if get_node_or_null(SELECTION_TRACKER) == null:
		selection_tracker = SelectionTracker.new()
		selection_tracker.name = SELECTION_TRACKER
		add_child(selection_tracker)
		selection_tracker.set_owner(_root_node)
	else:
		selection_tracker = get_node(SELECTION_TRACKER)


## Create a pathfinder node if not already present.
func _create_pathfinder() -> void:
	if get_node_or_null(RANGE_FINDER) == null:
		range_finder = RangeFinder.new()
		range_finder.name = RANGE_FINDER
		add_child(range_finder)
		range_finder.set_owner(_root_node)
	else:
		range_finder = get_node(RANGE_FINDER)


## Check that all required parameters are set and/or valid.
func _check_for_required_parameters() -> void:
	var tile_count: int = get_z_count() * get_x_count()
	assert(
			player_start_tiles.size() >= MAX_PLAYER_COUNT,
			"Not enough tiles specified for player starting options."
	)
	assert(
			enemy_start_tiles.size() > 0,
			"No tiles specified for enemy starting options."
	)
	for tile_index in player_start_tiles:
		assert(
				tile_index < tile_count,
				"Not all player starting options are within map bounds."
		)
		assert(
				not enemy_start_tiles.has(tile_index),
				"Some player starting options are also enemy starting options."
		)
	for tile_index in enemy_start_tiles:
		assert(
				tile_index < tile_count,
				"Not all enemy starting options are within map bounds."
		)
		assert(
				not player_start_tiles.has(tile_index),
				"Some enemy starting options are also player starting options."
		)
