extends Node
class_name Magic
"""
Node that defines a magic stat. Magic determines elemental potency of an action.
"""


# Describes a magic type.
enum Element {FIRE, EARTH, WATER, WIND}

export(Element) var type = Element.FIRE
export(int, 1, 1000) var value = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
