class_name TravelPointZones
extends Node3D
## Provides access to all travel points defined in the child TravelPoints nodes.
##
## A container node for TravelPoints nodes. Allows for the defining of multiple
## travel point areas that can be used to determine travel destinations.


## The various travel point zones tracked by this node.
var _zones: Array[TravelPoints] = []


## Gets references to all tracked TravelPoints.
func _ready() -> void:
	for zone: Node in get_children():
		if zone is TravelPoints:
			_zones.append(zone)
	if _zones.size() == 0:
		printerr("TravelPointsZones does not have any TravelPoints nodes.")


## Gets a random travel point in global space. Returns an infinite vector if
## no valid point is found.
func get_a_global_point() -> Vector3:
	if _zones.size() == 0:
		printerr(
				"Attempting to obtain random point from "
				+ "non-existant TravelPoints"
		)
		return Vector3.INF
	return _get_zone().get_a_global_point()


## Gets a random travel point in global space that is in a specific range of a
## reference point.
func get_a_global_point_in(max_range: float, ref_point: Vector3) -> Vector3:
	if _zones.size() == 0:
		printerr(
				"Attempting to obtain random point from "
				+ "non-existant TravelPoints"
		)
		return Vector3.INF
	return _get_zone().get_a_global_point_in(max_range, ref_point)


## Gets a random travel point in global space that is at least some distance
## away from a reference point.
func get_a_global_point_beyond(min_dist: float, ref_point: Vector3) -> Vector3:
	if _zones.size() == 0:
		printerr(
				"Attempting to obtain random point from "
				+ "non-existant TravelPoints"
		)
		return Vector3.INF
	return _get_zone().get_a_global_point_beyond(min_dist, ref_point)


## Gets a random travel point in global space that is within a specific range
## band relative to a reference point. Returns any random point if no points
## are found.
func get_a_global_point_within(
	min_dist: float,
	max_dist: float,
	ref_point: Vector3
) -> Vector3:
	if _zones.size() == 0:
		printerr(
				"Attempting to obtain random point from "
				+ "non-existant TravelPoints"
		)
		return Vector3.INF
	return _get_zone().get_a_global_point_within(min_dist, max_dist, ref_point)


## Gets a random zone of travel points to use.
func _get_zone() -> TravelPoints:
	if _zones.size() == 0:
		return null
	return _zones[randi() % _zones.size()]
