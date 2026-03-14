@tool
class_name ScalingHexCollider
extends CollisionShape3D
## Enables a CollisionShape3D to be adjustable by outside factors. Only works for
## CollisionShapes described by hex_tile_collision.


## The y coordinate of the top of each map tile.
var _top_y_at_zero: Array[float] = []


func _ready() -> void:
	var points: PackedVector3Array = shape.get_points()
	for i in range(6):
		_top_y_at_zero.append(points[i].y)


## Updates the collision shape mesh so that it reflects the current height.
func _update_collision_shape_height(height: int) -> void:
	if not is_node_ready():
		return
	var points: PackedVector3Array = shape.get_points()
	for i in range(6):
		var h: float = HexUtil.HEX_TILE_UNIT_HEIGHT * height
		points[i] = Vector3(points[i].x, h + _top_y_at_zero[i], points[i].z)
	shape.set_points(points)


## Triggers if the height needs to be updated.
func _on_HeightSource_height_changed(height: int) -> void:
	_update_collision_shape_height(height)
