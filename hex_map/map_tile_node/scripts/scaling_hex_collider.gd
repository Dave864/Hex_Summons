@tool
class_name ScalingHexCollider
extends CollisionShape3D
"""
Enables a CollisionShape3D to be adjustable by outside factors. Only works for
CollisionShapes described by a ConvexPolygonShape3D.
"""


# Updates the collision shape mesh so that it reflects the current height.
func _update_collision_shape_height(height: int) -> void:
	var points: PackedVector3Array = shape.get_points()
	for i in range(6):
		var h: float = Constants.HEX_TILE_UNIT_HEIGHT * height
		points[i] = Vector3(points[i].x, h, points[i].z)
	shape.set_points(points)


func _on_HeightSource_height_changed(height: int) -> void:
	_update_collision_shape_height(height)
