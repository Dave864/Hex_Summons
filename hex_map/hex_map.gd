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
var _highlighted_map_indexes: Array = []
var _selectable_map_indexes: Array = []

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


# Determines which map tiles are in the ring area positioned at the start index.
# Does not account for tile heights. Returns the indexes of the tiles.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-coordinate
func determine_ring_area(start: int, ra: RingArea) -> Array:
	var radius: int = ra.radius
	var tile_indices: Array = []
	var start_coord: Vector3 = _map_tiles[start].get_cub_coord()
	for x in range(-radius, radius + 1):
		var x_upper: int = max(-radius, -x - radius) as int
		var x_lower: int = min(radius, -x + radius) as int
		for y in range(x_lower, x_upper + 1):
			var coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			_add_valid_cube(tile_indices, coord)
	return tile_indices


# Determines which map tiles are in the cardinal area positioned at the start index.
# Does not account for tile heights. Returns the indexes of the tiles.
func determine_cardinal_area(start: int, ca: CardinalArea) -> Array:
	var distance: int = ca.distance
	var tile_indices: Array = []
	var start_coord: Vector3 = _map_tiles[start].get_cub_coord()
	tile_indices.append(start)
	for d in range(1, distance + 1):
		for n in range(6):
			var coord: Vector3 = HexUtil.cube_at_distance(start_coord, d, n)
			_add_valid_cube(tile_indices, coord)
	return tile_indices


# Determines which map tiles are in the cone area position at the start index,
# oriented to face the specified direction (0 - 5). Does not account for tile
# heights. Returns the indexes of the tiles.
func determine_cone_area(start: int, dir: int, ca: ConeArea) -> Array:
	var distance: int = ca.distance
	var spread: int = ca.spread
	var tile_indices: Array = []
	var start_coord: Vector3 = _map_tiles[start].get_cub_coord()
	tile_indices.append(start)
	for s in range(spread + 1):
		var cur_dir: int = dir + s
		# Keep the direction witin the bounds of 0 - 5.
		cur_dir -= 0 if cur_dir < 6 else 6
		for d in range(distance):
			var cur_coord: Vector3 = HexUtil.cube_at_distance(start_coord, cur_dir, d)
			_add_valid_cube(tile_indices, cur_coord)
			# Don't cast ray if there is no spread or if this is the last origin
			# line to add.
			if spread > 0 and s < spread:
				for i in range(d - 1):
					# The ray is cast two positions clockwise from the origin direction
					var ray_dir: int = cur_dir + 2 if cur_dir < 4 else cur_dir - 4
					var ray_coord: Vector3 = HexUtil.cube_at_distance(cur_coord, ray_dir, i)
					_add_valid_cube(tile_indices, ray_coord)
	return tile_indices


# Determines which map tiles are in the column area positioned at the start index,
# oriented to face the specified direction (0 - 5). Does not account for tile
# heights. Returns the indexes of the tiles.
func determine_column_area(start: int, dir: int, ca: ColumnArea) -> Array:
	var distance: int = ca.distance
	var spread: int = ca.spread
	var left_dir: int = dir - 1 if dir > 0 else 5
	var right_dir: int = dir + 1 if dir < 5 else 0
	var tile_indices: Array = []
	var start_coord: Vector3 = _map_tiles[start].get_cub_coord()
	tile_indices.append(start)
	for s in range(spread + 1):
		var left_coord: Vector3 = HexUtil.cube_at_distance(start_coord, left_dir, s)
		var right_coord: Vector3 = HexUtil.cube_at_distance(start_coord, right_dir, s)
		# Don't add adjacent tiles if the spread is 0.
		if s > 0:
			_add_valid_cube(tile_indices, left_coord)
			_add_valid_cube(tile_indices, right_coord)
		# Add additional tiles to fully fill in the "column" shape. Without the
		# extra tiles, the shape is a chevron.
		for d in range(distance + spread - s):
			# Only cast ray from starting point when spread is at 0.
			if s == 0:
				var ray_coord: Vector3 = HexUtil.cube_at_distance(start_coord, dir, d)
				_add_valid_cube(tile_indices, ray_coord)
			# Cast rays from both left and right points.
			else:
				var ray_coord_l: Vector3 = HexUtil.cube_at_distance(left_coord, dir, d)
				var ray_coord_r: Vector3 = HexUtil.cube_at_distance(right_coord, dir, d)
				_add_valid_cube(tile_indices, ray_coord_l)
				_add_valid_cube(tile_indices, ray_coord_r)
	return tile_indices


# Gets the map tiles of the specified area. Determines which calculation method
# based on the type of the area.
func determine_area(area: AreaRange, start: int, dir: int = -1) -> Array:
	var tile_indices: Array
	if area is RingArea:
		tile_indices = determine_ring_area(start, area)
	elif area is CardinalArea:
		tile_indices = determine_cardinal_area(start, area)
	elif area is ConeArea:
		tile_indices = determine_cone_area(start, dir, area)
	elif area is ColumnArea:
		tile_indices = determine_column_area(start, dir, area)
	else:
		tile_indices = []
	return tile_indices


