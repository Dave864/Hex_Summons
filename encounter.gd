class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map
export(NodePath) var hex_map = null

onready var character: Character = $Character
onready var selector: Selector = $Selector


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _on_Selector_tile_selected(tile: MapTile):
	character.follow_path(tile.translation)
