class_name EmissionPoint
extends Position3D
"""
Defines the tile the action will be emmited from.
"""


var emission_tile: MapTile = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_EmissionPoint_area_entered(map_tile: Area) -> void:
	emission_tile = map_tile
