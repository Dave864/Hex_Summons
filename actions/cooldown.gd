class_name Cooldown
extends Node
"""
Represents the number of turns that need to pass before an action can be used
again.
"""


export(int, 0, 10) var turn_count = 0

var _countdown: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
