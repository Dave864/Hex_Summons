tool
class_name HexMap
extends Spatial
"""
A representation of the overall battlemap. Exposes the necessary parameters
from the child nodes that are needed for other nodes to interact with the map.
"""


const TILES: String = "Tiles"
const FLOOR_MESH: String = "FloorMesh"
const SELECTION_TRACKER: String = "SelectionTracker"
const RANGE_FINDER: String = "RangeFinder"

var selection_tracker: SelectionTracker = null
var range_finder: RangeFinder = null
var _floor_mesh: PlaneMesh = preload("res://hex_map/resources/hex_map_floor.tres")
var _floor_mesh_node: MeshInstance = null
var _tiles_node: Tiles = null

onready var _map_tiles: Array = [] setget , get_map_tiles
# Reference to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_create_selection_tracker()
	_create_pathfinder()
	_create_floor_mesh()
	_create_tiles_node()
	_map_tiles = _tiles_node.get_children()


# Get the number of tiles along the X axis.
func get_x_count() -> int:
	return _tiles_node.get_x_count()


# Get the number of tiles along the Z axis.
func get_z_count() -> int:
	return _tiles_node.get_z_count()


# Retrieve the map tiles of this hex map.
func get_map_tiles() -> Array:
	return _map_tiles


# Creates a Tiles node if not already present.
func _create_tiles_node() -> void:
	if get_node_or_null(TILES) == null:
		_tiles_node = Tiles.new()
		_tiles_node.name = TILES
		add_child(_tiles_node)
		_tiles_node.set_owner(_root_node)
	else:
		_tiles_node = get_node(TILES)


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
		_floor_mesh_node = get_node(FLOOR_MESH)


# Create a selection tracker node if not already present.
func _create_selection_tracker() -> void:
	if get_node_or_null(SELECTION_TRACKER) == null:
		selection_tracker = SelectionTracker.new()
		selection_tracker.name = SELECTION_TRACKER
		add_child(selection_tracker)
		selection_tracker.set_owner(_root_node)
	else:
		selection_tracker = get_node(SELECTION_TRACKER)


# Create a pathfinder node if not already present.
func _create_pathfinder() -> void:
	if get_node_or_null(RANGE_FINDER) == null:
		range_finder = RangeFinder.new()
		range_finder.name = RANGE_FINDER
		add_child(range_finder)
		range_finder.set_owner(_root_node)
	else:
		range_finder = get_node(RANGE_FINDER)
