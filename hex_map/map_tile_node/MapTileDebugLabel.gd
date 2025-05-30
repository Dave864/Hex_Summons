tool
extends Label3D
"""
Label for map tiles used for debugging. Will remove once no longer needed.
"""


export(NodePath) var coordinate_ref = null


func update_label_display(height: int) -> void:
	var format: String = "[%d:%d]\n%s  \n    %s\n%s  "
	var coord: MapCoordinate = get_node(coordinate_ref)
	var cube_coord: Vector3 = coord.get_cube_coord()
	text = str(
			format % [
				coord.get_map_index(), 
				height, 
				cube_coord.x,
				cube_coord.y,
				cube_coord.z
			]
	)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_MapTile_height_changed(new_height: int) -> void:
	update_label_display(new_height)
