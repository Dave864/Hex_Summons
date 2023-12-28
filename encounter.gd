class_name Encounter
extends Node
"""
Manages the events of an encounter.
"""


# Reference to the encounter hex_map
export(NodePath) var hex_map_path = null

onready var character: Character = $PlayerCharacter
onready var selector: Selector = $Selector

var _rf: RangeFinder


# Called when the node enters the scene tree for the first time.
func _ready():
	var hex_map: HexMap = get_node(hex_map_path)
	_rf = RangeFinder.new(
		hex_map.x_count,
		hex_map.z_count,
		hex_map.get_map_tiles()
	)


func _process(_delta):
	pass


func _on_Selector_tile_selected(tile: MapTile):
	SignalBus.emit_signal(
		"tile_selected",
		_rf.calculate_path(
			character.get_index_at(),
			tile.get_index()
		)
	)
