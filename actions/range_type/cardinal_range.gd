tool
class_name CardinalRange
extends AreaRange
"""
Describes an action range whose area is constrained by the six directions of a hexagon.
"""


enum EffectType {
	CONE,
	COLUMN,
}

# The "width" of the effect area.
export(int, 0, 6) var effect_spread = 0 setget set_spread
# How many tiles out from the cast point the action will affect.
export(int, 1, 1000) var effect_distance = 1 setget set_distance
export(EffectType) var effect_type setget set_effect_type


func set_spread(value: int) -> void:
	effect_spread = value
	_update_collision_shape()


func set_distance(val: int) -> void:
	effect_distance = val
	_update_collision_shape()


func set_effect_type(type: int) -> void:
	effect_type = type
	_update_collision_shape()


# Virtual function. Gets the details of the effect range.
func get_effect_range() -> Dictionary:
	return {
		"area_type": AreaType.CARDINAL,
		"effect_type": effect_type,
		"distance": effect_distance,
		"spread": effect_spread
	}


# Virtual function. Updates the collision shape to fit the dimensions of the
# effect range.
func _update_collision_shape() -> void:
	if effect_spread == 0 and effect_distance == 1:
		_cs_as_point()
		# Position the point collision to be on the adjacent tile
		$CollisionPolygon.translation = Vector3(_tile_distance, 0.0, 0.0)
	elif effect_spread == 0:
		_cs_as_line(((2 * effect_distance) - 2) * Constants.HEX_EDGE_RATIO)
	else:
		var cs_points: PoolVector2Array = []
		$CollisionPolygon.set_depth(_cs_height)
		match effect_type:
			EffectType.CONE:
				cs_points = _cs_as_cone()
			EffectType.COLUMN:
				cs_points = _cs_as_column()
		$CollisionPolygon.set_polygon(cs_points)
		$CollisionPolygon.rotation_degrees = Vector3(90.0, 0.0, 0.0)
		$CollisionPolygon.translation = Vector3.ZERO


# Draw the collision shape as a line, represented as a long cube.
func _cs_as_line(length: float) -> void:
	var cube_points: PoolVector2Array = []
	cube_points.resize(4)
	cube_points[0] = Vector2(-_cs_height / 2, 0)
	cube_points[1] = Vector2(_cs_height / 2, 0)
	cube_points[2] = Vector2(-_cs_height / 2, length)
	cube_points[3] = Vector2(_cs_height / 2, length)
	$CollisionPolygon.set_depth(_cs_height)
	$CollisionPolygon.set_polygon(cube_points)
	$CollisionPolygon.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	# Position the line collision to start on an adjacent tile
	$CollisionPolygon.translation = Vector3(
		(length / 2) + _tile_distance,
		0.0,
		0.0
	)


# Draw a cone collision shape
func _cs_as_cone() -> PoolVector2Array:
	var cs_points: PoolVector2Array = []
	cs_points.resize(2 * effect_spread + 2)
	for i in range(effect_spread + 1):
		var p0: Vector2 = Vector2(_tile_distance, 0.0)
		# Set distance to be small to represent a line around a spread
		var d: float = effect_distance + 1 if effect_distance > 1 else _cs_height + 1
		var p1: Vector2 = Vector2(_tile_distance * d, 0.0)
		# Prevent issues with convex decomposing
		var deg: float = 60 * i if i < 6 else 359
		p0 = p0.rotated(deg2rad(deg))
		p1 = p1.rotated(deg2rad(deg))
		cs_points[i] = p0
		# Place second point from the end of the array to have the
		# resulting collision shape be drawn correctly
		cs_points[(2 * effect_spread + 2) - i - 1] = p1
	return cs_points


# Draw a "column" collision shape
func _cs_as_column() -> PoolVector2Array:
	var cs_points: PoolVector2Array = []
	if effect_spread == 1:
		cs_points.resize(6)
		#  5 ----- 4
		#   \  dist \
		#    0       3
		#   /  dist  /
		#  1 ----- 2
		cs_points[0] = Vector2(_tile_distance, 0)
		cs_points[1] = Vector2(_tile_distance, 0).rotated(deg2rad(60))
		cs_points[5] = Vector2(_tile_distance, 0).rotated(deg2rad(-60))
		cs_points[3] = Vector2(_tile_distance * (effect_distance + effect_spread), 0)
		cs_points[2] = cs_points[1] + Vector2(_tile_distance * effect_distance, 0)
		cs_points[4] = cs_points[5] + Vector2(_tile_distance * effect_distance, 0)
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
		cs_points[2] = Vector2(_tile_distance * effect_spread, 0).rotated(deg2rad(60))
		cs_points[3] = cs_points[2] + Vector2(_tile_distance * effect_distance, 0)
		cs_points[4] = Vector2(_tile_distance * (effect_distance + effect_spread), 0)
		cs_points[6] = Vector2(_tile_distance * effect_spread, 0).rotated(deg2rad(-60))
		cs_points[5] = cs_points[6] + Vector2(_tile_distance * effect_distance, 0)
	return cs_points
