tool
class_name ScalingHexMesh
extends MeshInstance
"""
Enables a MeshInstance to be adjustable by outside factors.
"""


# Updates the shape mesh so that it reflects the current height.
func _update_tile_shape_height(height: int) -> void:
	mesh.set_height(Constants.HEX_TILE_UNIT_HEIGHT * (1 + height))
	# Move the shape so that the bottom is always at -0.25
	var y_translate: float = (Constants.HEX_TILE_UNIT_HEIGHT / 2) * (height - 1)
	set_translation(Vector3(0.0, y_translate, 0.0))


func _on_HeightSource_height_changed(height: int) -> void:
	_update_tile_shape_height(height)
