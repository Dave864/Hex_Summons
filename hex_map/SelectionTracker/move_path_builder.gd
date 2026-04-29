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


## Initializes the object.
func _init() -> void:
	_move_origin = -1
	_move_range = -1
	_move_area_astar = null
	_current_id_path = []
	_path_end_index = 0


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
	var path_index := _current_id_path.find(destination_id)
	if path_index > 0:
		_update_path_end(path_index)
		return
	var start_id: int = (
		_move_origin if _path_end_index == 0
		else _current_id_path[_path_end_index]
	)
	var new_path_segment := _move_area_astar.get_id_path(start_id, destination_id)
	if new_path_segment.size() == 0:
		printerr("Destination is not within movement area.")
		return
	_add_segment_to_current_path(new_path_segment)


## Creates a new pathfinder object for the given movement area.
func _update_move_area(new_move_area: Array[MapTile], grid_x_count: int) -> void:
	if _move_area_astar != null:
		_move_area_astar.free()
	_move_area_astar = HexMapAStar.new(new_move_area, grid_x_count)


## Updates the recorded end of the path, removing old path ids if the new path
## is shorter.
func _update_path_end(new_path_end: int) -> void:
	if new_path_end < _path_end_index:
		for i: int in range(new_path_end + 1, _current_id_path.size()):
			_move_area_astar.set_point_disabled(_current_id_path[i], false)
			_current_id_path[i] = -1
	_path_end_index = new_path_end


## Sets the current path to be from move origin to destination.
func _create_path_from_origin(destination_id: int) -> void:
	var path := _move_area_astar.get_id_path(
			_move_origin, 
			destination_id
	)
	for i: int in _current_id_path.size():
		_current_id_path[i] = path[i] if i < path.size() else -1


## Adds a new path segment to the end of the current path. The current path is
## not updated if the start of the segment is not the same as the end of the
## path. If the size of the current path would exceed the movement range,
## it is set to be the path from movement origin to the end of the new segment. 
func _add_segment_to_current_path(new_path_segment: PackedInt64Array) -> void:
	if new_path_segment[0] != _current_id_path[_path_end_index]:
		printerr("Start of new segment not aligned with end of current path.")
		return
	if _path_end_index + new_path_segment.size() - 1 > _move_range:
		_create_path_from_origin(new_path_segment[-1])
		return
	for i: int in range(1, new_path_segment.size()):
		_path_end_index += 1
		_current_id_path[_path_end_index] = new_path_segment[i]
