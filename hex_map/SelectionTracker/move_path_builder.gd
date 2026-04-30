class_name MovePathBuilder
extends Object
## Builder that allows for the creation of a custom movement path within a given
## area of map tiles.
##
## Records a movement path. Movement path is created based on a selected destination.
## If a path has already been made, the path to the new destination is determined
## using the end of the previous path, adding on to the original. A completely new
## path is created if the result exceeds the specified movement range. Requires
## a selection of interconnected MapTiles, movement range, and start tile.


## The tile index of the starting tile.
var _move_origin: int
## The movement limit for the path.
var _move_range: int
## The pathfinder for the movement area.
var _move_area_astar: HexMapAStar 
## The current index path.
var _current_id_path: PackedInt64Array
## The index of the end of the path.
var _path_end_index: int
## The distance traveled by the current path.
var _current_distance: float


## Initializes the object.
func _init() -> void:
	_move_origin = -1
	_move_range = -1
	_move_area_astar = null
	_current_id_path = []
	_path_end_index = 0
	_current_distance = 0.0


## Updates the details for the movement area.
func update_move_area_details(
	new_origin: int,
	new_move_range: int,
	new_move_area: Array[MapTile],
	grid_x_count: int
) -> void:
	_move_origin = new_origin
	_move_range = new_move_range
	_current_id_path.clear()
	_current_id_path.resize(_move_range + 1)
	_current_id_path.fill(-1)
	_path_end_index = 0
	_current_distance = 0.0
	_update_move_area(new_move_area, grid_x_count)


## Returns the path as an array of tile ids.
func get_id_path() -> PackedInt64Array:
	return _current_id_path


## Returns the path as an array of points (Vector3).
func get_point_path() -> PackedVector3Array:
	var point_path: PackedVector3Array
	for i: int in _current_id_path.size():
		if _current_id_path[i] < 0:
			break
		point_path.append(_move_area_astar.get_point_position(_current_id_path[i]))
	return point_path


## Updates the current path to travel to the new destination. The path is not
## updated if the destination is out of bounds or on an impassable tile.
func create_path_to_id(destination_id: int) -> void:
	if destination_id < 0:
		printerr("Destination is not valid.")
		return
	if _path_end_index == 0:
		_create_path_from_origin(destination_id)
		return
	var path_index := _current_id_path.find(destination_id)
	if path_index >= 0:
		_shrink_path_end(path_index)
		return
	var start_id: int = _current_id_path[_path_end_index]
	var new_path_segment := _move_area_astar.get_id_path(start_id, destination_id)
	if new_path_segment.size() == 0:
		printerr("New path segment could not be created.")
		return
	_add_segment_to_current_path(new_path_segment)


## Creates a new pathfinder object for the given movement area.
func _update_move_area(new_move_area: Array[MapTile], grid_x_count: int) -> void:
	_move_area_astar = HexMapAStar.new(new_move_area, grid_x_count)
	# All tiles disabled by default, so they need to be enabled.
	_move_area_astar.set_all_disabled(false)


## Updates the recorded end of the path, removing old path ids that are no longer
## in the new path.
func _shrink_path_end(new_path_end: int) -> void:
	for i: int in range(new_path_end + 1, _current_id_path.size()):
		var id := _current_id_path[i]
		if id >= 0:
			_move_area_astar.set_point_disabled(id, false)
		_current_id_path[i] = -1
	_path_end_index = new_path_end
	_move_area_astar.set_point_disabled(_current_id_path[_path_end_index], false)
	_current_distance = _move_area_astar.travel_distance_for_id_path(
			_current_id_path.slice(0, _path_end_index + 1)
	)


## Sets the current path to be from move origin to destination.
func _create_path_from_origin(destination_id: int) -> void:
	# Reenable points from old path.
	_set_path_disabled(false)
	var path := _move_area_astar.get_id_path(
			_move_origin, 
			destination_id
	)
	for i: int in _current_id_path.size():
		_current_id_path[i] = path[i] if i < path.size() else -1
	_path_end_index = path.size() - 1
	_set_path_disabled(true)
	_current_distance = _move_area_astar.travel_distance_for_id_path(path)


## Adds a new path segment to the end of the current path. The current path is
## not updated if the start of the segment is not the same as the end of the
## path. If the size of the current path would exceed the movement range,
## it is set to be the path from movement origin to the end of the new segment. 
func _add_segment_to_current_path(new_path_segment: PackedInt64Array) -> void:
	if new_path_segment[0] != _current_id_path[_path_end_index]:
		printerr("Start of new segment not aligned with end of current path.")
		return
	var new_distance := (
		_move_area_astar.travel_distance_for_id_path(new_path_segment) \
		+ _current_distance
	)
	if new_distance > _move_range:
		_create_path_from_origin(new_path_segment[-1])
		return
	_current_distance = new_distance
	for i: int in range(1, new_path_segment.size()):
		_path_end_index += 1
		_current_id_path[_path_end_index] = new_path_segment[i]
	_move_area_astar.set_area_disabled(new_path_segment, true)
	# Enable last point to allow for new segments to be determined.
	_move_area_astar.set_point_disabled(new_path_segment[-1], false)


## Sets the disable flag for the current path.
func _set_path_disabled(disable: bool) -> void:
	for i: int in _path_end_index:
		var id := _current_id_path[i]
		if id >= 0:
			_move_area_astar.set_point_disabled(id, disable)
	# Enable the last point in the path to allow for new segments to be determined.
	var end_id := _current_id_path[_path_end_index]
	if end_id >= 0:
		_move_area_astar.set_point_disabled(end_id, false)
