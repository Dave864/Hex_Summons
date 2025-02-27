tool
class_name AreaRange
extends Area
"""
Describes the common parameters for area ranges of all actions, which are split
into the catergories of either `CardinalActoin` or `RingAction`.
"""


enum AreaType {
	CARDINAL,
	RING,
}

# The number of tiles from the character position that are affectable by the action.
export(int, 1, 1000) var area_distance = 1 setget set_area_distance, get_area_distance
# The number of tiles from the character position that are considered out of
# reach for the action. Should be always at least one less than the area_distance.
export(int, 0, 1000) var dead_distance = 0 setget set_dead_distance, get_dead_distance
# Indicates if the action's cast point is fixed to the character's position
# or is able to be defined within the action area.
export(bool) var fixed_to_character
# Denotes if an effect range ignores tile height.
export(bool) var effect_ignore_height

# The height of the collision shape
var _cs_height: float = 0.01
# The distance from the center of one tile to the center of another
var _tile_distance: float = 2 * Constants.HEX_EDGE_RATIO


func set_area_distance(ad: int) -> void:
	area_distance = ad
	set_dead_distance(dead_distance)


func get_area_distance() -> int:
	return area_distance


func set_dead_distance(dd: int) -> void:
	dead_distance = area_distance - 1 if dd >= area_distance else dd


func get_dead_distance() -> int:
	return dead_distance


# Virtual function. Gets the details of the effect range.
func get_effect_range() -> Dictionary:
	return {}


func _ready() -> void:
	pass


# Virtual function. Updates the collision shape to fit the dimensions of the
# effect range.
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
