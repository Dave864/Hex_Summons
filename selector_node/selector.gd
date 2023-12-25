class_name Selector
extends Area
"""
Moves around the map based on mouse movement and detects when a MapTile has been
passed over.
"""


signal tile_selected(map_tile)

# Reference to the map tiles in the current scene
export(NodePath) var _map_path = null

# Indicates when the SelectorShape should lock its position to that of the
# passed over tile.
var _snap_to_position: bool = false
# The position the SelectorShape locks to.
var _snap_position: Vector3 = Vector3.ZERO
# The MapTile that was last passed over
var _tile: MapTile = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	translation = $MousePosition.get_mouse_position()
	if _snap_to_position:
		var new_position: Vector3 = _snap_position - translation
		$SelectorShape.translation = Vector3(new_position.x, 0.125, new_position.z)


func _input(event):
	if event is InputEventMouseButton:
		# On mouse left click
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			emit_signal("tile_selected", _tile)
			$AnimationPlayer.play("selected")


func _on_Selector_area_entered(area):
	_snap_to_position = true
	_snap_position = area.translation
	_tile = area
