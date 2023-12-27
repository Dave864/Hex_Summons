class_name Character
extends Area
"""
Base class for players, mobs, and bosses. Contains a character's stats and map
position details.
"""


# The rate at which the character moves
export(float, 1.0) var movement_time

# Flag that indicates whether the creature has been set to its starting location
var _start_set: bool = false
var _current_index: int = -1 setget , get_index_at

# References to the various attacks and spells the character has access to
onready var _techniques: Array = $Techniques.get_children()
onready var _spells: Array = $Spells.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Creature_area_entered(map_tile):
	_current_index = map_tile.get_index()
	# If the creature's start position has not been set, move it to the position
	# of the tile it in the area of.
	if !_start_set:
		_start_set = true
		translation = map_tile.translation


# Moves the character along to the points of the path.
func follow_path(path: Array):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	for point in path:
		tween.tween_property(self, "translation", point, movement_time)


# Get the index of the tile the character is currently at.
func get_index_at() -> int:
	return _current_index
