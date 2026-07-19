@tool
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
## The regex pattern used to isolate acceptable tokens for the tiles inputs.
const TILE_INPUT_REGEX: String = "\\d+\\s*\\-\\s*\\d+|\\d+"

@export_group("Player Start Tiles", "player_start_tiles")
## Allows for the specification of tile indices for player start tiles using
## plain text.
@export var player_start_tiles_input: String = ""
## Triggers the processing of the player tiles input, resetting the input in the
## process.
@export_tool_button("Process Input") var player_start_tiles_process = _process_player_tiles_input
## The tile indexes that player characters can start at.
@export var player_start_tiles_values: PackedInt32Array = [0, 1, 2, 3]
@export_group("Enemy Start Tiles", "enemy_start_tiles")
## Allows for the specification of tile indices for enemy start tiles using
## plain text.
@export var enemy_start_tiles_input: String = ""
## Triggers the processing of the player tiles input, resetting the input in the
## process.
@export_tool_button("Process Input") var enemy_start_tiles_process = _process_enemy_tiles_input
## The tile indexes that enemy characters can start at.
@export var enemy_start_tiles_values: PackedInt32Array = []

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
	var direction_to_origin := pos.direction_to(Vector3.ZERO)
	var hex_dir := HexUtil.get_hex_direction(
			Vector2(direction_to_origin.x, direction_to_origin.z).normalized()
	)
	var facing_direction := Vector2.UP.rotated(-HexUtil.dir_rotation(hex_dir))
	character.character_sprite.facing_direction = facing_direction.normalized()


## Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array[MapTile]:
	return _tiles_node.get_all()


## Get the map tile at the specific index.
func get_tile_at(index: int) -> MapTile:
	return _tiles_node.get_at(index)


## Gets the map tiles of the specified ids.
func get_tiles_from_ids(tile_ids: Array[int]) -> Array[MapTile]:
	return _tiles_node.get_from_ids(tile_ids)


## Checks if the given cube coordinates are within the bounds of the map.
func is_valid_cube(cube: Vector3) -> bool:
	return _tiles_node.is_valid_cube(cube)


## Populates player_start_tiles_values with indices defined by the input string.
func _process_player_tiles_input() -> void:
	for i: int in _translate_index_regex(player_start_tiles_input):
		if not player_start_tiles_values.has(i):
			player_start_tiles_values.append(i)
	player_start_tiles_values.sort()
	player_start_tiles_input = ""
	if Engine.is_editor_hint():
		notify_property_list_changed()


## Populates enemy_start_tiles_values with indices defined by the input string.
func _process_enemy_tiles_input() -> void:
	for i: int in _translate_index_regex(enemy_start_tiles_input):
		if not enemy_start_tiles_values.has(i):
			enemy_start_tiles_values.append(i)
	enemy_start_tiles_values.sort()
	enemy_start_tiles_input = ""
	if Engine.is_editor_hint():
		notify_property_list_changed()


## Takes the provided input and extracts a list of tile indices.
func _translate_index_regex(input: String) -> Array[int]:
	var indices: Array[int] = []
	var regex := RegEx.new()
	regex.compile(TILE_INPUT_REGEX)
	var results := regex.search_all(input)
	for result_part: RegExMatch in results:
		var split := result_part.get_string().split("-", false)
		if split.size() == 1:
			indices.append(split[0].to_int())
		elif split.size() > 1:
			for i: int in range(split[0].to_int(), split[1].to_int() + 1):
				indices.append(i)
	return indices


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
	if Engine.is_editor_hint():
		return
	var tile_count: int = get_z_count() * get_x_count()
	assert(
			player_start_tiles_values.size() >= MAX_PLAYER_COUNT,
			"Not enough tiles specified for player starting options."
	)
	assert(
			enemy_start_tiles_values.size() > 0,
			"No tiles specified for enemy starting options."
	)
	for tile_index in player_start_tiles_values:
		assert(
				tile_index < tile_count and tile_index >= 0,
				"Not all player starting options are within map bounds."
		)
		assert(
				not enemy_start_tiles_values.has(tile_index),
				"Some player starting options are also enemy starting options."
		)
	for tile_index in enemy_start_tiles_values:
		assert(
				tile_index < tile_count and tile_index >= 0,
				"Not all enemy starting options are within map bounds."
		)
		assert(
				not player_start_tiles_values.has(tile_index),
				"Some enemy starting options are also player starting options."
		)
