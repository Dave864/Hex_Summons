class_name Action
extends Node
"""
Describes the range and effects of an action.
"""


"""
TODO: Implement logic to use stats nodes to define action effect
"""
export(int, 1, 1000) var power
# Flag that denotes if the emission is fixed to the center of the area
export(bool) var emit_from_center

# The area that is ignored when determining the possible tiles for effect emmision.
var _dead_range: AreaRange
# The area specifying the possible tiles for effect emmision.
var _area_range: AreaRange

# The point the area range collisions are located at.
onready var area_pt: Position3D = $AreaPoint
# The area specifying the tiles affected by the effect.
onready var effect_range: AreaRange = $EmissionPoint/EffectRange
# The point the effect is emitted from.
onready var emission_pt: EmissionPoint = $EmissionPoint


func _ready() -> void:
	# No DeadRange node indicates no dead range.
	_dead_range = get_node_or_null("AreaPoint/DeadRange")
	_area_range = get_node("AreaPoint/AreaRange")


func _process(_delta) -> void:
	pass


# Get the tiles in the area range, accounting for the dead range.
func get_area_tiles() -> Array:
	var area_tiles: Array = _area_range.tile_ids.duplicate(true)
	if _dead_range:
		for i in _dead_range.tile_ids:
			area_tiles.erase(i)
	return area_tiles


func enable_area_collision() -> void:
	_area_range.set_monitoring(true)
	if _dead_range:
		_dead_range.set_monitoring(true)


func disable_area_collision() -> void:
	_area_range.set_monitoring(false)
	if _dead_range:
		_dead_range.set_monitoring(false)


func enable_effect_collision() -> void:
	emission_pt.get_node("Area").set_monitoring(true)
	effect_range.set_monitoring(true)


func disable_effect_collision() -> void:
	emission_pt.get_node("Area").set_monitoring(false)
	effect_range.set_monitoring(false)


# Rotates the emission along the y-axis to align it with a specified point.
# Will only affect cardinal_range areas.
func rotate_to_point(point: Vector3, inverse: bool = false) -> void:
	if _area_range is CardinalRange:
		point.y = 0.0
		var emission_pos: Vector3 = emission_pt.global_translation
		emission_pos.y = 0.0
		var direction: Vector3 = (point - emission_pos).normalized()
		direction = -direction if inverse else direction
		var rotation: Vector3 = Vector3.RIGHT.rotated(
			Vector3.UP,
			Vector3.RIGHT.angle_to(direction)
		)
		emission_pt.rotation_degrees = rotation


# Resets the position of the emittor position.
func reset_emittor_position() -> void:
	emission_pt.translation = Vector3.ZERO


# Positions the emittor at the tile.
func _on_Selector_tile_hovered(tile: Area) -> void:
	if emit_from_center:
		rotate_to_point(tile.global_translation, true)
	else:
		emission_pt.global_translation = tile.global_translation
		rotate_to_point(_area_range.global_translation)
