class_name MapTileTrackingPoint
extends TrackingPoint
## A point that moves gradually to a specified location that also tracks where
## it is on a HexMap.
##
## Is able to be moved manually and also moved to adjacent tiles should they be
## present.


## The map tile this point is hovering over.
var _current_tile: MapTile = null


## Moves this point to the adjacent tile in the given direction.
func move_to_adjacent_tile(
	direction: HexUtil.HexDirection,
	new_movement_type: TrackingPoint.MovementType
) -> void:
	var adjacent_tile: MapTile = _current_tile.get_adjacent_tile(direction)
	if adjacent_tile == null:
		return
	movement_type = new_movement_type
	_current_tile = adjacent_tile
	update_destination(_current_tile.get_character_position())


## Updates the tracked map tile.
func _on_MapTileDetector_area_entered(map_tile: Area3D) -> void:
	if not map_tile is MapTile:
		return
	_current_tile = map_tile as MapTile
