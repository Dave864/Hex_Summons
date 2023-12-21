class_name TileSelector
extends Area

# Indicates that the tile was selected
signal selected()

# The material to use when the mouse hovers over the tile
export var hover_material: SpatialMaterial

# Flag to indicate that the mouse cursor is over the tile
var _mouse_hover: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	_mouse_hover = false
	show()
	$MeshInstance.hide()
	$MeshInstance.set_surface_material(0, hover_material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event is InputEventMouseButton and _mouse_hover:
		# Signal that the tile was selected
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			emit_signal("selected")


func _on_TileSelector_mouse_entered():
	_mouse_hover = true
	$MeshInstance.show()


func _on_TileSelector_mouse_exited():
	_mouse_hover = false
	$MeshInstance.hide()
