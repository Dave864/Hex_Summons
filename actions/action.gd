class_name Action
extends Node
"""
Describes the range, damage profile, and effects of an action.
"""


export(int, 1, 1000) var power

var targeted_tiles: Array = []

onready var range_data: AreaRange = $EmmisionPoint/Range
onready var emission_pt: EmissionPoint = $EmissionPoint


# Clear out the array of target tiles.
func clear_targets() -> void:
	targeted_tiles.clear()


func enable_collision() -> void:
	emission_pt.Area.set_monitoring(true)
	range_data.set_monitoring(true)


func disable_collision() -> void:
	emission_pt.Area.set_monitoring(false)
	range_data.set_monitoring(false)
	clear_targets()


# Rotates the range area along the y-axis to align it with specified point.
# Will only affect cardinal_range areas.
func align_to_point(point: Vector3) -> void:
	if range_data is CardinalRange:
		point.y = 0.0
		var emission_pos: Vector3 = emission_pt.translation
		emission_pos.y = 0.0
		var direction: Vector3 = (point - emission_pos).normalized()
		var rotation: Vector3 = Vector3.RIGHT.rotated(
			Vector3.UP,
			Vector3.RIGHT.angle_to(direction)
		)
		emission_pt.rotation_degrees = rotation


func _ready() -> void:
	range_data.connect("area_entered", self, "_on_Range_area_entered")
	range_data.connect("area_exited", self, "_on_Range_area_exited")
	disable_collision()


func _on_Range_area_entered(tile: Area) -> void:
	targeted_tiles.append(tile)


func _on_Range_area_exited(tile: Area) -> void:
	targeted_tiles.erase(tile)
