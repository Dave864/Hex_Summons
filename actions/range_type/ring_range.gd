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
		$CollisionShape.translation = Vector3.ZERO
	else:
		var c_shape: ConvexPolygonShape = ConvexPolygonShape.new()
		$CollisionShape.set_shape(c_shape)
