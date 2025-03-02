tool
class_name HexMap
extends Spatial
"""
A representation of the overall battlemap. Exposes the necessary parameters
from the child nodes that are needed for other nodes to interact with the map.
"""


const TILES = "Tiles"
const FLOOR_MESH = "FloorMesh"

var hm_astar: HexMapAStar = null
var _floor_mesh: PlaneMesh = preload("res://hex_map/hex_map_floor.tres")
var _floor_mesh_node: MeshInstance = null
var _tiles_node: Tiles = null

onready var _map_tiles: Array = [] setget , get_map_tiles
# Reference to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_create_floor_mesh()
	_create_tiles_node()
	hm_astar = HexMapAStar.new(
		_map_tiles,
		$Tiles.get_x_count(),
		$Tiles.get_z_count()
	)


# Get the number of tiles along the X axis.
func get_x_count() -> int:
	return $Tiles.get_x_count()


# Get the number of tiles along the Z axis.
func get_z_count() -> int:
	return $Tiles.get_z_count()


# Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array:
	return _map_tiles


# Highlight the specified tiles as movement for the given player character.
func highlight_character_movement(
	tile_indexes: Array,
	pc: PlayerCharacter
) -> void:
	for i in tile_indexes:
		var tile: MapTile = _map_tiles[i]
		if tile.get_current_occupant() == null:
			tile.set_selection_type(MapTile.SelectionType.RANGE)
		elif tile.get_current_occupant().name == pc.name:
			tile.set_selection_type(MapTile.SelectionType.PLAYER)
		else:
			tile.set_selection_type(MapTile.SelectionType.ALLY)


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for tile in _map_tiles:
		tile.set_selection_type(MapTile.SelectionType.NONE)


# Creates a Tiles node if not already present.
func _create_tiles_node() -> void:
	if get_node_or_null(TILES) == null:
		_tiles_node = Tiles.new()
		_tiles_node.name = TILES
		add_child(_tiles_node)
		_tiles_node.set_owner(_root_node)
		_map_tiles = _tiles_node.get_children()
	else:
		_tiles_node = $Tiles


# Create a floor mesh node and position it if not already present.
func _create_floor_mesh() -> void:
	if get_node_or_null(FLOOR_MESH) == null:
		_floor_mesh_node = MeshInstance.new()
		_floor_mesh_node.name = FLOOR_MESH
		_floor_mesh_node.set_mesh(_floor_mesh)
		_floor_mesh_node.mesh.resource_local_to_scene = true
		add_child(_floor_mesh_node)
		_floor_mesh_node.set_owner(_root_node)
		_floor_mesh_node.translation.y = -Constants.HEX_TILE_UNIT_HEIGHT
	else:
		_floor_mesh_node = $FloorMesh
