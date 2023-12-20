extends Area


export(int) var start_tile_index = 0

onready var _map: Spatial = get_node("../HexMap")
var _current_tile_index: int = start_tile_index


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var current_tile: Spatial = _map.get_map_tile(start_tile_index)
#	var start_position: Vector3 = current_tile.translation
#	start_position.y = 0.0
#	translate_object_local(start_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
