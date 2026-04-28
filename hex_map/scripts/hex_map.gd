class_name HexMap
extends Node3D
## A representation of the overall battlemap.
##
## Exposes the necessary parameters from the child nodes that are needed for
## other nodes to interact with the map.


## Name of the node that stores the map tiles.
const TILES: String = "Tiles"
## Name of the node that holds logic for pathfinding and distance calculation.
const RANGE_FINDER: String = "RangeFinder"
## The maximum number of player characters that can be present on the map.
const MAX_PLAYER_COUNT: int = 4

## The tile indexes that player characters can start at.
@export var player_start_tiles: PackedInt32Array = [0, 1, 2, 3]
## The tile indexes that enemy characters can start at.
@export var enemy_start_tiles: PackedInt32Array = []

var range_finder: RangeFinder = null
var _tiles_node: Tiles = null

## Reference to the scene tree root.
@onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_create_pathfinder()
	_create_tiles_node()
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


## Retrieve the Tiles node that contains the map tiles.
func get_tiles_node() -> Tiles:
	return _tiles_node


## Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array[MapTile]:
	return _tiles_node.get_all()


## Get the map tile at the specific index.
func get_tile_at(index: int) -> MapTile:
	return _tiles_node.get_at(index)


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
				tile_index < tile_count and tile_index >= 0,
				"Not all player starting options are within map bounds."
		)
		assert(
				not enemy_start_tiles.has(tile_index),
				"Some player starting options are also enemy starting options."
		)
	for tile_index in enemy_start_tiles:
		assert(
				tile_index < tile_count and tile_index >= 0,
				"Not all enemy starting options are within map bounds."
		)
		assert(
				not player_start_tiles.has(tile_index),
				"Some enemy starting options are also player starting options."
		)
