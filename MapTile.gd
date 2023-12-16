extends Spatial


# Flag that indicates whether the tile is active or not
export var active: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if !active:
		hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
