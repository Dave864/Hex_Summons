class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map
export(NodePath) var hex_map_path = null

onready var character: Character = $Character
onready var selector: Selector = $Selector
onready var rf: RangeFinder = get_node("%s/RangeFinder" % hex_map_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass


func _on_Selector_tile_selected(tile: MapTile):
	var path: PoolIntArray = rf.calculate_path(character.get_index(), tile.get_index())
	print(path)
	character.follow_path([tile.translation])
