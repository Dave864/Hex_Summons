@tool
class_name RangeFinder
extends Node
## Contains the logic for determining area ranges and paths for a HexMap. Requires
## a reference to the map tiles.


@export var map_tiles_reference: NodePath = NodePath(""): set = set_map_tiles
@export var dist_maps: Resource = null: set = set_distance_map

var _hm_astar: HexMapAStar = null

@onready var _map_tiles: Tiles = get_node(map_tiles_reference)


## Updates the reference path for map tiles node. Is intended only for use when
## running the RangeFinder script in the inspector for the purposes of saving
## the distance map resource data.
func set_map_tiles(ref_path: NodePath) -> void:
	map_tiles_reference = ref_path
	notify_property_list_changed()
	# Allow for the _map_tiles variable to be set in the _ready function.
	if Engine.is_editor_hint() and is_node_ready():
		_map_tiles = get_node(map_tiles_reference)
		_update_distance_map()


## Updates the distance map when the reference is changed. Is intended only for
## use when running the RangeFinder script in the inspector for the purposes of
## saving the distance map resource data.
func set_distance_map(new_dist_map: Resource) -> void:
	if new_dist_map == null:
		dist_maps = null
		printerr("RangeFinder distance map needs to be defined.")
		return
	if not new_dist_map is HexMapDistances:
		printerr("Resource is not of type HexMapDistances.")
		dist_maps = null
		notify_property_list_changed()
		return
	dist_maps = new_dist_map
	# Allow for the distance_map to be updated in the _ready function.
	if Engine.is_editor_hint() and is_node_ready():
		_update_distance_map()


## Calculates the travel distance from a given start to a specified destination.
func travel_distance(start_id: int, dest_id: int) -> float:
	var d_map: DistanceMap = dist_maps.at(start_id)
	var dist: float = d_map.travel_dist_at(dest_id)
	d_map.free()
	return dist


## Calculates the travel distance from a given start to a specified destination.
func tile_distance(start_id: int, dest_id: int) -> float:
	var d_map: DistanceMap = dist_maps.at(start_id)
	var dist: float = d_map.tile_dist_at(dest_id)
	d_map.free()
	return dist


## Gets the distances from the starting point to all tiles within a given reach.
## A negative reach indicates that all map tiles should be looked at. The use_tile
## flag indicates that the tile distance should be used instead of travel distance.
func get_distance_map(start_id: int, use_tile: bool, reach: int = -1) -> DistanceMap:
	var d_map: DistanceMap = dist_maps.at(start_id)
	if reach < 0:
		return d_map
	if use_tile:
		var tile_map: DistanceMap = DistanceMap.new(
				start_id,
				d_map.map_from_tile_dist(reach)
		)
		d_map.free()
		return tile_map
	else:
		var travel_map: DistanceMap = DistanceMap.new(
				start_id,
				d_map.map_from_travel_dist(reach)
		)
		d_map.free()
		return travel_map


## Determines the point path to the point within a defined area for a character.
## This is likely not thread safe as it calls AStar's get_point_path, which is
## noted to not be thread safe.
func get_character_point_path(
	c: Character,
	dest_id: int,
	opponents: Array,
	movement_area_ids: Array
) -> PackedVector3Array:
	_hm_astar.set_area_disabled(movement_area_ids, false)
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(opponents, true)
	
	var point_path: PackedVector3Array = _hm_astar.get_point_path(
			c.map_coordinate.get_tile_index(),
			dest_id
	)
	 # Reset for future range finder operations.
	_hm_astar.set_area_disabled(movement_area_ids, true)
	return point_path


## Determines the id path to the point within a defined area for a character.
func get_character_id_path(
	c: Character,
	dest_id: int,
	opponents: Array,
	movement_area_ids: Array
) -> PackedInt64Array:
	_hm_astar.set_area_disabled(movement_area_ids, false)
	# Disable connection points of the opposite character type to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(opponents, true)
	
	var id_path: PackedInt64Array = _hm_astar.get_id_path(
			c.map_coordinate.get_tile_index(),
			dest_id
	)
	 # Reset for future range finder operations.
	_hm_astar.set_area_disabled(movement_area_ids, true)
	return id_path


