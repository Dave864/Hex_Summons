tool
class_name HexMap
extends Spatial
"""
Initializes the nodes associated with a battle map and makes them available 
in the editor. The following hierarchy is generated:
	HexMap
		TilesManager
			MapTile
			MapTile2
			...
		RangeFinder
		Selector
"""


const TILES_MANAGER: String = "TilesManager"
const TILES_MANAGER_SCRIPT: Script = preload(
	"res://" +
	"hex_map/" +
	"helper_node_scripts/" +
	"tiles_manager.gd"
)
const RANGE_FINDER: String = "RangeFinder"
const RANGE_FINDER_SCRIPT: Script = preload(
	"res://" +
	"hex_map/" +
	"helper_node_scripts/" +
	"range_finder.gd"
)

export(int, 1, 50) var z_count = 3 setget set_z_count
export(int, 1, 50) var x_count = 2 setget set_x_count

# Referene to the scene tree root.
onready var _root_node: Node = get_tree().edited_scene_root


# Called when the node enters the scene tree for the first time.
func _ready():
	# Create the helper nodes associated with the battle map.
	_create_range_finder_node()
	_create_tiles_manager_node()


# Creates the TilesManager node if it has not already been made
func _create_tiles_manager_node():
	if !has_node(TILES_MANAGER):
		var tiles_manager = Spatial.new()
		add_child(tiles_manager)
		_set_node_properties(tiles_manager, TILES_MANAGER, TILES_MANAGER_SCRIPT)
	$TilesManager.set_x_count(x_count)
	$TilesManager.set_z_count(z_count)


# Creates the RangeFinder node if it has not already been made
func _create_range_finder_node():
	if !has_node(RANGE_FINDER):
		var range_finder = Node.new()
		add_child(range_finder)
		_set_node_properties(range_finder, RANGE_FINDER, RANGE_FINDER_SCRIPT)
	$RangeFinder.set_x_count(x_count)
	$RangeFinder.set_z_count(z_count)


# Assign the name and the script of a node
func _set_node_properties(n: Node, name: String, script: Script):
	n.name = name
	n.set_script(script)
	n.set_process(true)
	n.set_owner(_root_node)


func set_z_count(value: int):
	z_count = value
	if has_node("TilesManager"):
		$TilesManager.set_z_count(value)
	if has_node("RangeFinder"):
		$RangeFinder.set_z_count(value)


func set_x_count(value: int):
	x_count = value
	if has_node("TilesManager"):
		$TilesManager.set_x_count(value)
	if has_node("RangeFinder"):
		$RangeFinder.set_x_count(value)
