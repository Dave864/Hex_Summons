tool
extends Spatial


const TILES_MANAGER_SCRIPT := preload("TilesManager.gd")
const TILES_MANAGER: String = "TilesManager"

# Referene to the scene tree root
var _root_node: Node
var _tiles_manager: Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	_root_node = get_tree().edited_scene_root
	_create_tiles_manager()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Create the TilesManager node
func _create_tiles_manager():
	# Create the TilesManager nodes if it hasn't already been instanced
	if get_child_count() == 0:
		_tiles_manager = Spatial.new()
		_tiles_manager.name = TILES_MANAGER
		_tiles_manager.set_script(TILES_MANAGER_SCRIPT)
		_tiles_manager.set_process(true)
		add_child(_tiles_manager)
		_tiles_manager.set_owner(_root_node)