# Highlight the specified tiles as movement for the given player character.
# Setting start_id to -1 indicates that we want to use the current player position
# to determine where to set the Player highlight.
func highlight_player_movement(
	tile_indexes: Array,
	pc: PlayerCharacter,
	start_id: int = -1
) -> void:
	var map_section: Array = []
	for i in tile_indexes:
		map_section.append(_map_tiles[i])
	
	var traversable_indices: Array = _hm_astar.get_traversable_tiles(
		pc.get_map_index_at() if start_id < 0 else start_id,
		pc.stats.get_movement_range(),
		map_section
	)
	
	for i in traversable_indices:
		var tile: MapTile = _map_tiles[i]
		if tile.get_current_occupant() == null:
			if i == start_id:
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.NONE)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().name == pc.name:
			if start_id < 0 or start_id == pc.get_map_index_at():
				tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			else:
				tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.get_map_index())
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
			_highlighted_map_indexes.append(tile.get_map_index())


# Highlight the specified tiles as being within the area range of an action.
func highlight_player_action_area(tile_indexes: Array, pc: PlayerCharacter) -> void:
	var map_section: Array = _get_tiles_from_ids(tile_indexes)
	
	var area_range_indices: Array = _hm_astar.get_traversable_tiles(
		pc.get_map_index_at(),
		pc.stats.get_movement_range(),
		map_section
	)
	
	for i in area_range_indices:
		var tile: MapTile = _map_tiles[i]
		if i == pc.get_map_index_at():
			tile.set_highlight_type(HexHighlighter.Option.PLAYER)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant() == null:
			tile.set_highlight_type(HexHighlighter.Option.RANGE)
			_highlighted_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_highlight_type(HexHighlighter.Option.TARGET)
			_highlighted_map_indexes.append(tile.get_map_index())
		else:
			tile.set_highlight_type(HexHighlighter.Option.ALLY)
			_highlighted_map_indexes.append(tile.get_map_index())


# Highlight the selector for the specified tiles to represent the effect area
# of an action.
func highlight_effect_area(tile_indexes: Array, ignore_heights: bool) -> void:
	var map_section: Array = _get_tiles_from_ids(tile_indexes)
	
	if !ignore_heights:
		pass
	
	for tile in map_section:
		if tile.get_current_occupant() == null:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
			_selectable_map_indexes.append(tile.get_map_index())
		elif tile.get_current_occupant().get_type() == Constants.MapOccupants.ENEMY:
			tile.set_selector_type(HexHighlighter.Option.TARGET)
			_selectable_map_indexes.append(tile.get_map_index())
		else:
			tile.set_selector_type(HexHighlighter.Option.EFFECT_RANGE)
			_selectable_map_indexes.append(tile.get_map_index())


# Clear the higlights from all tiles.
func clear_highlights() -> void:
	for i in _highlighted_map_indexes:
		_map_tiles[i].set_highlight_type(HexHighlighter.Option.NONE)
	_highlighted_map_indexes.clear()


# Clear selector highlights from all tiles.
func clear_selector_highlights() -> void:
	for i in _selectable_map_indexes:
		_map_tiles[i].set_selector_type(HexHighlighter.Option.NONE)
	_selectable_map_indexes.clear()


# Calculates the distance from a given start to a specified destination.
func calculate_distance(start_id: int, dest_id: int) -> int:
	return _hm_astar.get_id_path(start_id, dest_id).size()


# Determines the path to the point within a defined area for a player character.
func get_point_path_for_player(
	pc: PlayerCharacter,
	dest_id: int,
	enemies: Array,
	movement_area: Array
) -> PoolVector3Array:
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	update_astar_disabled_for_characters(enemies, true)
	
	_hm_astar.disconnect_area(_get_tiles_from_ids(movement_area))
	var point_path: PoolVector3Array = _hm_astar.get_point_path(
		pc.get_map_index_at(),
		dest_id
	)
	_hm_astar.full_reset(_get_tiles_from_ids(movement_area))
	return point_path


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
	dest_id: int,
	enemies: Array,
	players: Array,
	movement_area: Array = []
) -> PoolVector3Array:
	# Get the currently traversible tiles for the character if movement is not
	# provided.
	if movement_area.size() == 0:
		movement_area = _hm_astar.get_traversable_tiles(
			character.get_map_index_at(),
			character.stats.get_movement_range(),
			_get_tiles_from_ids(character.stats.get_movement_area())
		)
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


# Get the area that can be reached by a character. Takes in an array of the
# opposing characters for determining the tiles to disable.
func get_traversible_tiles_for_character(c: Character, opponents: Array) -> Array:
	update_astar_disabled_for_characters(opponents, true)
	var t_tiles: Array = _hm_astar.get_traversable_tiles(
		c.get_map_index_at(),
		c.stats.get_movement_range(),
		_get_tiles_from_ids(c.stats.get_movement_area())
	)
	var opponent_tiles: Array = []
	for oc in opponents:
		opponent_tiles.append(_map_tiles[oc.get_map_index_at()])
	# Reset connections and disabled tiles for next pathfinding calculation
	_hm_astar.reconnect_area(opponent_tiles)
	update_astar_disabled_for_characters(opponents, false)
	return t_tiles


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


# Adds the index to the provided array if the index is within the bounds of
# the hex map.
func _add_valid_index(a: Array, index: int) -> void:
	if index >= 0 and index < (get_x_count() * get_z_count()):
		a.append(index)


# Adds the index value of the provided cube coordinate if the index is within
# the bounds of the hex map.
func _add_valid_cube(a: Array, cube: Vector3) -> void:
	_add_valid_index(a, HexUtil.cube_to_index(cube, get_x_count()))
