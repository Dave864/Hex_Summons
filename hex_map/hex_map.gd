tool
class_name HexMap
extends Spatial
"""
A representation of the overall battlemap. Exposes the necessary parameters
from the child nodes that are needed for other nodes to interact with the map.
"""


const TILES = "Tiles"
const FLOOR_MESH = "FloorMesh"

var _hm_astar: HexMapAStar = null
var _floor_mesh: PlaneMesh = preload("res://hex_map/hex_map_floor.tres")
var _floor_mesh_node: MeshInstance = null
var _tiles_node: Tiles = null

onready var _map_tiles: Array = [] setget , get_map_tiles
# Reference to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


func _ready() -> void:
	_create_floor_mesh()
	_create_tiles_node()
	_map_tiles = _tiles_node.get_children()
	_hm_astar = HexMapAStar.new(
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
func highlight_player_movement(
	tile_indexes: Array,
	pc: PlayerCharacter
) -> void:
	var map_section: Array = []
	for i in tile_indexes:
		map_section.append(_map_tiles[i])
	
	var traversable_indices: Array = _hm_astar.get_traversable_tiles(
		pc.get_map_index_at(),
		pc.stats.get_movement_range(),
		map_section
	)
	
	for i in traversable_indices:
		var tile: MapTile = _map_tiles[i]
		if tile.get_current_occupant() == null:
			tile.set_selection_type(HexHighlighter.Option.RANGE)
		elif tile.get_current_occupant().name == pc.name:
			tile.set_selection_type(HexHighlighter.Option.PLAYER)
		else:
			tile.set_selection_type(HexHighlighter.Option.ALLY)


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for tile in _map_tiles:
		tile.set_selection_type(HexHighlighter.Option.NONE)


# Calculates the distance from a given start to a specified destination.
func calculate_distance(start_id: int, dest_id: int) -> int:
	return _hm_astar.get_id_path(start_id, dest_id).size()


# Determines the path to the point within an area closest to the start.
func get_point_path_toward(
	start_id: int,
	dest_id: int,
	movement_area: Array
) -> PoolVector3Array:
	var true_dest_id: int = dest_id
	var path_to_dest: PoolIntArray = _hm_astar.get_id_path(start_id, dest_id)
	
	# Determine the last point in the path that is within the movement range.
	for i in range(path_to_dest.size() - 1, 0, -1):
		if (not path_to_dest[i] in movement_area):
			true_dest_id = path_to_dest[i - 1]
	
	_hm_astar.disconnect_area(_get_tiles_from_ids(movement_area))
	var point_path: PoolVector3Array = _hm_astar.get_point_path(start_id, true_dest_id)
	_hm_astar.full_reset(_get_tiles_from_ids(movement_area))
	
	return point_path


# Determines the path to the point within a character's movement area.
func get_point_path_toward_for_character(
	character: Character,
	movement_area: Array,
	dest_id: int,
	enemies: Array,
	players: Array
) -> PoolVector3Array:
#	var movement_area: Array = _hm_astar.get_traversable_tiles(
#		character.get_map_index_at(),
#		character.stats.get_movement_range(),
#		_get_tiles_from_ids(character.stats.get_movement_area())
#	)
	var start_id: int = character.get_map_index_at()
	var true_dest_id: int = dest_id
	
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	update_astar_disabled_for_characters(
		enemies,
		character.get_type() == Constants.MapOccupants.PLAYER
	)
	update_astar_disabled_for_characters(
		players,
		character.get_type() == Constants.MapOccupants.ENEMY
	)
	# reenable destination tile to allow a path to be found when target tile 
	# has an opponent.
	_hm_astar.set_point_disabled(dest_id, false)
	
	while true:
		var path_to_dest: PoolIntArray = _hm_astar.get_id_path(start_id, dest_id)
		# Determine the last point in the path that is within the movement 
		# range. A tile occupied by an opponent is not considered within
		# movement range.
		for i in range(path_to_dest.size() - 1, 0, -1):
			var occupant: Character = _map_tiles[path_to_dest[i]].get_current_occupant()
			if (
				not path_to_dest[i] in movement_area
				or (occupant != null and occupant.get_type() != character.get_type())
			):
				true_dest_id = path_to_dest[i - 1]
		# Check if the true destination, the last tile in the available move, is
		# occupied by an ally other than itself. If so, disable that tile and 
		# recalculate the shortest path.
		var dest_occupant: Character = _map_tiles[true_dest_id].get_current_occupant()
		if (
			dest_occupant != null
			and dest_occupant.name != character.name
			and dest_occupant.get_type() == character.get_type()
		):
			_hm_astar.set_point_disabled(true_dest_id, true)
		else:
			break
	
	_hm_astar.disconnect_area(_get_tiles_from_ids(movement_area))
	var point_path: PoolVector3Array = _hm_astar.get_point_path(start_id, true_dest_id)
	_hm_astar.full_reset(_map_tiles)
	return point_path


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func update_astar_disabled_for_characters(characters: Array, disabled: bool) -> void:
	for c in characters:
		_hm_astar.set_point_disabled(c.get_map_index_at(), disabled)


# Creates a Tiles node if not already present.
func _create_tiles_node() -> void:
	if get_node_or_null(TILES) == null:
		_tiles_node = Tiles.new()
		_tiles_node.name = TILES
		add_child(_tiles_node)
		_tiles_node.set_owner(_root_node)
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


# Gets the MapTiles of the specified ids.
func _get_tiles_from_ids(ids: Array) -> Array:
	var tiles: Array = []
	for i in ids:
		tiles.append(_map_tiles[i])
	return tiles
