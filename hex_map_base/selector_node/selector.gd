class_name Selector
extends Area
"""
Moves around the map based on mouse movement and detects when a tile has been
passed over.
"""


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translation = $MousePosition.get_mouse_position()


func _on_Selector_area_entered(area):
	pass # Replace with function body.
