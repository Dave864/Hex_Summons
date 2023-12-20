tool
extends Spatial


const TILES_MANAGER_SCRIPT := preload("res://addons/hex_map/tiles/tiles_manager.gd")
const TILES_MANAGER: String = "TilesManager"
const RANGE_FINDER_SCRIPT := preload("res://addons/hex_map/tiles/range_finder.gd")
const RANGE_FINDER: String = "RangeFinder"

# Referene to the scene tree root
var _root_node: Node
var _tiles_manager: Spatial
var _range_finder: Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	_root_node = get_tree().edited_scene_root
	_create_node(_range_finder, RANGE_FINDER, RANGE_FINDER_SCRIPT)
	_create_node(_tiles_manager, TILES_MANAGER, TILES_MANAGER_SCRIPT)


# Create a node using the given parameters
func _create_node(var new_node, name: String, var script):
	# Create the TilesManager nodes if it hasn't already been instanced
	if get_node_or_null(name) == null:
		new_node = Spatial.new()
		new_node.name = name
		new_node.set_script(script)
		new_node.set_process(true)
		add_child(new_node)
		new_node.set_owner(_root_node)
