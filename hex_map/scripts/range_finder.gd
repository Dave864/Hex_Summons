class_name RangeFinder
extends Node
"""
Contains the logic for determining area ranges and paths for a HexMap. Requires
a reference to the map tiles.
"""


export(NodePath) var map_tiles_reference = null

var _map_tiles: Tiles = null
var _hm_astar: HexMapAStar = null


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
	
	_hm_astar.disconnect_area(_map_tiles.get_tiles_from_ids(movement_area))
	var point_path: PoolVector3Array = _hm_astar.get_point_path(
		pc.get_map_index_at(),
		dest_id
	)
	_hm_astar.full_reset(_map_tiles.get_tiles_from_ids(movement_area))
	return point_path


# Determines the path to the point within an area closest to the start.
func get_point_path_toward(
	start_id: int,
	dest_id: int,
	movement_area_ids: Array
) -> PoolVector3Array:
	var true_dest_id: int = dest_id
	var path_to_dest: PoolIntArray = _hm_astar.get_id_path(start_id, dest_id)
	
	# Determine the last point in the path that is within the movement range.
	for i in range(path_to_dest.size() - 1, 0, -1):
		if (not path_to_dest[i] in movement_area_ids):
			true_dest_id = path_to_dest[i - 1]
	
	var movement_area_tiles: Array = _map_tiles.get_tiles_from_ids(movement_area_ids)
	_hm_astar.disconnect_area(movement_area_tiles)
	var point_path: PoolVector3Array = _hm_astar.get_point_path(start_id, true_dest_id)
	_hm_astar.full_reset(movement_area_tiles)
	
	return point_path


# Determines the path to the point within a character's movement area.
func get_point_path_toward_for_character(
	c: Character,
	dest_id: int,
	enemies: Array,
	players: Array,
	movement_area_ids: Array = []
) -> PoolVector3Array:
	# Get the currently traversible tiles for the character if movement is not
	# provided.
	assert(
			movement_area_ids.size() > 0,
			"Error: No movement area provided for character %s." % c.name
	)
	var start_id: int = c.get_map_index_at()
	var true_dest_id: int = dest_id
	
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	update_astar_disabled_for_characters(
		enemies,
		c.get_type() == Constants.MapOccupants.PLAYER
	)
	update_astar_disabled_for_characters(
		players,
		c.get_type() == Constants.MapOccupants.ENEMY
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
			var occupant: Character = (
					_map_tiles.get_tile_at_index(path_to_dest[i]) \
					.occupant.get_current_occupant()
			)
			if (
				not path_to_dest[i] in movement_area_ids
				or (occupant != null and occupant.get_type() != c.get_type())
			):
				true_dest_id = path_to_dest[i - 1]
		# Check if the true destination, the last tile in the available move, is
		# occupied by an ally other than itself. If so, disable that tile and 
		# recalculate the shortest path.
		var dest_occupant: Character = (
				_map_tiles.get_tile_at_index(true_dest_id) \
				.occupant.get_current_occupant()
		)
		if (
			dest_occupant != null
			and dest_occupant.name != c.name
			and dest_occupant.get_type() == c.get_type()
		):
			_hm_astar.set_point_disabled(true_dest_id, true)
		else:
			break
	
	_hm_astar.disconnect_area(_map_tiles.get_tiles_from_ids(movement_area_ids))
	var point_path: PoolVector3Array = _hm_astar.get_point_path(start_id, true_dest_id)
	_hm_astar.full_reset(_map_tiles.get_all_tiles())
	return point_path


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func update_astar_disabled_for_characters(characters: Array, disabled: bool) -> void:
	for c in characters:
		_hm_astar.set_point_disabled(c.get_map_index_at(), disabled)


# Get the area that can be reached by a character. Takes in an array of the
# opposing characters for determining the tiles to disable.
func get_traversible_tiles_for_character(c: Character, opponents: Array) -> Array:
	update_astar_disabled_for_characters(opponents, true)
	var c_move_indexes: Array = _determine_ring_area_indexes(
		c.stats.get_movement_range(),
		c.get_map_index_at()
	)
	var t_tiles: Array = _hm_astar.get_traversable_ids(
		c.get_map_index_at(),
		c.stats.get_movement_range(),
		_map_tiles.get_tiles_from_ids(c_move_indexes)
	)
	update_astar_disabled_for_characters(opponents, false)
	return t_tiles


# Determines the tile indexes that describe a source range, excluding any defined
# dead range.
func determine_source_range_indexes(
	source_range: AreaRange,
	dead_range: AreaRange,
	emission_map_index: int,
	ignore_heights: bool
) -> Array:
	var source_indexes: Array = source_range.determine_area_indexes(
			emission_map_index,
			_map_tiles
	)
	var dead_indexes: Array = (
			dead_range.determine_area_indexes(emission_map_index, _map_tiles) 
			if dead_range != null
			else []
	)

	if not ignore_heights:
		pass

	if dead_indexes.size() == 0:
		return source_indexes
	var final_indexes: Array = []
	for index in source_indexes:
		if not dead_indexes.has(index):
			final_indexes.append(index)
	return final_indexes


# Determines the tile indexes that describe the given effect range.
func determine_effect_range_indexes(
	effect_range: AreaRange,
	emission_map_index: int,
	emission_direction: int,
	ignore_heights: bool
) -> Array:
	var effect_indexes: Array = effect_range.determine_directional_area_indexes(
			emission_map_index,
			emission_direction,
			_map_tiles
	)
	
	if not ignore_heights:
		pass

	return effect_indexes


# Called when the node enters the scene tree for the first time.
func _ready():
	_map_tiles = get_node(map_tiles_reference)
	_hm_astar = HexMapAStar.new(
		_map_tiles.get_all_tiles(),
		_map_tiles.get_x_count(),
		_map_tiles.get_z_count()
	)


# Determines which map tiles are in the ring area positioned at the start index.
# Does not account for tile heights.
# Reference: https://www.redblobgames.com/grids/hexagons/#range-coordinate
func _determine_ring_area_indexes(radius: int, start: int) -> Array:
	var tile_ids: Array = []
	var start_coord: Vector3 = (
			_map_tiles.get_tile_at_index(start) \
			.map_coordinate.get_cube_coord()
	)
	for x in range(-radius, radius + 1):
		var x_lower: int = max(-radius, -x - radius) as int
		var x_upper: int = min(radius, radius - x) as int
		for y in range(x_lower, x_upper + 1):
			var coord: Vector3 = Vector3(x, y, -x - y) + start_coord
			if _map_tiles.is_valid_cube(coord):
				var tile_id = HexUtil.cube_to_index(coord, _map_tiles.get_x_count())
				tile_ids.append(tile_id)
	return tile_ids
