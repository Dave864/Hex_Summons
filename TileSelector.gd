extends Area


# The material to use when the mouse hovers over the tile
export var hover_material: SpatialMaterial


# Called when the node enters the scene tree for the first time.
func _ready():
	$MeshInstance.set_surface_material(0, hover_material)
	$MeshInstance.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TileSelector_mouse_entered():

	$MeshInstance.show()


func _on_TileSelector_mouse_exited():
	$MeshInstance.hide()
