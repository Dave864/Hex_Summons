tool
class_name RangeFinder
extends Node
"""
A collection of calculations and algorithms used for various map actions that
depend on getting a range of tiles.
"""


var _z_count: int = 3 setget set_z_count
var _x_count: int = 2 setget set_x_count


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _notification(what):
	match what:
		# When set as child of HexMap node, update the x and z counts to be the
		# values of the x and z counts of the HexMap node.
		NOTIFICATION_PARENTED:
			var hex_map: Spatial = get_parent()
			set_x_count(hex_map.x_count)
			set_z_count(hex_map.z_count)


# Converts the cube coordinates to the corresponding index
func _cube_to_index(coord: Vector3) -> int:
	var z_pos: int = int(coord.y + (coord.x - (int(coord.x) & 1)) / 2.0)
	var x_pos: int = int(coord.x)
	return (z_pos * _x_count) + x_pos


func set_z_count(value: int):
	_z_count = value


func set_x_count(value: int):
	_x_count = value
