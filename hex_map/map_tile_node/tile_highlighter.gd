class_name TileHighlighter
extends Spatial


# The material to use when the tile is highlighted
export var highlight_material: SpatialMaterial


# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	$MeshInstance.hide()
	$MeshInstance.set_surface_material(0, highlight_material)


# Called every frame. 'delta' is the elapsed time since the previous frame
#func _process(delta):
#	pass
