class_name Selector
extends Area
"""
Moves around the map based on mouse movement and detects when a tile has been
passed over.
"""


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _snap_selector: bool = false
var _snap_position: Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	translation = $MousePosition.get_mouse_position()
	if _snap_selector:
		var new_position: Vector3 = _snap_position - translation
		$SelectorShape.translation = Vector3(new_position.x, 0.125, new_position.z)


func _on_Selector_area_entered(area):
	_snap_selector = true
	_snap_position = area.translation
