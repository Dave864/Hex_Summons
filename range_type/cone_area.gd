tool
extends AreaRange
class_name ConeArea
"""
Describes a range whose area can be described as a cone.
"""


# Describes how wide the cone area is.
export (int, 0, 6) var spread = 0 setget set_spread
# Describes how far out the cone extends away from the start point.
export (int, 1, 100) var distance = 1 setget set_distance


func set_spread(s: int) -> void:
	spread = s
	_update_collision_shape()


func set_distance(d: int) -> void:
	distance = d
	_update_collision_shape()


# Virtual function. Updates the collision shape to fit the dimensions of the
# area.
func _update_collision_shape() -> void:
	if spread == 0 and distance == 1:
		_cs_as_point()
		# Position the point collision to be on the adjacent tile
		$CollisionPolygon.translation = Vector3(_tile_distance, 0.0, 0.0)
	elif spread == 0:
		_cs_as_line(((2 * distance) - 2) * Constants.HEX_EDGE_RATIO)
	else:
		var cs_points: PoolVector2Array = _cs_as_cone()
		$CollisionPolygon.set_depth(_cs_height)
		$CollisionPolygon.set_polygon(cs_points)
		$CollisionPolygon.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		$CollisionPolygon.translation = Vector3.ZERO


# Draw a cone collision shape
func _cs_as_cone() -> PoolVector2Array:
	var cs_points: PoolVector2Array = []
	cs_points.resize(2 * spread + 2)
	for i in range(spread + 1):
		var p0: Vector2 = Vector2(_tile_distance, 0.0)
		# Set distance to be small to represent a line around a spread
		var d: float = distance + 1 if distance > 1 else _cs_height + 1
		var p1: Vector2 = Vector2(_tile_distance * d, 0.0)
		# Prevent issues with convex decomposing
		var deg: float = 60 * i if i < 6 else 359
		p0 = p0.rotated(deg2rad(deg))
		p1 = p1.rotated(deg2rad(deg))
		cs_points[i] = p0
		# Place second point from the end of the array to have the
		# resulting collision shape be drawn correctly
		cs_points[(2 * spread + 2) - i - 1] = p1
	return cs_points