## Finds the point in the area that is closest to target_id. The area is an array
## of tile ids. Returns -1 if no closest index could be found.
func get_closest_in_area(target_id: int, area_indices: Array) -> int:
	if area_indices.size() == 0:
		return -1
	var d_map: DistanceMap = dist_maps.at(target_id)
	if area_indices.size() == 1:
		return d_map.tile_ids()[0]
	var closest: Array = [-1, INF]
	for id in area_indices:
		if id == target_id:
			return target_id
		if closest[1] > d_map.tile_dist_at(id):
			closest[0] = id
			closest[1] = d_map.tile_dist_at(id)
	return closest[0]


## Determines the path id that gets closest to a destination within a distance
## limit.
func get_closest_id_path(
	start_id: int,
	dest_id: int,
	max_dist: int,
	use_tile_dist: bool = false
) -> PackedInt32Array:
	_hm_astar.set_all_disabled(false)
	if use_tile_dist:
		_hm_astar.set_cost_to_tile()
	var path_to_dest: PackedInt32Array = _hm_astar.get_closest_id_path(
			start_id,
			dest_id,
			max_dist
	)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	if use_tile_dist:
		_hm_astar.set_cost_to_travel()
	return path_to_dest


## Get the area that can be reached by a character. Takes in an array of the
## opposing characters for determining the tiles to disable.
func get_character_travesible_tiles(
	c: Character,
	opponents: Array,
	move_override: int = -1
) -> Array:
	_hm_astar.set_all_disabled(false)
	_disable_character_tiles(opponents, true)
	var move: int = (
			c.stats.get_movement_range() if move_override < 0
			else move_override
	)
	var move_distances: Dictionary = _hm_astar.get_distance_map(
			c.map_coordinate.get_tile_index(),
			false,
			move
	)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return move_distances.keys()


## Finds the closest path to a destination within a character's movement range
## where the final point is not occupied by an ally.
func get_character_closest_point_toward(
	c: Character,
	dest_id: int,
	opponents: Array,
	move_override: int = -1
) -> int:
	# Enable all connections to make sure the path can be found.
	_hm_astar.set_all_disabled(false)
	# Disable connection points of the opponents to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(opponents, true)
	# Reenable destination tile to allow a path to be found when target tile 
	# has an opponent.
	_hm_astar.set_point_disabled(dest_id, false)
	var true_dest_id: int
	var closest_path: PackedInt32Array = []
	
	var move: int = (
			c.stats.get_movement_range() if move_override < 0
			else move_override
	)
	while true:
		closest_path = _hm_astar.get_closest_id_path(
				c.map_coordinate.get_tile_index(),
				dest_id,
				move
		)
		true_dest_id = closest_path[-1]
		# Determine the last point in the path that is within the movement 
		# range. A tile occupied by an opponent is not considered within
		# movement range.
		for i in range(closest_path.size() - 1, 0, -1):
			var occupant: Character = (
					_map_tiles.get_at(closest_path[i]) \
					.occupant.get_current_occupant()
			)
			if occupant == null or occupant.get_type() == c.get_type():
				break
			true_dest_id = closest_path[i - 1]
		# Check if the found destination tile is occupied by an ally other 
		# than itself. If so, disable that tile and recalculate the shortest path.
		var dest_occupant: Character = (
				_map_tiles.get_at(true_dest_id) \
				.occupant.get_current_occupant()
		)
		if (
			dest_occupant != null
			and dest_occupant.get_instance_id() != c.get_instance_id()
			and dest_occupant.get_type() == c.get_type()
		):
			_hm_astar.set_point_disabled(true_dest_id, true)
		else:
			break
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return true_dest_id


