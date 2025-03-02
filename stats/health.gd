extends Node
class_name Health
"""
Node that defines the health stat.
"""

signal health_changed(new_value)

export(int, 1, 1000) var max_value

var cur_value: int = max_value setget set_current_value


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_current_value(v: int) -> void:
	cur_value = max_value if v > max_value else 0 if v < 0 else v
	emit_signal("health_changed", cur_value)
