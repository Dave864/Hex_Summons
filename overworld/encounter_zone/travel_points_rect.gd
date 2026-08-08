@tool
class_name TravelPointsRect
extends TravelPoints
## Holds a collection of points in 3D space that are within a defined
## rectangular area that will serve as travel points for overworld characters.
##
## Defines a helper that populates a defined area with a selected number of
## points. If the plane defined by the rectangle is above a nav mesh, the points
## are placed on said mesh. The points are placed on the plane itself if no
## such mesh is detected.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