## Determines the point within a character's movement area that is the farthest
## away from a target where the final point is not occupied by an ally.
func get_character_farthest_point_away(
	c: Character,
	target_id: int,
	opponents: Array,
	movement_indexes: Array
) -> int:
	# Enable all connections to make sure the point can be found.
	_hm_astar.set_all_disabled(false)
	# Disable connection points of the opponents to prevent character
	# from being able to move into those spaces
	_disable_character_tiles(opponents, true)
	var farthest_pt: int
	var true_farthest_pt: int
	var farthest_path: PackedInt64Array = []
	while true:
		farthest_pt = _hm_astar.get_farthest_in_area(
				target_id,
				movement_indexes
		)
		farthest_path = _hm_astar.get_id_path(
				c.map_coordinate.get_tile_index(),
				farthest_pt
		)
		true_farthest_pt = farthest_path[-1]
		# Determine the last point in the path that is within the movement 
		# range. A tile occupied by an opponent is not considered within
		# movement range.
		for i in range(farthest_path.size() - 1, 0, -1):
			var occupant: Character = (
					_map_tiles.get_at(farthest_path[i]) \
					.occupant.get_current_occupant()
			)
			if occupant == null or occupant.get_type() == c.get_type():
				break
			true_farthest_pt = farthest_path[i - 1]
		# Check if the found destination tile is occupied by an ally other 
		# than itself. If so, disable that tile and recalculate the shortest path.
		var dest_occupant: Character = (
				_map_tiles.get_at(true_farthest_pt) \
				.occupant.get_current_occupant()
		)
		if (
			dest_occupant != null
			and dest_occupant.get_instance_id() != c.get_instance_id()
			and dest_occupant.get_type() == c.get_type()
		):
			_hm_astar.set_point_disabled(true_farthest_pt, true)
		else:
			break
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()
	return true_farthest_pt
	


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	# Waiting for _map_tiles to be ready allows for RangeFinder node being
	# able to be placed in any position relative to node with map tiles data.
	# Without this, RangeFinder node would always need to be after map tiles
	# node.
	await _map_tiles.ready
	_hm_astar = HexMapAStar.new(_map_tiles.get_all(), _map_tiles.get_x_count())
	if Engine.is_editor_hint():
		_update_distance_map()


## Updates the distance map if necessary. Should only ever be called when running
## the RangeFinder script in inspector.
func _update_distance_map() -> void:
	var d_hash: int = hash(get_parent().name)
	if (
			dist_maps == null 
			or (dist_maps.map_hash == d_hash and dist_maps.d_maps.size() > 0)
	):
		return
	var d_maps: Dictionary = {}

	if _hm_astar == null:
		_hm_astar = HexMapAStar.new(
				_map_tiles.get_all(),
				_map_tiles.get_x_count()
		)
	
	# Enable all connections to make sure distance can be found.
	_hm_astar.set_all_disabled(false)
	var index: int
	for tile in _map_tiles.get_all():
		index = tile.map_coordinate.get_tile_index()
		d_maps[index] = _hm_astar.get_full_distance_map(index)
	# Reset for future range finder operations.
	_hm_astar.set_all_disabled()

	dist_maps.d_maps = d_maps
	dist_maps.map_hash = d_hash
	var err: int = ResourceSaver.save(dist_maps, dist_maps.resource_path)
	if err != OK:
		printerr("Failed to save distance maps")


## Updates the astar disabled flag for the tiles occupied by the specified characters.
func _disable_character_tiles(
	characters: Array,
	disabled: bool
) -> void:
	for c in characters:
		_hm_astar.set_point_disabled(c.map_coordinate.get_tile_index(), disabled)


## Determines which tiles are reachable in a specified map section.
func _get_traversible_ids(
	start_index: int,
	reach: int
) -> Array:
	var d_map: DistanceMap = get_distance_map(start_index, false, reach)
	return d_map.tile_ids()


## Check that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			dist_maps != null,
			"RangeFinder distance_maps has not been set."
	)
	assert(
			dist_maps is HexMapDistances,
			"RangeFinder distance_maps is not of type HexMapDistances."
	)
