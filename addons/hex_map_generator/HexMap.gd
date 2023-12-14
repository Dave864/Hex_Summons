tool
extends Spatial

# Reference to the scene for the map tile
export(PackedScene) var map_tile
# The number of tiles along the X axis
export(int, 3, 30) var x_count = 3
# The number of tiles along the Z axis
export(int, 1, 30) var z_count = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
