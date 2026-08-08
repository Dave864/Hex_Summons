@tool
@abstract
class_name TravelPoints
extends Node3D
## Holds a collection of points in 3D space that serve as travel points for
## overworld characters.
##
## Defines a helper that populates a defined area with a selected number of
## points. Places new points on the nav mesh the area is above or on the plane
## if no such mesh is found.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
