class_name RangeFinder
extends Node
"""
Contains the logic for determining area ranges and paths for a HexMap. Requires
a reference to the map tiles.
"""


export(NodePath) var map_tiles_reference = null

var _map_tiles: Tiles = null
var _hm_astar: HexMapAStar = null


# Calculates the travel distance from a given start to a specified destination.
func travel_distance(start_id: int, dest_id: int) -> float:
	# Enable all connections to make sure distance can be found.
	_hm_astar.set_all_disabled(false)
	var dist: float = _hm_astar.travel_distance(start_id, dest_id)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return dist


# Calculates the travel distance from a given start to a specified destination.
func tile_distance(start_id: int, dest_id: int) -> float:
	# Enable all connections to make sure distance can be found.
	_hm_astar.set_all_disabled(false)
	var dist: float = _hm_astar.tile_distance(start_id, dest_id)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return dist


# Gets the distances from the starting point to all tiles within a given reach.
# A negative reach indicates that all map tiles should be looked at. Specifying
# get_all determines whether to include tiles that are outside of reach of not.
# Each entry has the travel distance and tile distance stored in an array.
# Travel distance is at index 0, tile distance is at index 1.
func get_distance_map(start_id: int, get_all: bool, reach: int = -1) -> Dictionary:
	# Enable all connections to make sure distance can be found.
	_hm_astar.set_all_disabled(false)
	var d_map: Dictionary = _hm_astar.get_distance_map(start_id, get_all, reach)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return d_map


# Determines the path to the point within a defined area for a player character.
func get_player_point_path(
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
		pc.map_coordinate.get_index(),
		dest_id
	)
	 # Reset for future range finder operations.
	_hm_astar.set_area_disabled(movement_area_ids, true)
	return point_path


# Finds the point in the area that is closest to start. The area is a dicitonary
# whose keys are the map tile ids and values are the various distances to the
# tiles from some point, which may not be the same as start.
func get_closest_in_area(start_id: int, area_d_map: Dictionary) -> int:
	# Enable all connections to make sure the closest point can be found.
	_hm_astar.set_all_disabled(false)
	var target_id: int = _hm_astar.get_closest_in_area(start_id, area_d_map)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return target_id


# Determines the tile id within a given area that is closest to a destination.
func get_closest_index_toward(
	start_id: int,
	dest_id: int,
	movement_area_ids: Array
) -> int:
	_hm_astar.set_all_disabled(false)
	var path_to_dest: PoolIntArray = _hm_astar.get_id_path(start_id, dest_id)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	
	var closest_id: int = dest_id
	for i in range(path_to_dest.size() - 1, 0, -1):
		if not path_to_dest[i] in movement_area_ids:
			closest_id = path_to_dest[i - 1]
		else:
			break
	return closest_id


# Determines the path within a character's movement area that gets closest
# to a destination.
func get_character_point_path_toward(
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
	var start_id: int = c.map_coordinate.get_index()
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
func get_character_travesible_tiles(c: Character, opponents: Array) -> Array:
	_hm_astar.set_all_disabled(false)
	_disable_character_tiles(opponents, true)
	var move_distances: Dictionary = _hm_astar.get_distance_map(
			c.map_coordinate.get_index(),
			false,
			c.stats.get_movement_range()
	)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return move_distances.keys()


# Called when the node enters the scene tree for the first time.
func _ready():
	_map_tiles = get_node(map_tiles_reference)
	_hm_astar = HexMapAStar.new(
			_map_tiles.get_all(),
			_map_tiles.get_x_count()
	)


# Updates the astar disabled flag for the tiles occupied by the specified characters.
func _disable_character_tiles(
	characters: Array,
	disabled: bool
) -> void:
	for c in characters:
		_hm_astar.set_point_disabled(c.map_coordinate.get_index(), disabled)


# Helper function for get_character_point_path_toward. Finds the closest point
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
					_map_tiles.get_at(path_to_dest[i]) \
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
				_map_tiles.get_at(true_dest_id) \
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


# Determines which tiles are reachable in a specified map section.
func _get_traversible_ids(
	section_ids: Array,
	start_index: int,
	reach: int
) -> Array:
	_hm_astar.set_area_disabled(section_ids, false)
	var distances: Dictionary = _hm_astar.get_distance_map(start_index, false, reach)
	# Reset for future range finder operations.
	_hm_astar.set_area_disabled(section_ids)
	return distances.keys()
