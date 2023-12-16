extends Area

# Indicates that the tile was selected
signal tile_selected

# The material to use when the mouse hovers over the tile
export var hover_material: SpatialMaterial

# Flag to indicate that the mouse cursor is over the tile
var mouse_hover: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_hover = false;
	$MeshInstance.set_surface_material(0, hover_material)
	$MeshInstance.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event is InputEventMouseButton and mouse_hover:
		$AnimationPlayer.play("selected")
		emit_signal("tile_selected")


func _on_TileSelector_mouse_entered():
	mouse_hover = true
	$MeshInstance.show()


func _on_TileSelector_mouse_exited():
	mouse_hover = false
	$MeshInstance.hide()
