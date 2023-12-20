extends Area


export(int) var start_index = 0

onready var _rf: RangeFinder = get_node("../HexMap/RangeFinder")
var _current_index: int = start_index


# Called when the node enters the scene tree for the first time.
func _ready():
	var current_tile = _rf.get_tile_at_index(start_index)
	var start_position: Vector3 = current_tile.translation
	start_position.y = 0.0
	translation = start_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
