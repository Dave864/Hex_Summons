class_name Character
extends Area


# The rate at which the character moves
export(float, 1.0) var movement_time

# Flag that indicates whether the creature has been set to its starting location
var _start_set: bool = false
var _current_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Move the creature node to the selected tile
#func _on_tile_selected(tile: MapTile):
#	var destination: Vector3 = tile.translation
#	destination.y = 0.0
#	translation = destination


func _on_Creature_area_entered(map_tile):
	_current_index = map_tile.get_index()
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
		translation = map_tile.translation


func follow_path(path: Array):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	for point in path:
		tween.tween_property(self, "translation", point, movement_time)
