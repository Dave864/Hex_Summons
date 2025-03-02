extends Node
class_name Resistance
"""
Node that defines a resistance stat. Resistance determines mitigation against
hostile actions of a given element.
"""


# Describes a resistance type.
enum Element {FIRE, EARTH, WATER, WIND}

export(Element) var type = Element.FIRE
export(int, 1, 1000) var value = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
