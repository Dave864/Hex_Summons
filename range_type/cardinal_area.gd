tool
class_name CardinalRange
extends AreaRange
"""
Describes an area whose area is constrained by the six directions of a hexagon.
"""


# How many tiles out the range will reach.
export(int, 1, 1000) var distance = 1 setget set_distance


func set_distance(val: int) -> void:
	distance = val
	_update_collision_shape()


# Virtual function. Updates the collision shape to fit the dimensions of the
# area.
func _update_collision_shape() -> void:
	var cs_points: PoolVector2Array
	if distance == 1:
		cs_points = _cs_as_ring()
	else:
		cs_points = _cs_as_cardinal()
	$CollisionPolygon.set_polygon(cs_points)
	$CollisionPolygon.set_depth(_cs_height)
	$CollisionPolygon.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	$CollisionPolygon.translation = Vector3.ZERO


# Draw a ring collision shape
func _cs_as_ring() -> PoolVector2Array:
	var cs_points: PoolVector2Array = []
	cs_points.resize(6)
	for i in range(6):
		cs_points[i] = Vector2(_tile_distance, 0.0).rotated(deg2rad(60 * i))
	return cs_points


# Draw a star collision shape to represent a cardinal range.
func _cs_as_cardinal() -> PoolVector2Array:
	var cs_points: PoolVector2Array = []
	cs_points.resize(12)
	for i in range(0, 12, 2):
		var p0: Vector2 = Vector2(_tile_distance * distance, 0.0)
		var p1: Vector2 = Vector2(0.05, 0.05)
		# Prevent issues with convex decomposing
		var deg: float = 60 * (i / 2.0)
		p0 = p0.rotated(deg2rad(deg))
		p1 = p1.rotated(deg2rad(deg))
		cs_points[i] = p0
		cs_points[i + 1] = p1
	return cs_points
