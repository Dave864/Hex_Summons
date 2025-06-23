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
func calculate_distance(start_id: int, dest_id: int) -> float:
	# Enable all connections to make sure distance can be found.
	_hm_astar.set_all_disabled(false)
	var dist: float = _hm_astar.distance(start_id, dest_id)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return dist


# Determines the path to the point within a defined area for a player character.
func get_point_path_for_player(
	pc: PlayerCharacter,
	dest_id: int,
	enemies: Array,
	movement_area_ids: Array
) -> PoolVector3Array:
	_hm_astar.set_area_disabled(movement_area_ids, false)
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(enemies, true)
	
	var point_path: PoolVector3Array = _hm_astar.get_point_path(
		pc.get_map_index_at(),
		dest_id
	)
	 # Reset for future range finder operations.
	_hm_astar.set_area_disabled(movement_area_ids, true)
	return point_path


# Determines the path within a character's movement area that gets closest
# to a destination.
func get_point_path_toward_for_character(
	c: Character,
	dest_id: int,
	enemies: Array,
	players: Array,
	movement_area_ids: Array
) -> PoolVector3Array:
	assert(
			movement_area_ids.size() > 0,
			"Error: No movement area provided for character %s." % c.name
	)
	var start_id: int = c.get_map_index_at()
	# Enable all connections to make sure the path can be found.
	_hm_astar.set_all_disabled(false)
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(
		enemies,
		c.get_type() == Character.Type.PLAYER
	)
	_disable_character_tiles(
		players,
		c.get_type() == Character.Type.ENEMY
	)
	# Reenable destination tile to allow a path to be found when target tile 
	# has an opponent.
	_hm_astar.set_point_disabled(dest_id, false)
	var true_dest_id: int = _determine_closest_point_toward(
			c,
			start_id,
			dest_id,
			movement_area_ids
	)
	# Only enable the movement area
	_hm_astar.set_all_disabled()
	_hm_astar.set_area_disabled(movement_area_ids, false)
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(
		enemies,
		c.get_type() == Character.Type.PLAYER
	)
	_disable_character_tiles(
		players,
		c.get_type() == Character.Type.ENEMY
	)
	
	var point_path: PoolVector3Array = _hm_astar.get_point_path(start_id, true_dest_id)
	# Reset for future range finder operations.
	_hm_astar.set_area_disabled(movement_area_ids)
	return point_path


# Get the area that can be reached by a character. Takes in an array of the
# opposing characters for determining the tiles to disable.
func get_traversible_tiles_for_character(c: Character, opponents: Array) -> Array:
	var c_move_indexes: Array = _determine_ring_area_indexes(
		c.stats.get_movement_range(),
		c.get_map_index_at()
	)
	_hm_astar.set_area_disabled(c_move_indexes, false)
	_disable_character_tiles(opponents, true)
	var t_tiles: Array = _hm_astar.get_traversable_ids(
		c.get_map_index_at(),
		c.stats.get_movement_range(),
		c_move_indexes
	)
	# Reset for future range finder operations.
	_hm_astar.set_area_disabled(c_move_indexes)
	return t_tiles


# Determines the tile indexes that describe a source range, excluding any defined
# dead range.
func determine_source_range_indexes(
	source_range: AreaRange,
	dead_range: AreaRange,
	source_start_index: int,
	ignore_heights: bool
) -> Array:
	var source_indexes: Array = source_range.determine_area_indexes(
			source_start_index,
			_map_tiles
	)
	var dead_indexes: Array = (
			dead_range.determine_area_indexes(source_start_index, _map_tiles) 
			if dead_range != null
			else []
	)

	if not ignore_heights:
		source_indexes = _get_traversible_ids(
				source_indexes,
				source_start_index,
				source_range.get_reach()
		)

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
		return _get_traversible_ids(
				effect_indexes,
				emission_map_index,
				effect_range.get_reach()
		)
	else:
		return effect_indexes


# Called when the node enters the scene tree for the first time.
func _ready():
	_map_tiles = get_node(map_tiles_reference)
	_hm_astar = HexMapAStar.new(
			_map_tiles.get_all_tiles(),
			_map_tiles.get_x_count()
	)


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func _disable_character_tiles(
	characters: Array,
	disabled: bool
) -> void:
	for c in characters:
		_hm_astar.set_point_disabled(c.get_map_index_at(), disabled)


# Helper function for get_point_path_toward_for_character. Finds the closest point
# to a destination within a character's movement area that the character can move to.
func _determine_closest_point_toward(
	c: Character,
	start_id: int,
	dest_id: int,
	movement_area_ids: Array
) -> int:
	var true_dest_id: int = dest_id
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
			else:
				break
		# Check if the found destination tile is occupied by an ally other 
		# than itself. If so, disable that tile and recalculate the shortest path.
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
	return true_dest_id


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


# Determines which tiles are reachable in a specified map section.
func _get_traversible_ids(
	section_ids: Array,
	start_index: int,
	travel_range: int
) -> Array:
	_hm_astar.set_area_disabled(section_ids, false)
	var indexes: Array = _hm_astar.get_traversable_ids(
			start_index,
			travel_range,
			section_ids
	)
	_hm_astar.set_area_disabled(section_ids)
	return indexes
