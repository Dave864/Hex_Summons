tool
class_name AreaRange
extends Area
"""
Describes the common parameters for area ranges.
"""

# The index of the map tiles the area is currently touching
var tile_ids: Array = []
# The height of the collision shape
var _cs_height: float = 0.01
# The distance from the center of one tile to the center of another
var _tile_distance: float = 2 * Constants.HEX_EDGE_RATIO


func _ready() -> void:
	connect("area_entered", self, "_on_Area_area_entered")
	connect("area_exited", self, "_on_Area_area_exited")


# Virtual function. Updates the collision shape to fit the dimensions of the
# area.
func _update_collision_shape() -> void:
	pass


# Draw the collision shape as a point, represented as a cube.
func _cs_as_point() -> void:
	var cube_points: PoolVector2Array = []
	cube_points.resize(4)
	cube_points[0] = Vector2(-_cs_height / 2, _cs_height / 2)
	cube_points[1] = Vector2(_cs_height / 2, _cs_height / 2)
	cube_points[2] = Vector2(_cs_height / 2, -_cs_height / 2)
	cube_points[3] = Vector2(-_cs_height / 2, -_cs_height / 2)
	$CollisionPolygon.set_depth(_cs_height)
	$CollisionPolygon.set_polygon(cube_points)


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


func _on_Area_area_entered(map_tile: Area) -> void:
	tile_ids.append(map_tile.get_index())


func _on_Area_area_exited(map_tile: Area) -> void:
	tile_ids.erase(map_tile.get_index())
