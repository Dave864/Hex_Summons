tool
extends AreaRange
class_name ColumnArea
"""
Describes a range whose area starts from a point and reaches out in a diamond
shape.
"""


# Describes how wide the diamond area is.
export (int, 0, 100) var spread = 0 setget set_spread
# Describes how far out the range extends away from the start point.
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
		var cs_points: PoolVector2Array = _cs_as_column()
		$CollisionPolygon.set_depth(_cs_height)
		$CollisionPolygon.set_polygon(cs_points)
		$CollisionPolygon.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		$CollisionPolygon.translation = Vector3.ZERO


func _cs_as_column() -> PoolVector2Array:
	var cs_points: PoolVector2Array = []
	if spread == 1:
		cs_points.resize(6)
		#  5 ----- 4
		#   \  dist \
		#    0       3
		#   /  dist  /
		#  1 ----- 2
		cs_points[0] = Vector2(_tile_distance, 0)
		cs_points[1] = Vector2(_tile_distance, 0).rotated(deg2rad(60))
		cs_points[5] = Vector2(_tile_distance, 0).rotated(deg2rad(-60))
		cs_points[3] = Vector2(_tile_distance * (distance + spread), 0)
		cs_points[2] = cs_points[1] + Vector2(_tile_distance * distance, 0)
		cs_points[4] = cs_points[5] + Vector2(_tile_distance * distance, 0)
	else:
		cs_points.resize(8)
		#   6 ------ 5
		#  /   dist   \
		# 7            \
		#  \            \
		#   0            4
		#  /            /
		# 1            /
		#  \   dist   /
		#   2 ------ 3
		cs_points[0] = Vector2(_tile_distance, 0)
		cs_points[1] = Vector2(_tile_distance, 0).rotated(deg2rad(60))
		cs_points[7] = Vector2(_tile_distance, 0).rotated(deg2rad(-60))
		cs_points[2] = Vector2(_tile_distance * spread, 0).rotated(deg2rad(60))
		cs_points[3] = cs_points[2] + Vector2(_tile_distance * distance, 0)
		cs_points[4] = Vector2(_tile_distance * (distance + spread), 0)
		cs_points[6] = Vector2(_tile_distance * spread, 0).rotated(deg2rad(-60))
		cs_points[5] = cs_points[6] + Vector2(_tile_distance * distance, 0)
	return cs_points
