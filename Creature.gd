extends Area


const TILES_MANAGER_PATH: String = "../HexMap/TilesManager"
const RANGE_FINDER_PATH: String = "../HexMap/RangeFinder"

export(int) var start_index = 0

var _rf: RangeFinder = null
var _current_index: int = start_index


# Called when the node enters the scene tree for the first time.
func _ready():
	var tm = get_node(TILES_MANAGER_PATH)
	var start_position: Vector3 = tm.get_child(start_index).translation
	start_position.y = 0.0
	translation = start_position
	
	if SignalBus.connect("tile_selected", self, "_on_tile_selected"):
		# TODO: implement error handling
		printerr("Failed to connect tile_selected signal to Creature node")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Sets the reference to the RangeFinder node
# Workaround for RangeFinder node not being created during _ready()
func _set_range_finder():
	_rf = get_node(RANGE_FINDER_PATH) if _rf == null else _rf


# Move the creature node to the selected tile
func _on_tile_selected(tile: MapTile):
	var destination: Vector3 = tile.translation
	destination.y = 0.0
	translation = destination
