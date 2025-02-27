tool
class_name RingRange
extends AreaRange
"""
Describes an action range whose area encompasses all hexes within the defined distance.
"""


# How many tiles out from the cast point the action will affect.
export(int, 0, 1000) var distance = 0 setget set_distance


func set_distance(val: int) -> void:
	distance = val
	_update_collision_shape()


# Virtual function. Updates the collision shape to fit the dimensions of the
# effect range.
func _update_collision_shape() -> void:
	if distance == 0:
		_cs_as_point()
		$CollisionPolygon.translation = Vector3.ZERO
	else:
		var cs_points: PoolVector2Array = _cs_as_ring()
		$CollisionPolygon.set_depth(_cs_height)
		$CollisionPolygon.set_polygon(cs_points)
		$CollisionPolygon.rotation_degrees = Vector3(90.0, 0.0 ,0.0)


# Draw the collision shape as a hexagonal ring.
func _cs_as_ring() -> PoolVector2Array:
	var cs_shape: PoolVector2Array = []
	cs_shape.resize(6)
	for i in range(6):
		cs_shape[i] = Vector2(_tile_distance * distance, 0.0).rotated(deg2rad(60 * i))
	return cs_shape
